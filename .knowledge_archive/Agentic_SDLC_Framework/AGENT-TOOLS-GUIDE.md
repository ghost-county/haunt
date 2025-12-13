# Agent Tool Configuration Guide

## Purpose

Agent tool configuration is critical for operational success in the Agentic SDLC framework. When agents lack the tools required for their documented responsibilities, they experience runtime failures that block work execution. This guide ensures every agent has appropriate tools aligned with their role.

**Core Principle:** If an agent's responsibilities include creating or modifying files, that agent MUST have Write/Edit tools configured.

---

## Agent Categories

### 1. Dev Agents

**Examples:** Dev-Backend, Dev-Frontend, Dev-Infrastructure, TDD-Coder

**Responsibilities:**
- Implement features per roadmap assignments
- Write and modify code files
- Create and update test files
- Update configuration files
- Modify documentation files
- Commit changes with proper messages

**Required Tools:**
- **Read** - Read existing code, tests, configuration files
- **Write** - Create new files (initial implementations, new tests)
- **Edit** - Modify existing files (feature additions, bug fixes)
- **Bash** - Run tests, execute build commands, git operations
- **TodoWrite** - Track implementation progress
- **Glob** - Find files by pattern (locate test files, config files)
- **Grep** - Search code for patterns (find function definitions, usages)

**Optional Tools:**
- **mcp__context7__*** - Look up library documentation
- **mcp__agent_memory__*** - Persist learnings between sessions
- **mcp__agent_chat__*** - Coordinate with other agents

**Rationale:** Dev agents are the primary file creators/modifiers in the system. They must be able to read existing code (Read), create new files (Write), modify existing files (Edit), run commands (Bash), and search the codebase (Grep/Glob). Without these tools, they cannot perform their core responsibilities.

---

### 2. Research Agents

**Examples:** Research-Analyst, Research-Critic

**Responsibilities:**
- Investigate questions and gather evidence
- Search for documentation and references
- Validate findings from other agents
- Provide citations and confidence levels
- Synthesize research into reports

**Required Tools:**
- **Read** - Read existing research, documentation
- **Grep** - Search within files for specific content
- **Glob** - Find files matching patterns
- **WebSearch** - Search the internet for information
- **WebFetch** - Retrieve web pages for analysis

**Optional Tools:**
- **Write** - Create standalone research reports (if output to files)
- **mcp__context7__*** - Access official library documentation
- **mcp__agent_memory__*** - Remember past research findings
- **mcp__agent_chat__*** - Coordinate research efforts

**Rationale:** Research agents primarily consume information rather than create files. Their core tools focus on search and retrieval (WebSearch, WebFetch, Grep). Write tool becomes required only if research outputs are saved to files rather than returned directly.

---

### 3. Quality Agents

**Examples:** Code-Reviewer, Release-Manager

**Responsibilities:**
- Review code submissions
- Verify test coverage and passage
- Check against anti-patterns
- Run integration tests
- Manage merge sequences
- Maintain changelog

**Required Tools:**
- **Read** - Review code, tests, documentation
- **Grep** - Search for patterns, anti-patterns
- **Glob** - Find all files in a changeset
- **Bash** - Run test suites, execute git commands
- **TodoWrite** - Track review/merge tasks

**Optional Tools:**
- **Edit** - Apply minor fixes during review (format, style)
- **Write** - Update changelog, create review reports
- **mcp__agent_memory__*** - Remember past review decisions
- **mcp__agent_chat__*** - Coordinate with developers

**Rationale:** Quality agents primarily read and validate rather than create. They need Read for code inspection, Bash for running tests and git operations, and Grep/Glob for searching. Write/Edit become necessary if they maintain changelog files or create review documentation.

---

### 4. Coordinator Agents

**Examples:** Project-Manager, Business-Analyst

**Responsibilities:**
- Create roadmap documents
- Write planning documents
- Generate analysis reports
- Update requirement specifications
- Maintain feature contracts
- Create batch execution plans

