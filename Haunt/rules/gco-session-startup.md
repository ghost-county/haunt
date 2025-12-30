# Session Startup: Targeted File Access

## Principle

**Use targeted tools (grep, head) instead of full file reads when you only need specific information.**

## Assignment Lookup Protocol

When finding your assignment during session startup:

### Priority 3: Check Roadmap (Use Targeted Read)

**WRONG:**
```bash
Read(.haunt/plans/roadmap.md)  # Reads 1,647 lines
```

**RIGHT:**
```bash
# If looking for specific requirement:
grep -A 30 "REQ-XXX" .haunt/plans/roadmap.md  # ~30 lines

# If looking for your agent type's assignments:
grep -B 5 "Agent: Dev-Backend" .haunt/plans/roadmap.md  # Shows assignments + context

# If checking for ⚪ Not Started items:
grep "^###.*⚪" .haunt/plans/roadmap.md  # Lists all unstarted requirements
```

## Requirement Details Extraction

**When you have a REQ-XXX assignment, extract only that requirement:**

```bash
# Extract specific requirement (saves 1,600+ lines)
grep -A 30 "REQ-261" .haunt/plans/roadmap.md

# Get tasks section:
grep -A 15 "Tasks:" .haunt/plans/roadmap.md | grep -A 15 "REQ-261"

# Check completion criteria:
grep -A 5 "Completion:" .haunt/plans/roadmap.md | grep -A 5 "REQ-261"
```

## Configuration Access

**When checking environment or configuration:**

```bash
# WRONG: Read entire .env
Read(.env)  # 84 lines

# RIGHT: Extract specific variables
grep -E "DATABASE_URL|API_KEY|NODE_ENV" .env  # ~3 lines
```

## When to Use Full Read

Use `Read()` tool when:
- File is small (<100 lines)
- Need complete overview (new file, major refactor)
- Need to understand entire structure

## Token Savings

| Scenario | Full Read | Targeted Read | Savings |
|----------|-----------|---------------|---------|
| Find assignment in roadmap | 1,647 lines | 30 lines | 98% |
| Check REQ status | 1,647 lines | 30 lines | 98% |
| Get config values | 84 lines | 5 lines | 94% |
| Preview source file | 500 lines | 50 lines | 90% |

**Impact:** Targeted reads during session startup can save 1,500-1,600 tokens per session.
