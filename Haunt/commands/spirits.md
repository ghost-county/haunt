# Spirits (Active Agent Status)

Display the status of all active spirits (background agents) in the current haunting session.

## Check Spirit Status

Use the `/tasks` command or check AgentOutputTool to see:

1. **Running spirits**: Agents still processing
2. **Completed spirits**: Agents that have returned from the void
3. **Failed spirits**: Agents that encountered issues

### Spirit Management

- **Check status**: `AgentOutputTool(agentId="...", block=false)`
- **Wait for spirit**: `AgentOutputTool(agentId="...", block=true)`
- **Banish spirit**: `KillShell(shell_id="...")`

### Tips

- Spirits run in isolated contexts
- Each spirit returns a single result message
- Use `/seance` to spawn multiple spirits in parallel
- Long-running spirits should use `run_in_background: true`

List all active spirits and their current status.
