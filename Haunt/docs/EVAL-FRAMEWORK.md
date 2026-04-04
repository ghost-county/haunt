# Haunt Eval Framework

Structural golden task validation for the Haunt toolkit.

## What It Is

A lightweight eval suite that verifies Haunt's harness infrastructure is intact after changes to agents, skills, hooks, or scripts. Each scenario is a shell script that checks file existence, deployment state, and script correctness — not Claude output quality.

**Structural evals catch:**
- Missing or undeployed agent definitions
- Broken hook syntax after edits
- Setup regressions (skills/commands not deployed)
- Completion gate logic regressions

**Structural evals do NOT catch:**
- LLM output quality degradation
- Agent reasoning or instruction-following changes
- Prompt engineering regressions

## How to Run

```bash
# Run all scenarios
bash Haunt/tests/eval/run-evals.sh

# Run a specific scenario by name filter
bash Haunt/tests/eval/run-evals.sh scrying
bash Haunt/tests/eval/run-evals.sh xs-solo
bash Haunt/tests/eval/run-evals.sh completion-gate
```

Exit code is 0 if all scenarios pass, non-zero if any fail.

## Scenarios

| File | What It Tests |
|------|---------------|
| `scenario-xs-solo.sh` | Solo-mode seance infrastructure: agent, hooks, setup script, CLAUDE.md |
| `scenario-completion-gate.sh` | Completion gate: syntax validity, stale verification rejection, fresh acceptance |
| `scenario-scrying.sh` | Planning phase: PM agent, requirements/task skills, seance command — source and deployed |

## Adding New Scenarios

1. Create `Haunt/tests/eval/scenario-{name}.sh`
2. Source the shared helpers and follow the pattern:

```bash
#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
source "$(dirname "${BASH_SOURCE[0]}")/eval-lib.sh"

echo "Scenario: My Scenario Name"

# Use check_file, check_exec, check_syntax from eval-lib.sh
check_file "some file exists" "$REPO_ROOT/path/to/file"
check_exec "script is executable" "$REPO_ROOT/path/to/script.sh"
check_syntax "script has valid syntax" "$REPO_ROOT/path/to/script.sh"

# For custom conditions, use check() with eval (less preferred)
check "custom check" "[[ -d '$REPO_ROOT/some/dir' ]]"

report_results
```

3. Make it executable: `chmod +x Haunt/tests/eval/scenario-{name}.sh`
4. Run `bash Haunt/tests/eval/run-evals.sh` to verify it runs

Rules:
- Must exit 0 on success, non-zero on failure
- Must clean up any temp files (use `trap cleanup EXIT`)
- Must complete in < 5 seconds
- Must not invoke Claude or make network calls

## What It Does NOT Do

This framework does **not** invoke Claude. Testing actual LLM output quality requires running real seance sessions and scoring outputs against rubrics — expensive and non-deterministic. That is a future enhancement (LLM-graded evals).

Current scope: verify the harness that surrounds Claude is intact, so changes to hooks, agents, and skills don't silently break the framework.

## Philosophy

The seance is a multi-phase workflow with many moving parts: agents, hooks, skills, commands, and deployment scripts. Any of these can break silently when edited. Structural evals provide a fast, cheap regression check:

- **Run before and after major changes** to catch regressions immediately
- **Run in CI** to prevent broken deployments from reaching users
- **Run after `setup-haunt.sh`** to confirm deployment succeeded

Think of it as a smoke test for the toolkit itself.
