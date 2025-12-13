# Summon Agent

Spawn a Ghost County agent to handle a specific task. The spirit will execute autonomously and return with results.

## Task: $ARGUMENTS

Analyze the task and determine the appropriate agent type:

- **gco-dev** (via Dev-Backend/Dev-Frontend/Dev-Infrastructure): Code implementation, tests, features
- **gco-research** (via Research-Analyst): Investigation, documentation, analysis
- **gco-project-manager** (via Project-Manager-Agent): Planning, roadmap updates, coordination
- **gco-code-reviewer**: Code review, quality checks

Spawn the agent using the Task tool with appropriate subagent_type and provide clear instructions based on the user's request.

Remember: GCO agents should only spawn other GCO agents to maintain namespace isolation.
