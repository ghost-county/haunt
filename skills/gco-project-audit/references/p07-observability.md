# P7: The Observability Imperative

> "If you can't see inside your pipeline, you're trusting it on faith."

Source: [JD Forsythe — 10 Claude Code Principles](https://jdforsythe.github.io/10-principles/principles/observability/)

## Audit Criteria

### What to Check

1. **Tool call logging** — Is every tool call logged with inputs, outputs, and duration?
2. **Structured format** — Are logs JSON (queryable), not printf (archaeology)?
3. **Model version tracking** — Are model version, temperature, and system prompt hash logged per LLM call?
4. **Artifact hashing** — Are artifacts hashed at handoff points to detect message loss?
5. **Review metrics** — Are approval latency and content logged for review steps?
6. **Input + output logging** — Are both sides of every interaction logged? (Outputs without inputs = impossible diagnosis)
7. **Pipeline viewer** — Is there a tool to read logs and print the artifact chain?

### Scoring

| Rating | Criteria |
|--------|----------|
| Strong | Structured JSON logging at all boundaries; artifact hashing; review metrics; pipeline viewer |
| Partial | Some logging but unstructured; missing handoff hashing; no review metrics |
| Weak | Printf-style logging; outputs only; no structured format |
| Missing | Black box pipeline; no logging infrastructure |

### Common Violations

- No logging at all (black box pipeline)
- Unstructured text logs (grep expeditions, not database queries)
- Logging outputs but not inputs (can't diagnose why bad output was produced)
- No review approval metrics (rubber-stamp pattern invisible)
- Logging too much (signal buried in noise) — log at boundaries, not internals
- No artifact hashing at handoffs (message loss undetectable)

### MAST Failure Modes (Detectable Only Through Observability)

| ID | Failure Mode | Detection Method |
|----|-------------|-----------------|
| FM-1.1 | Message Loss | Hash handoff payloads; confirm receipt |
| FM-1.4 | Stale Context | Timestamp all context; compare at handoffs |
| FM-3.1 | Rubber-Stamp Approval | Log approval latency + content; flag <5s approvals |
| FM-3.2 | Error Cascading | Hash artifact chains; trace backward from failure |

### Key Metric

> Review approval rate and latency. If >85% approval in <5 seconds, you have a rubber stamp.

### Log Entry Format

```json
{
  "event": "tool_call",
  "agent": "implementer",
  "tool": "file_write",
  "input": {"path": "src/auth.ts", "content_hash": "a1b2c3"},
  "output": {"success": true, "bytes_written": 1847},
  "duration_ms": 34,
  "timestamp": "2026-03-28T14:32:08.441Z"
}
```
