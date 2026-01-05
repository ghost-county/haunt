#!/usr/bin/env python3
"""
GitHub Issue Scanner for @haunt marker detection

Tier 2 of hybrid architecture - Polling fallback using GitHub Search API
Periodically scans for issues with @haunt marker that webhooks may have missed
"""

import json
import logging
import os
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, List, Optional

try:
    import requests
except ImportError:
    print("ERROR: requests library is not installed. Install with: pip install requests", file=sys.stderr)
    sys.exit(1)

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML is not installed. Install with: pip install pyyaml", file=sys.stderr)
    sys.exit(1)


class IssueScanner:
    """Polls GitHub Search API for issues with @haunt marker"""

    def __init__(self, config_path: str = "config.yaml"):
        """Initialize issue scanner with configuration"""
        self.config = self._load_config(config_path)
        self.setup_logging()
        self.session = requests.Session()
        self.session.headers.update({
            'Authorization': f'token {self.config["repository"]["token"]}',
            'Accept': 'application/vnd.github.v3+json'
        })

    def _load_config(self, config_path: str) -> Dict[str, Any]:
        """Load configuration from YAML file with environment variable substitution"""
        config_file = Path(__file__).parent / config_path

        if not config_file.exists():
            raise FileNotFoundError(
                f"Configuration file not found: {config_file}\n"
                f"Copy config.yaml.template to config.yaml and configure values."
            )

        with open(config_file, 'r') as f:
            config = yaml.safe_load(f)

        # Substitute environment variables
        config['repository']['token'] = os.getenv('GH_TOKEN', config['repository']['token'])

        # Validate required fields
        if not config['repository']['token'] or config['repository']['token'].startswith('${'):
            raise ValueError("GH_TOKEN environment variable not set")

        return config

    def setup_logging(self):
        """Configure logging based on config settings"""
        log_config = self.config.get('logging', {})
        log_level = getattr(logging, log_config.get('level', 'INFO'))
        log_file = log_config.get('file')

        # Create log directory if it doesn't exist
        if log_file:
            log_path = Path(log_file)
            log_path.parent.mkdir(parents=True, exist_ok=True)

        logging.basicConfig(
            level=log_level,
            format=log_config.get('format', '%(asctime)s - %(name)s - %(levelname)s - %(message)s'),
            handlers=[
                logging.FileHandler(log_file) if log_file else logging.StreamHandler(),
                logging.StreamHandler()  # Always log to console
            ]
        )

        self.logger = logging.getLogger(__name__)

    def check_rate_limit(self) -> bool:
        """
        Check GitHub API rate limit status

        Returns:
            True if sufficient quota remaining, False if rate limited
        """
        try:
            response = self.session.get('https://api.github.com/rate_limit')
            response.raise_for_status()
            data = response.json()

            core_limit = data['resources']['core']
            remaining = core_limit['remaining']
            reset_time = datetime.fromtimestamp(core_limit['reset'])

            self.logger.debug(f"Rate limit: {remaining} remaining, resets at {reset_time}")

            min_remaining = self.config['rate_limit'].get('min_remaining', 1000)

            if remaining < min_remaining:
                self.logger.warning(
                    f"Rate limit low: {remaining} remaining (threshold: {min_remaining}). "
                    f"Resets at {reset_time}"
                )
                return False

            return True

        except requests.RequestException as e:
            self.logger.error(f"Failed to check rate limit: {e}")
            return False

    def has_marker(self, text: str) -> bool:
        """
        Check if text contains @haunt marker

        Args:
            text: Text to search (issue body or comment)

        Returns:
            True if marker found, False otherwise
        """
        if not text:
            return False

        marker = self.config['marker']['text']
        case_sensitive = self.config['marker'].get('case_sensitive', False)

        if case_sensitive:
            return marker in text
        else:
            return marker.lower() in text.lower()

    def search_issues(self, since: Optional[datetime] = None) -> List[Dict[str, Any]]:
        """
        Search for issues containing @haunt marker

        Args:
            since: Only return issues updated after this datetime

        Returns:
            List of issue dictionaries
        """
        # Build search query
        marker = self.config['marker']['text']
        repo = self.config['repository']['name']
        query_parts = [
            marker,
            f'repo:{repo}',
            'is:issue',
            'is:open'
        ]

        # Add date filter if incremental scanning
        if since and self.config['polling'].get('incremental', True):
            date_str = since.strftime('%Y-%m-%d')
            query_parts.append(f'updated:>={date_str}')

        query = ' '.join(query_parts)

        # Search using GitHub Search API
        try:
            response = self.session.get(
                'https://api.github.com/search/issues',
                params={
                    'q': query,
                    'per_page': self.config['polling'].get('limit', 100),
                    'sort': 'updated',
                    'order': 'desc'
                }
            )
            response.raise_for_status()

            data = response.json()
            total_count = data.get('total_count', 0)
            issues = data.get('items', [])

            self.logger.info(f"Search found {total_count} issues (returned {len(issues)})")

            return issues

        except requests.RequestException as e:
            self.logger.error(f"Search API request failed: {e}")
            return []

    def fetch_issue_comments(self, issue_number: int) -> List[Dict[str, Any]]:
        """
        Fetch comments for a specific issue

        Args:
            issue_number: GitHub issue number

        Returns:
            List of comment dictionaries
        """
        repo = self.config['repository']['name']

        try:
            response = self.session.get(
                f'https://api.github.com/repos/{repo}/issues/{issue_number}/comments'
            )
            response.raise_for_status()
            return response.json()

        except requests.RequestException as e:
            self.logger.error(f"Failed to fetch comments for issue #{issue_number}: {e}")
            return []

    def extract_issue_data(self, issue: Dict[str, Any]) -> Dict[str, Any]:
        """
        Extract relevant data from issue object

        Args:
            issue: GitHub issue API response

        Returns:
            Dictionary with extracted issue data
        """
        # Determine marker location
        marker_location = None
        if 'body' in self.config['marker']['search_in']:
            if self.has_marker(issue.get('body', '')):
                marker_location = 'issue_body'

        # Check comments if marker not found in body
        if not marker_location and 'comments' in self.config['marker']['search_in']:
            comments = self.fetch_issue_comments(issue['number'])
            for comment in comments:
                if self.has_marker(comment.get('body', '')):
                    marker_location = 'comment'
                    break

        return {
            'issue_number': issue['number'],
            'issue_id': issue['id'],
            'title': issue['title'],
            'body': issue.get('body', ''),
            'state': issue['state'],
            'labels': [label['name'] for label in issue.get('labels', [])],
            'assignees': [assignee['login'] for assignee in issue.get('assignees', [])],
            'creator': issue['user']['login'],
            'created_at': issue['created_at'],
            'updated_at': issue['updated_at'],
            'url': issue['html_url'],
            'repository': self.config['repository']['name'],
            'marker_location': marker_location,
            'action': 'polling_detected',
        }

    def load_state(self) -> Dict[str, Any]:
        """
        Load scanner state from file

        Returns:
            State dictionary with last_scan timestamp
        """
        state_file = Path(self.config['state']['cache_dir']) / 'scanner-state.json'

        if not state_file.exists():
            return {'last_scan': None}

        try:
            with open(state_file, 'r') as f:
                return json.load(f)
        except (json.JSONDecodeError, IOError) as e:
            self.logger.warning(f"Failed to load state file: {e}")
            return {'last_scan': None}

    def save_state(self, state: Dict[str, Any]):
        """
        Save scanner state to file

        Args:
            state: State dictionary to save
        """
        state_file = Path(self.config['state']['cache_dir']) / 'scanner-state.json'
        state_file.parent.mkdir(parents=True, exist_ok=True)

        try:
            with open(state_file, 'w') as f:
                json.dump(state, indent=2, fp=f)
        except IOError as e:
            self.logger.error(f"Failed to save state file: {e}")

    def load_processed_issues(self) -> List[int]:
        """
        Load list of already processed issue IDs

        Returns:
            List of issue IDs
        """
        processed_file = Path(self.config['state']['processed_issues_file'])

        if not processed_file.exists():
            return []

        try:
            with open(processed_file, 'r') as f:
                data = json.load(f)
                return [issue['issue_id'] for issue in data]
        except (json.JSONDecodeError, IOError) as e:
            self.logger.warning(f"Failed to load processed issues: {e}")
            return []

    def add_to_pending(self, issue_data: Dict[str, Any]):
        """
        Add issue to pending approval queue

        Args:
            issue_data: Extracted issue metadata
        """
        pending_file = Path(self.config['state']['processed_issues_file']).parent / 'pending-issues.json'
        pending_file.parent.mkdir(parents=True, exist_ok=True)

        # Load existing pending issues
        pending_issues = []
        if pending_file.exists():
            with open(pending_file, 'r') as f:
                pending_issues = json.load(f)

        # Check if already pending
        if any(p['issue_id'] == issue_data['issue_id'] for p in pending_issues):
            self.logger.debug(f"Issue #{issue_data['issue_number']} already in pending queue")
            return

        # Add to pending queue
        pending_issues.append(issue_data)

        # Write back to file
        with open(pending_file, 'w') as f:
            json.dump(pending_issues, indent=2, fp=f)

        self.logger.info(f"Added issue #{issue_data['issue_number']} to pending approval queue")

    def scan_once(self):
        """Perform a single scan cycle"""
        self.logger.info("Starting issue scan cycle")

        # Check rate limit
        if not self.check_rate_limit():
            self.logger.warning("Rate limit too low, skipping scan")
            return

        # Load state
        state = self.load_state()
        last_scan = state.get('last_scan')
        since = datetime.fromisoformat(last_scan) if last_scan else None

        # Search for issues
        issues = self.search_issues(since=since)

        if not issues:
            self.logger.info("No new issues found")
            self.save_state({'last_scan': datetime.now().isoformat()})
            return

        # Load already processed issues
        processed_ids = self.load_processed_issues()

        # Process each issue
        new_issues = 0
        for issue in issues:
            issue_data = self.extract_issue_data(issue)

            # Skip if already processed
            if issue_data['issue_id'] in processed_ids:
                self.logger.debug(f"Issue #{issue_data['issue_number']} already processed")
                continue

            # Skip if marker not actually found (false positive from search)
            if not issue_data['marker_location']:
                self.logger.debug(f"Issue #{issue_data['issue_number']} no marker found (false positive)")
                continue

            # Add to pending queue
            self.add_to_pending(issue_data)
            new_issues += 1

        self.logger.info(f"Scan complete: {new_issues} new issues added to pending queue")

        # Update state
        self.save_state({'last_scan': datetime.now().isoformat()})

    def run_continuous(self):
        """Run scanner in continuous polling mode"""
        interval_minutes = self.config['polling']['interval']
        self.logger.info(f"Starting continuous scanner (interval: {interval_minutes} minutes)")

        while True:
            try:
                self.scan_once()
            except Exception as e:
                self.logger.error(f"Scan cycle failed: {e}", exc_info=True)

            # Sleep until next cycle
            sleep_seconds = interval_minutes * 60
            self.logger.info(f"Next scan in {interval_minutes} minutes")
            time.sleep(sleep_seconds)


def main():
    """Entry point for issue scanner"""
    # Check for config file path argument
    config_path = sys.argv[1] if len(sys.argv) > 1 else 'config.yaml'

    # Check for mode argument
    mode = sys.argv[2] if len(sys.argv) > 2 else 'once'

    try:
        scanner = IssueScanner(config_path)

        if mode == 'continuous':
            scanner.run_continuous()
        else:
            scanner.scan_once()

    except Exception as e:
        print(f"ERROR: Scanner failed: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
