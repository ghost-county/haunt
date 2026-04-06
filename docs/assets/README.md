# Haunt Framework Visual Diagrams

This directory contains visual workflow diagrams for the Haunt framework.

## Diagrams

### 1. Séance Workflow Infographic (`seance-workflow.mmd`)

**Purpose:** Shows the complete séance workflow from idea to roadmap creation.

**Phases:**
- Phase 1: Requirements Development (JTBD extraction, acceptance criteria)
- Phase 2: Requirements Analysis (Kano, RICE, complexity estimation)
- Phase 3: Roadmap Creation (REQ-XXX items, sizing, agent assignment)

**Referenced in:** `Haunt/README.md`

### 2. Agent Coordination Diagram (`agent-coordination.mmd`)

**Purpose:** Shows how agents coordinate via roadmap status updates.

**Key Elements:**
- Agent roles: PM, Dev, Code Reviewer, Release Manager
- Roadmap as communication layer
- Status transitions: ⚪ → 🟡 → 🟢
- Task checkbox updates
- Implementation notes sharing

**Referenced in:** `Haunt/docs/WHITE-PAPER.md`

### 3. Session Startup Protocol Diagram (`session-startup.mmd`)

**Purpose:** Shows session startup sequence and assignment lookup priority.

**Key Steps:**
1. Environment verification (pwd, git status)
2. Test validation (run tests, fix if failing)
3. Assignment lookup (priority order: Direct → Active Work → Roadmap → Ask PM)

**Referenced in:** `Haunt/SETUP-GUIDE.md`

## File Formats

- `.mmd` - Mermaid diagram source (text-based, version-controllable)
- `.html` - Standalone HTML files that render diagrams via Mermaid.js CDN

## Viewing Diagrams

### Option 1: Open HTML Files Locally
```bash
open Haunt/docs/assets/seance-workflow.html
open Haunt/docs/assets/agent-coordination.html
open Haunt/docs/assets/session-startup.html
```

### Option 2: View Mermaid Source in GitHub
GitHub automatically renders `.mmd` files as diagrams in the web UI.

### Option 3: Use Mermaid Live Editor
1. Copy `.mmd` file contents
2. Paste into https://mermaid.live
3. Export as SVG or PNG if needed

## Updating Diagrams

To update a diagram:
1. Edit the `.mmd` source file
2. Open corresponding `.html` file in browser to preview
3. If satisfied, commit changes to `.mmd` file
4. GitHub will auto-render updated diagram

## Implementation Notes

**REQ-228, REQ-229, REQ-230:** Visual Workflow Diagrams (Phase 1 Quick Wins)
- Diagrams created using Mermaid.js for maintainability
- HTML files use CDN for Mermaid rendering (no build step required)
- All diagrams use consistent color scheme and styling
