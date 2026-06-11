# Writing Concise Standards

Standards are injected into LLM context at runtime. Every word costs tokens. Target ≤30 lines per file. The format below is calibration — match it, don't transcend it.

## Rules

- **Lead with the rule.** State what to do first. Rationale second (if non-obvious).
- **Show, don't tell.** Code example beats prose.
- **Skip the obvious.** Don't document what the code already makes clear.
- **One concept per file.** Don't bundle unrelated patterns.
- **Bullets over paragraphs.** Scannable beats readable.

---

## Good

```markdown
# API Response Envelope

All API responses use this envelope.

\`\`\`json
{ "success": true, "data": { ... } }
{ "success": false, "error": { "code": "AUTH_001", "message": "..." } }
\`\`\`

- Never return raw data without the envelope
- Error responses must include both `code` and `message`
- Success responses omit the `error` field entirely
- Log full error server-side, return safe message to client
```

**Why it works:** 11 lines. Rule stated upfront. Code example shows both shapes. Bullets cover the non-obvious constraints. No paragraph filler.

---

## Bad

```markdown
# Error Handling Guidelines

When an error occurs in our application, we have established a consistent
pattern for how errors should be formatted and returned to the client. This
helps maintain consistency across our API surface and makes it easier for
frontend developers to handle errors appropriately and display the right
information to end users.

The pattern was originally established during the initial API design phase
back in 2024 when we were building out the user authentication module. At
that point, we evaluated several different approaches including the JSON:API
specification, GraphQL-style error blocks, and a custom format. We settled
on the envelope pattern because it provides a clean separation between
success and failure responses while keeping the response structure
predictable for clients...

[continues for 3 more paragraphs]
```

**Why it fails:** Paragraphs instead of rules. History lesson instead of guidance. The reader has to extract the actual standard from prose. Token cost is ~3-4x higher than necessary. Agents will skim and miss the rule.

---

## Format Template

```markdown
# {Standard Title}

{One-sentence rule statement.}

\`\`\`{language}
{minimal example showing the pattern}
\`\`\`

- {Constraint or edge case 1}
- {Constraint or edge case 2}
- {Constraint or edge case 3 — with why if non-obvious}
```

That's the entire template. Three sections: rule, example, bullets. Anything more is bloat unless the pattern genuinely requires it.