**Required Tools:**
- **Read** - Read existing plans, requirements, specifications
- **Write** - Create new roadmaps, plans, analysis documents
- **Edit** - Update existing roadmaps, mark phases complete
- **TodoWrite** - Track planning tasks
- **Grep** - Search existing documents for context
- **Glob** - Find related planning documents

**Optional Tools:**
- **Bash** - Git operations for committing plans (if needed)
- **mcp__agent_memory__*** - Remember planning decisions
- **mcp__agent_chat__*** - Coordinate with all agent types

**Rationale:** Coordinator agents are documentation-heavy. They constantly create (Write) and update (Edit) planning documents, roadmaps, and analysis reports. These agents MUST have Write/Edit or they cannot fulfill their core responsibilities of maintaining project documentation.

---

## Tool Selection Rules

### Rule 1: Document Creation → Write Tool Required
If an agent's responsibilities include creating new documents, the agent MUST have the Write tool.

**Examples:**
- Business-Analyst creating Feature-to-Value-Chain Reports → Needs Write
- Project-Manager creating roadmap.md → Needs Write
- Requirements-Reviewer creating requirements documents → Needs Write

### Rule 2: Document Modification → Edit Tool Required
If an agent updates existing files (marking tasks complete, updating status), the agent MUST have the Edit tool.

**Examples:**
- Project-Manager marking phases complete in roadmap.md → Needs Edit
- Dev agents modifying existing code → Needs Edit
- Business-Analyst updating analysis reports → Needs Edit

### Rule 3: Command Execution → Bash Tool Required
If an agent runs tests, builds, git operations, or any shell commands, the agent MUST have the Bash tool.

**Examples:**
- Dev agents running test suites → Needs Bash
- Quality agents running integration tests → Needs Bash
- Release-Manager executing git merge operations → Needs Bash

### Rule 4: File Search → Grep/Glob Tools Required
If an agent needs to find files or search within files, the agent MUST have Grep (content search) and/or Glob (pattern matching).

**Examples:**
- Dev agents finding test files → Needs Glob
- Research agents searching documentation → Needs Grep
- Code-Reviewer finding anti-patterns → Needs Grep

### Rule 5: Web Research → WebSearch/WebFetch Tools Required
If an agent gathers information from the internet, the agent MUST have WebSearch and WebFetch tools.

**Examples:**
- Research-Analyst investigating questions → Needs WebSearch, WebFetch
- Requirements-Reviewer validating best practices → Needs WebSearch

### Rule 6: Task Tracking → TodoWrite Tool Recommended
All agents benefit from TodoWrite for tracking multi-step workflows, but it's most critical for agents with complex, multi-phase responsibilities.

**Examples:**
- Dev agents tracking implementation steps → TodoWrite recommended
- Project-Manager tracking batch execution → TodoWrite recommended

---

## Audit Results

### Agents Audited (7 Total)

#### Repository: Knowledge/AgenticSDLC - Multiverse Curriculum/Agents

1. **Business-Analyst.md** ✅ Tools Properly Configured
2. **Project-Manager-Agent.md** ⚠️ Missing Write/Edit Tools (CRITICAL)
3. **TDD-Coder.md** ⚠️ No Tools Specified (CRITICAL)
4. **Dependency-Analyzer.md** ⚠️ No Tools Specified
5. **Interface-Contract.md** ⚠️ No Tools Specified
6. **requirements-reviewer.md** ✅ Tools Properly Configured
7. **value_chain_expert.md** ⚠️ Missing Write/Edit Tools (CRITICAL)

