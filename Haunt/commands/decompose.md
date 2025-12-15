# Decompose (Task Decomposition)

Break down large requirements into atomic, parallelizable tasks - the decomposition ritual that transforms overwhelming work into manageable spirits.

## Invoke the Decomposition: $ARGUMENTS

### Usage

| Command | Description |
|---------|-------------|
| `/decompose REQ-XXX` | Decompose a specific requirement into atomic tasks |
| `/decompose REQ-XXX --dry-run` | Analyze and show decomposition without modifying roadmap |
| `/decompose REQ-XXX --parallel` | Focus on maximizing parallelization opportunities |

### Execution Workflow

#### Step 1: Parse Arguments

```python
import re

args = "$ARGUMENTS".strip()

# Extract REQ-XXX
req_match = re.search(r'REQ-\d+', args)
if not req_match:
    print("No requirement ID found. Usage: /decompose REQ-XXX")
    exit(1)

req_id = req_match.group(0)
dry_run = '--dry-run' in args
parallel_focus = '--parallel' in args
```

#### Step 2: Read Requirement from Roadmap

```python
roadmap_path = ".haunt/plans/roadmap.md"

# Read roadmap
with open(roadmap_path, 'r') as f:
    content = f.read()

# Find requirement section
req_pattern = f"### [^#]* {req_id}: (.+?)\\n"
match = re.search(req_pattern, content)
if not match:
    print(f"Requirement {req_id} not found in roadmap.")
    exit(1)

req_title = match.group(1)

# Extract full requirement section
req_section_start = content.find(f"### {req_id}:")
req_section_end = content.find("\n### ", req_section_start + 1)
if req_section_end == -1:
    req_section_end = content.find("\n---", req_section_start + 1)
    if req_section_end == -1:
        req_section_end = len(content)

req_section = content[req_section_start:req_section_end]

# Parse fields
effort = extract_field(req_section, "**Effort:**")
files = extract_files(req_section)
tasks = extract_tasks(req_section)
```

#### Step 3: Validate SPLIT Need

Check if decomposition is warranted:

```python
file_count = len(files)
task_count = len(tasks)
effort_value = effort.strip().upper()

split_needed = False
split_reasons = []

if effort_value == "SPLIT":
    split_needed = True
    split_reasons.append("Marked as SPLIT")

if file_count > 8:
    split_needed = True
    split_reasons.append(f"Files ({file_count}) exceed limit of 8")

if task_count > 6:
    split_needed = True
    split_reasons.append(f"Tasks ({task_count}) exceed limit of 6")

if not split_needed:
    print(f"{req_id} does not require decomposition (Effort: {effort_value}, Files: {file_count}, Tasks: {task_count})")
    print("Use --force to decompose anyway.")
    exit(0)
```

#### Step 4: Invoke Task Decomposition Skill

Load and invoke the `gco-task-decomposition` skill:

```
Invoke skill: gco-task-decomposition

Input:
- Requirement ID: {req_id}
- Title: {req_title}
- Current Effort: {effort}
- Files: {files}
- Tasks: {tasks}
- Mode: {"dry-run" if dry_run else "execute"}
- Focus: {"parallel" if parallel_focus else "standard"}
```

#### Step 5: Generate Decomposition

The skill will:
1. Analyze the requirement's natural boundaries
2. Identify dependencies between potential pieces
3. Map parallelization opportunities
4. Size each piece within limits (XS/S/M)
5. Generate dependency DAG visualization
6. Create roadmap-ready requirement format

### Output Format

**Decomposition Report:**

