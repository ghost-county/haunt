# Gather the Coven (Multi-Agent Coordination)

Gather the coven to coordinate multiple agents working in parallel on the same complex task. Use when a single feature requires diverse expertise or when parallel work streams will speed completion.

## What is a Coven?

A coven is Ghost County's pattern for multi-agent parallel coordination. It:

1. **Analyzes the task** - Determines if parallel work is appropriate
2. **Defines contracts** - Establishes shared interfaces before spawning
3. **Spawns coordinated agents** - Multiple spirits working in concert
4. **Manages integration** - Brings parallel streams together

## Task: $ARGUMENTS

Invoke the `gco-coven-mode` skill with the user's request:

```
$ARGUMENTS
```

The skill will:
- Analyze whether the task suits parallel execution
- Identify which domains are involved (backend, frontend, infrastructure, etc.)
- Define integration contracts (API specs, interfaces, file ownership)
- Spawn appropriate agents with coordinated scopes
- Monitor progress and facilitate integration
- Aggregate results into unified completion

## When to Use Coven vs Seance

| Use `/seance` when: | Use `/coven` when: |
|---------------------|-------------------|
| Starting new project | Implementing existing complex task |
| Planning features | Executing across multiple domains |
| Sequential workflow | Parallel work appropriate |
| Need roadmap creation | Already have requirement in roadmap |

**Simple rule:** Seance for planning, Coven for parallel execution.

## Example Usage

```
/coven REQ-089: Real-time notifications
/coven Implement user profile feature across all layers
/coven Add authentication to backend, frontend, and infrastructure
```

## Coordination Patterns

The coven supports several coordination patterns:

- **Domain Split:** Backend + Frontend + Infrastructure working independently
- **Layer Split:** Cross-cutting changes across architectural layers
- **Feature Decomposition:** Large feature broken into parallel sub-features
- **Research + Implementation:** Parallel research and development streams

## Example Coven Session

```
User: /coven REQ-089: Real-time notifications

Response:
🌙 Gathering the coven for REQ-089...

Analyzing task:
- Backend: WebSocket server, notification queue
- Frontend: Notification UI, WebSocket client
- Infrastructure: Redis pub/sub, load balancer

✅ Suitable for parallel coven work (3 independent streams)

Defining contracts:
- WebSocket message format: { type, payload, timestamp }
- API: /api/notifications (REST), ws://api/notifications (WS)
- Redis channel: "notifications:{user_id}"

Contract saved to: .haunt/docs/integration-contracts/REQ-089.md

Ready to summon the coven?
[User confirms]

🕯️ The spirits gather...

Summoning gco-dev-backend for WebSocket server...
Summoning gco-dev-frontend for notification UI...
Summoning gco-dev-infrastructure for Redis setup...

[Agents work in parallel]
[Integration phase]
[Testing validation]

🎉 The coven has completed its work!
All changes integrated and tested.
```

## Quality Assurance

Before completing, the coven ensures:
- All parallel streams completed successfully
- No file or logical conflicts
- Integration contracts honored
- Full test suite passes
- Unified commit created

## See Also

- `/seance <feature>` - Sequential workflow orchestration (planning → implementation)
- `/summon <agent> <task>` - Spawn single agent for focused work
- `/haunting` - View current active work across all agents
