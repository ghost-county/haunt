#!/usr/bin/env python3
"""
Archive completed roadmap items to reduce file size.
Moves all 🟢 (completed) requirements to the archive file.
"""

import re
import sys
from datetime import datetime
from pathlib import Path

ROADMAP_PATH = Path(".sdlc/plans/roadmap.md")
ARCHIVE_PATH = Path(".sdlc/completed/roadmap-archive.md")

def main():
    if not ROADMAP_PATH.exists():
        print(f"Error: {ROADMAP_PATH} not found")
        sys.exit(1)

    content = ROADMAP_PATH.read_text()

    # Find all requirement sections (### 🟢 REQ-XXX or ### ⚪ REQ-XXX etc.)
    # Each requirement starts with ### and ends before the next ### or ---
    req_pattern = r'(### [🟢⚪🟡🔴] REQ-\d+:.*?)(?=\n### |\n---|\Z)'

    completed = []
    active = []

    matches = re.findall(req_pattern, content, re.DOTALL)

    for match in matches:
        if '### 🟢' in match:
            completed.append(match.strip())
        else:
            active.append(match.strip())

    print(f"Found {len(completed)} completed requirements")
    print(f"Found {len(active)} active requirements")

    if not completed:
        print("No completed requirements to archive")
        return

    # Add new completed items to archive
    today = datetime.now().strftime("%Y-%m-%d")
    new_archive = f"\n\n## Archived {today}\n\n"
    new_archive += "\n\n---\n\n".join(completed)

    # Append to archive
    ARCHIVE_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(ARCHIVE_PATH, "a") as f:
        f.write(new_archive)

    print(f"Archived {len(completed)} requirements to {ARCHIVE_PATH}")

    # Now rebuild the roadmap with only active items
    # Keep the header section (everything before first ### REQ-)
    header_match = re.search(r'^(.*?)(?=### [🟢⚪🟡🔴] REQ-)', content, re.DOTALL)
    if header_match:
        header = header_match.group(1)
    else:
        header = "# Project Roadmap\n\n"

    # Find the footer (everything after the last requirement and before END OF ROADMAP)
    footer = "\n\n---\n\n**END OF ROADMAP**\n"

    # Build new roadmap
    new_roadmap = header
    new_roadmap += "\n\n---\n\n".join(active)
    new_roadmap += footer

    # Write new roadmap
    ROADMAP_PATH.write_text(new_roadmap)

    new_lines = new_roadmap.count('\n')
    print(f"New roadmap size: {new_lines} lines")

if __name__ == "__main__":
    main()