```
+--------------------------------------------------+
|  DECOMPOSITION RITUAL COMPLETE                   |
+--------------------------------------------------+

Original Haunting: {req_id}: {req_title}
  Effort: {original_effort}
  Files: {original_file_count}
  Tasks: {original_task_count}

Split Into: {decomposed_count} atomic hauntings

+--------------------------------------------------+
|  DEPENDENCY DAG                                   |
+--------------------------------------------------+

        {req_id}-A (Foundation)
             |
    +--------+--------+
    |                 |
{req_id}-B      {req_id}-C
(Backend)         (Models)
    |                 |
    +--------+--------+
             |
        {req_id}-D (Frontend)

+--------------------------------------------------+
|  PARALLELIZATION ANALYSIS                         |
+--------------------------------------------------+

Phase 1 (Sequential):  {req_id}-A
Phase 2 (Parallel):    {req_id}-B || {req_id}-C
Phase 3 (Sequential):  {req_id}-D

Parallelization Ratio: {ratio}%
Estimated Time Savings: {savings}

+--------------------------------------------------+
|  DECOMPOSED REQUIREMENTS                          |
+--------------------------------------------------+

{req_id}-A: {title-A}
  Effort: {size-A} | Files: {count-A} | Blocked by: None

{req_id}-B: {title-B}
  Effort: {size-B} | Files: {count-B} | Blocked by: {req_id}-A

{req_id}-C: {title-C}
  Effort: {size-C} | Files: {count-C} | Blocked by: {req_id}-A
  Note: Can run parallel with {req_id}-B

{req_id}-D: {title-D}
  Effort: {size-D} | Files: {count-D} | Blocked by: {req_id}-B, {req_id}-C

+--------------------------------------------------+
|  AGENT ASSIGNMENTS                                |
+--------------------------------------------------+

Dev-Backend: {req_id}-A, {req_id}-B, {req_id}-C ({hours} hours)
Dev-Frontend: {req_id}-D ({hours} hours)

+--------------------------------------------------+

{"[DRY RUN] No changes made to roadmap" if dry_run else "Roadmap updated with decomposed requirements"}
```

### Error Messages

**Requirement not found:**
```
+--------------------------------------------------+
|  DECOMPOSITION FAILED                             |
+--------------------------------------------------+

Cannot locate {req_id} in .haunt/plans/roadmap.md

The spirits cannot decompose what does not exist.

Verify requirement:
  cat .haunt/plans/roadmap.md | grep {req_id}

View all requirements:
  /haunting
```

**Decomposition not needed:**
```
+--------------------------------------------------+
|  DECOMPOSITION NOT REQUIRED                       |
+--------------------------------------------------+

{req_id}: {req_title}

Current Sizing:
  Effort: {effort} (within limits)
  Files: {file_count} (limit: 8)
  Tasks: {task_count} (limit: 6)

This haunting is already appropriately sized.

Force decomposition:
  /decompose {req_id} --force
```

**Circular dependency detected:**
```
+--------------------------------------------------+
|  DECOMPOSITION ERROR                              |
+--------------------------------------------------+

Circular dependency detected in decomposition!

Cycle: {req_id}-A -> {req_id}-B -> {req_id}-C -> {req_id}-A

The spirits cannot form a circle - dependencies must be acyclic.

Review the task boundaries and dependencies.
```

### Examples

**Standard decomposition:**
```
/decompose REQ-050
```

Output shows full decomposition with DAG, parallelization analysis, and updates roadmap.

**Preview decomposition without changes:**
```
/decompose REQ-050 --dry-run
```

Shows what the decomposition would look like without modifying the roadmap.

**Focus on parallelization:**
```
/decompose REQ-050 --parallel
```

Optimizes the decomposition to maximize parallel execution opportunities.

### Decomposition Strategies

The skill uses these strategies based on requirement type:

| Type | Strategy | Decomposition Pattern |
|------|----------|----------------------|
| Feature | Layer Split | DB -> Backend -> API -> Frontend |
| Refactor | Risk Isolation | Tests -> Refactor -> Dependent Code |
| Bug Fix | Minimal Split | Failing Test -> Fix -> Regression Tests |
| Research | Phase Split | Spike -> Analysis -> Recommendations |
| Infrastructure | Component Split | Network -> Compute -> Storage -> Config |

### Integration with Workflow

**During Planning:**
```
/seance Add user authentication
  -> PM creates REQ-050 (sized SPLIT)
  -> /decompose REQ-050
  -> Roadmap updated with REQ-050-A through REQ-050-F
  -> /summon dev for each piece
```

**Manual decomposition:**
```
User: "REQ-123 is too big"
  -> /decompose REQ-123 --dry-run  # Preview
  -> User approves
  -> /decompose REQ-123            # Execute
```

### After Decomposition

1. **Original requirement:** Marked as "Decomposed into REQ-XXX-A through REQ-XXX-N"
2. **New requirements:** Added to roadmap with proper dependencies
3. **DAG visualization:** Saved to `.haunt/docs/decomposition/REQ-XXX-dag.md` (optional)
4. **Ready for execution:** Use `/summon` or `/summon all` to begin work

### See Also

- `/summon` - Spawn agents to work on decomposed pieces
- `/coven` - Coordinate parallel execution of decomposed tasks
- `/haunting` - View roadmap status including decomposed items
- `Haunt/skills/gco-task-decomposition/SKILL.md` - Full decomposition methodology
- `Haunt/rules/gco-roadmap-format.md` - Sizing rules (XS/S/M/SPLIT)
