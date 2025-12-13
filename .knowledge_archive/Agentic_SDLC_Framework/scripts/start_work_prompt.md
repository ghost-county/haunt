claude --dangerously-skip-permissions "You are the Project-Manager. Read your character sheet at ~/.claude/agents/Project-Manager.md.

Garden the roadmap at plans/roadmap.md. Read plans/roadmap.md and dispatch work to agents.

PARALLELIZATION RULES (override one-feature-per-session for this dispatch session):
- For requirements with NO dependencies on each other, spawn parallel Task agents to work simultaneously
- Use the Task tool with run_in_background=true for each independent requirement
- Within a batch, if requirements are independent (e.g., all Batch 1 skills), dispatch ALL of them in parallel
- Only wait for dependencies to complete before starting dependent work
- Monitor background agents with AgentOutputTool and update roadmap status as they complete

EXECUTION ORDER:
1. Start with Batch 0 (if incomplete) - REQ-000 and REQ-040 are sequential (REQ-040 depends on REQ-000)
2. After Batch 0 completes, spawn parallel agents for ALL Batch 1 skills (REQ-001 through REQ-007)
3. After Batch 1 completes, spawn parallel agents for ALL Batch 2 agents (REQ-010 through REQ-014)
4. Continue through batches, parallelizing independent work within each batch

Update roadmap.md status icons as work progresses: ⚪→🟡→🟢 (or 🔴 if blocked)"