#### Repository: Agentic_SDLC_Framework
- **03-Agent-Definitions.md** - Documentation only (contains agent templates, not actual agent files)
- **agents/** directory - Empty (no agent files yet)

---

## Mismatches Found

### CRITICAL Issues (Block Agent Functionality)

#### 1. Project-Manager-Agent.md
**Current Tools:** `mcp__agent_chat__*, mcp__agent_memory__*`

**Documented Responsibilities:**
- Create roadmap in `plans/roadmap.md`
- Create detailed plans in `plans/[feature]-plan.md`
- Update roadmap (mark phases complete, archive)
- Create and maintain `completed/roadmap-archive.md`

**Problem:** Agent must create and update multiple markdown files but lacks Write/Edit tools.

**Impact:** Runtime failure when attempting to create roadmap.md or update status.

**Fix Required:** Add Write, Edit, Read, TodoWrite, Grep, Glob tools.

---

#### 2. TDD-Coder.md
**Current Tools:** None specified in frontmatter

**Documented Responsibilities:**
- Write tests (create .test.ts files)
- Implement code (create/modify source files)
- Run tests (execute npm test, pytest)
- Commit changes (git operations)
- Write dev log entries (create/update docs/dev-log.md)
- Update roadmap (edit plans/roadmap.md)

**Problem:** Agent has extensive file creation/modification responsibilities but NO tools configured.

**Impact:** Complete operational failure - agent cannot perform any of its core functions.

**Fix Required:** Add Read, Write, Edit, Bash, TodoWrite, Grep, Glob tools (full Dev Agent toolset).

---

#### 3. value_chain_expert.md
**Current Tools:** `mcp__agent_chat__*, mcp__agent_memory__*`

**Documented Responsibilities:**
- Create Feature-to-Value-Chain Reports (markdown output)
- Document strategic analysis
- Generate recommendation summaries

**Problem:** Agent must create markdown analysis documents but lacks Write tool.

**Impact:** Cannot save analysis reports to files, limiting utility.

**Fix Required:** Add Write, Read, Edit, TodoWrite tools.

---

### MEDIUM Issues (Functionality Degraded)

#### 4. Dependency-Analyzer.md
**Current Tools:** None specified

**Documented Responsibilities:**
- Create dependency graphs
- Identify parallelization groups
- Document work streams

**Problem:** Output format not specified - unclear if results are returned directly or saved to files.

**Impact:** If output should be saved to files, agent cannot do so without Write tool.

**Fix Required:** If outputs to files: Add Write, Read tools. Otherwise: Add Read, Grep, Glob tools for analyzing requirements.

---

#### 5. Interface-Contract.md
**Current Tools:** None specified

**Documented Responsibilities:**
- Define API contracts
- Create OpenAPI specs or TypeScript interfaces
- Document endpoint schemas

**Problem:** Output format suggests file creation (OpenAPI spec, .ts files) but no Write tool.

**Impact:** Cannot save contract definitions to files.

**Fix Required:** Add Write, Read, Edit tools (contracts are files that get modified).

---

## Fixes Applied

### 1. Business-Analyst.md - No Changes Needed
**Status:** Already has proper tools configured.
**Tools:** Glob, Grep, Read, Edit, Write, TodoWrite, mcp__agent_chat__*, mcp__agent_memory__*
**Rationale:** Correctly configured for Coordinator agent creating analysis documents.

### 2. Project-Manager-Agent.md - Fix Required
**Action:** Add Write, Edit, Read, TodoWrite, Grep, Glob tools to frontmatter.
**File:** `/Users/heckatron/github_repos/Claude/Knowledge/AgenticSDLC - Multiverse Curriculum/Agents/Project-Manager-Agent.md`

### 3. TDD-Coder.md - Fix Required
**Action:** Add full Dev Agent toolset: Read, Write, Edit, Bash, TodoWrite, Grep, Glob, mcp__context7__*
**File:** `/Users/heckatron/github_repos/Claude/Knowledge/AgenticSDLC - Multiverse Curriculum/Agents/TDD-Coder.md`

### 4. value_chain_expert.md - Fix Required
**Action:** Add Write, Edit, Read, TodoWrite tools to frontmatter.
**File:** `/Users/heckatron/github_repos/Claude/Knowledge/AgenticSDLC - Multiverse Curriculum/Agents/value_chain_expert.md`

### 5. Dependency-Analyzer.md - Fix Required
**Action:** Add Read, Write, Grep, Glob tools (assuming output to files).
**File:** `/Users/heckatron/github_repos/Claude/Knowledge/AgenticSDLC - Multiverse Curriculum/Agents/Dependency-Analyzer.md`

### 6. Interface-Contract.md - Fix Required
**Action:** Add Write, Edit, Read, Grep tools for creating contract files.
**File:** `/Users/heckatron/github_repos/Claude/Knowledge/AgenticSDLC - Multiverse Curriculum/Agents/Interface-Contract.md`

### 7. requirements-reviewer.md - No Changes Needed
**Status:** Already has comprehensive tools configured.
**Tools:** Glob, Grep, Read, Edit, Write, NotebookEdit, WebFetch, TodoWrite, WebSearch, BashOutput, Skill, SlashCommand, mcp__*
**Rationale:** Properly configured for documentation-heavy agent.

---

## Standard Tool Sets by Category

### Dev Agent Standard Toolset
```yaml
tools: Read, Write, Edit, Bash, TodoWrite, Grep, Glob, mcp__context7__*, mcp__agent_memory__*, mcp__agent_chat__*
```

**Use for:** Dev-Backend, Dev-Frontend, Dev-Infrastructure, TDD-Coder

---

### Research Agent Standard Toolset
```yaml
tools: Read, Grep, Glob, WebSearch, WebFetch, mcp__context7__*, mcp__agent_memory__*, mcp__agent_chat__*
```

**Optional additions:** Write, Edit (if creating research report files)

**Use for:** Research-Analyst, Research-Critic

---

### Quality Agent Standard Toolset
```yaml
tools: Read, Grep, Glob, Bash, TodoWrite, mcp__agent_memory__*, mcp__agent_chat__*
```

**Optional additions:** Write, Edit (if maintaining changelog or review reports)

**Use for:** Code-Reviewer, Release-Manager

---

### Coordinator Agent Standard Toolset
```yaml
tools: Read, Write, Edit, TodoWrite, Grep, Glob, mcp__agent_memory__*, mcp__agent_chat__*
```

**Optional additions:** Bash (if committing planning documents via git)

**Use for:** Project-Manager, Business-Analyst, Requirements-Reviewer

---

## Future Agent Checklist

When creating new agents, use this checklist to ensure proper tool configuration:

1. **Identify Agent Category:** Dev, Research, Quality, or Coordinator?
2. **List Responsibilities:** What files will this agent create/modify?
3. **Apply Tool Selection Rules:**
   - Creates files? → Add Write
   - Modifies files? → Add Edit
   - Reads files? → Add Read
   - Runs commands? → Add Bash
   - Searches files? → Add Grep/Glob
   - Web research? → Add WebSearch/WebFetch
   - Tracks tasks? → Add TodoWrite
4. **Use Standard Toolset:** Start with category's standard toolset, then customize.
5. **Verify Against Responsibilities:** Ensure every documented responsibility has corresponding tool.
6. **Test Runtime:** Assign agent a task requiring each tool to verify configuration.

---

## Tool Configuration Format

All agents use YAML frontmatter for tool configuration:

```yaml
---
name: Agent-Name
description: Brief description of when to use this agent
tools: Read, Write, Edit, Bash, TodoWrite, Grep, Glob, mcp__context7__*, mcp__agent_memory__*, mcp__agent_chat__*
model: sonnet
color: green
---
```

**Wildcard Pattern:** Use `mcp__namespace__*` to grant access to all tools in an MCP namespace.

**Common MCP Namespaces:**
- `mcp__context7__*` - Library documentation lookup
- `mcp__agent_memory__*` - Persistent memory across sessions
- `mcp__agent_chat__*` - Inter-agent communication

---

## References

- [Claude Code Tool Documentation](https://docs.anthropic.com/claude/docs/tool-use)
- [Agentic SDLC Agent Architecture](./03-Agent-Definitions.md)
- [One-Feature-Per-Session Rule](./05-Operations.md)

---

**Document Version:** 1.0
**Last Updated:** 2025-12-09
**Next Review:** After Batch 1 completion (7 skill extractions)
