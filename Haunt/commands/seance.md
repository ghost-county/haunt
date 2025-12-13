# Conduct Seance (Workflow Orchestration)

Hold a séance to guide ideas through the complete Ghost County workflow: from vision to requirements to roadmap, then optionally summon worker spirits for implementation.

## What is a Seance?

A séance is Ghost County's primary workflow orchestration ritual. It:

1. **Detects context** - New project or existing project
2. **Guides planning** - Full or incremental idea-to-roadmap workflow
3. **Prompts for summoning** - Optionally spawns worker agents after planning

## Task: $ARGUMENTS

Invoke the `gco-seance` skill with the user's request:

```
$ARGUMENTS
```

The skill will:
- Detect whether `.haunt/` exists (new vs existing project)
- Load `gco-project-manager` with appropriate context
- Execute idea-to-roadmap workflow
- Present themed summoning prompt after planning
- Spawn agents if user confirms

## Example Usage

```
/seance Build a task management app
/seance Add OAuth login support
/seance Fix the authentication bug and add tests
```

The séance adapts to your project context and guides you through structured planning before any code is written.

## See Also

- `/summon <agent> <task>` - Directly spawn a specific agent
- `/haunting` - View current active work
- `/divine <topic>` - Research a topic
