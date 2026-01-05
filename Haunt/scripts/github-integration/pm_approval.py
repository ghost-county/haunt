#!/usr/bin/env python3
"""
PM Approval Workflow for GitHub Issues

Phase 1: Simple CLI-based approval workflow
Phase 2: Interactive PM agent integration (future)

Allows PM to review pending GitHub issues and approve/reject for roadmap addition
"""

import json
import logging
import os
import sys
from pathlib import Path
from typing import Dict, Any, List

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML is not installed. Install with: pip install pyyaml", file=sys.stderr)
    sys.exit(1)

try:
    import requests
except ImportError:
    print("ERROR: requests library is not installed. Install with: pip install requests", file=sys.stderr)
    sys.exit(1)

from roadmap_mapper import RoadmapMapper


class PMApprovalWorkflow:
    """Manages PM approval workflow for GitHub issues"""

    def __init__(self, config_path: str = "config.yaml"):
        """Initialize approval workflow"""
        self.config = self._load_config(config_path)
        self.mapper = RoadmapMapper(self.config)
        self.setup_logging()
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'token {self.config["repository"]["token"]}',
            'Accept': 'application/vnd.github.v3+json'
        })

    def _load_config(self, config_path: str) -> Dict[str, Any]:
        """Load configuration from YAML file"""
        config_file = Path(__file__).parent / config_path

        if not config_file.exists():
            raise FileNotFoundError(f"Configuration file not found: {config_file}")

        with open(config_file, 'r') as f:
            config = yaml.safe_load(f)

        # Substitute environment variables
        config['repository']['token'] = os.getenv('GH_TOKEN', config['repository']['token'])

        return config

    def setup_logging(self):
        """Configure logging"""
        log_config = self.config.get('logging', {})
        log_level = getattr(logging, log_config.get('level', 'INFO'))

        logging.basicConfig(
            level=log_level,
            format=log_config.get('format', '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        )

        self.logger = logging.getLogger(__name__)

    def load_pending_issues(self) -> List[Dict[str, Any]]:
        """Load pending issues from queue"""
        pending_file = Path(self.config['state']['processed_issues_file']).parent / 'pending-issues.json'

        if not pending_file.exists():
            return []

        try:
            with open(pending_file, 'r') as f:
                return json.load(f)
        except (json.JSONDecodeError, IOError) as e:
            self.logger.error(f"Failed to load pending issues: {e}")
            return []

    def save_pending_issues(self, issues: List[Dict[str, Any]]):
        """Save pending issues queue"""
        pending_file = Path(self.config['state']['processed_issues_file']).parent / 'pending-issues.json'
        pending_file.parent.mkdir(parents=True, exist_ok=True)

        try:
            with open(pending_file, 'w') as f:
                json.dump(issues, indent=2, fp=f)
        except IOError as e:
            self.logger.error(f"Failed to save pending issues: {e}")

    def load_processed_issues(self) -> List[Dict[str, Any]]:
        """Load processed issues log"""
        processed_file = Path(self.config['state']['processed_issues_file'])

        if not processed_file.exists():
            return []

        try:
            with open(processed_file, 'r') as f:
                return json.load(f)
        except (json.JSONDecodeError, IOError) as e:
            self.logger.warning(f"Failed to load processed issues: {e}")
            return []

    def save_processed_issues(self, issues: List[Dict[str, Any]]):
        """Save processed issues log"""
        processed_file = Path(self.config['state']['processed_issues_file'])
        processed_file.parent.mkdir(parents=True, exist_ok=True)

        try:
            with open(processed_file, 'w') as f:
                json.dump(issues, indent=2, fp=f)
        except IOError as e:
            self.logger.error(f"Failed to save processed issues: {e}")

    def get_next_req_number(self) -> int:
        """
        Determine next available REQ number from roadmap

        Returns:
            Next REQ number to use
        """
        roadmap_file = Path(self.config['roadmap']['file'])

        if not roadmap_file.exists():
            self.logger.warning(f"Roadmap file not found: {roadmap_file}")
            return 1

        try:
            with open(roadmap_file, 'r') as f:
                content = f.read()

            # Find all REQ-XXX numbers
            import re
            req_numbers = re.findall(r'REQ-(\d+)', content)

            if not req_numbers:
                return 1

            # Return max + 1
            return max(int(n) for n in req_numbers) + 1

        except IOError as e:
            self.logger.error(f"Failed to read roadmap: {e}")
            return 1

    def add_to_roadmap(self, issue_data: Dict[str, Any], req_number: int):
        """
        Add approved issue to roadmap

        Args:
            issue_data: GitHub issue metadata
            req_number: Assigned REQ number
        """
        roadmap_file = Path(self.config['roadmap']['file'])

        if not roadmap_file.exists():
            self.logger.error(f"Roadmap file not found: {roadmap_file}")
            return

        # Generate requirement markdown
        requirement = self.mapper.generate_requirement(issue_data, req_number)

        # Read existing roadmap
        try:
            with open(roadmap_file, 'r') as f:
                roadmap_lines = f.readlines()
        except IOError as e:
            self.logger.error(f"Failed to read roadmap: {e}")
            return

        # Find insertion point
        insert_after = self.config['roadmap'].get('insert_after', '## Current Focus:')
        insert_index = None

        for i, line in enumerate(roadmap_lines):
            if insert_after in line:
                insert_index = i + 1
                # Skip Active Work section to insert after it
                while insert_index < len(roadmap_lines) and not roadmap_lines[insert_index].startswith('##'):
                    insert_index += 1
                break

        if insert_index is None:
            self.logger.error(f"Could not find insertion point: {insert_after}")
            return

        # Insert requirement
        roadmap_lines.insert(insert_index, '\n' + requirement + '\n---\n\n')

        # Write back to roadmap
        try:
            with open(roadmap_file, 'w') as f:
                f.writelines(roadmap_lines)
            self.logger.info(f"Added REQ-{req_number:03d} to roadmap")
        except IOError as e:
            self.logger.error(f"Failed to write roadmap: {e}")

    def post_github_comment(self, issue_number: int, comment_body: str):
        """
        Post comment to GitHub issue

        Args:
            issue_number: GitHub issue number
            comment_body: Comment text
        """
        repo = self.config['repository']['name']

        try:
            response = self.session.post(
                f'https://api.github.com/repos/{repo}/issues/{issue_number}/comments',
                json={'body': comment_body}
            )
            response.raise_for_status()
            self.logger.info(f"Posted comment to issue #{issue_number}")
        except requests.RequestException as e:
            self.logger.error(f"Failed to post comment: {e}")

    def approve_issue(self, issue_data: Dict[str, Any]):
        """
        Approve issue and add to roadmap

        Args:
            issue_data: GitHub issue metadata
        """
        # Get next REQ number
        req_number = self.get_next_req_number()

        # Add to roadmap
        self.add_to_roadmap(issue_data, req_number)

        # Post bidirectional link comment if enabled
        comment = self.mapper.add_bidirectional_link(issue_data, req_number)
        if comment:
            self.post_github_comment(issue_data['issue_number'], comment)

        # Mark as processed
        processed_issues = self.load_processed_issues()
        processed_issues.append({
            'issue_id': issue_data['issue_id'],
            'issue_number': issue_data['issue_number'],
            'req_number': req_number,
            'approved': True,
            'approved_at': str(Path(__file__).stat().st_mtime)
        })
        self.save_processed_issues(processed_issues)

        self.logger.info(f"Approved issue #{issue_data['issue_number']} as REQ-{req_number:03d}")

    def reject_issue(self, issue_data: Dict[str, Any]):
        """
        Reject issue (do not add to roadmap)

        Args:
            issue_data: GitHub issue metadata
        """
        # Mark as processed but rejected
        processed_issues = self.load_processed_issues()
        processed_issues.append({
            'issue_id': issue_data['issue_id'],
            'issue_number': issue_data['issue_number'],
            'approved': False,
            'rejected_at': str(Path(__file__).stat().st_mtime)
        })
        self.save_processed_issues(processed_issues)

        self.logger.info(f"Rejected issue #{issue_data['issue_number']}")

    def review_pending_issues(self):
        """Interactive CLI workflow to review pending issues"""
        pending = self.load_pending_issues()

        if not pending:
            print("No pending issues to review.")
            return

        print("\n=== PM Approval Workflow ===")
        print(f"Pending issues: {len(pending)}\n")

        approved_count = 0
        rejected_count = 0

        for issue in pending[:]:  # Iterate over copy so we can modify original
            print(f"\n--- Issue #{issue['issue_number']} ---")
            print(f"Title: {issue['title']}")
            print(f"URL: {issue['url']}")
            print(f"Labels: {', '.join(issue.get('labels', []))}")
            print(f"Marker location: {issue.get('marker_location', 'unknown')}")
            print("\nBody preview:")
            print(issue.get('body', 'No description')[:200])
            print("...")

            # Get PM decision
            while True:
                decision = input("\nApprove (a), Reject (r), Skip (s), or Quit (q)? ").strip().lower()

                if decision == 'a':
                    self.approve_issue(issue)
                    pending.remove(issue)
                    approved_count += 1
                    break
                elif decision == 'r':
                    self.reject_issue(issue)
                    pending.remove(issue)
                    rejected_count += 1
                    break
                elif decision == 's':
                    break
                elif decision == 'q':
                    print("\nQuitting review process.")
                    self.save_pending_issues(pending)
                    print(f"Approved: {approved_count}, Rejected: {rejected_count}, Remaining: {len(pending)}")
                    return
                else:
                    print("Invalid choice. Please enter a, r, s, or q.")

        # Save remaining pending issues
        self.save_pending_issues(pending)

        print("\n=== Review Complete ===")
        print(f"Approved: {approved_count}")
        print(f"Rejected: {rejected_count}")
        print(f"Remaining: {len(pending)}")


def main():
    """Entry point for PM approval workflow"""
    config_path = sys.argv[1] if len(sys.argv) > 1 else 'config.yaml'

    try:
        workflow = PMApprovalWorkflow(config_path)
        workflow.review_pending_issues()
    except Exception as e:
        print(f"ERROR: Approval workflow failed: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
