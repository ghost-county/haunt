---
last-verified: 2026-04-03
name: gco-secure-coding
description: >-
  OWASP Top 10 audit, STRIDE threat modeling, CWE classification, prompt injection prevention, and agent security patterns for production code.
  Use when building production features, reviewing auth/payments/PII code, or before deployment to public-facing environments.
---

# Secure Coding Best Practices

## Vocabulary Payload

| Term | Definition |
|------|-----------|
| OWASP Top 10 | Industry-standard list of critical web application security risks |
| STRIDE | Threat model: Spoofing, Tampering, Repudiation, Info Disclosure, DoS, Elevation |
| CWE | Common Weakness Enumeration -- standardized vulnerability classification |
| Prompt Injection | Attack where user input overrides LLM system instructions |
| XSS | Cross-Site Scripting -- injecting scripts into web pages viewed by others |
| SQL Injection | Inserting malicious SQL via unsanitized user input |
| CSRF | Cross-Site Request Forgery -- tricking users into unintended actions |
| CSP | Content Security Policy -- HTTP header controlling resource loading |
| CORS | Cross-Origin Resource Sharing -- controls cross-domain HTTP requests |
| Path Traversal | Using `../` to access files outside intended directories |
| Parameterized Query | SQL query where user input is bound as data, not code |
| Allowlist | Explicit list of permitted values (opposite of blocklist) |
| Tool Permission Boundary | READ/WRITE/EXECUTE/ADMIN categorization for agent tool access |
| PII | Personally Identifiable Information -- data requiring encryption + access control |
| Secret Rotation | Periodically replacing API keys, tokens, and credentials |
| Rate Limiting | Capping request frequency to prevent abuse and DoS |
| Output Escaping | Converting special characters to safe representations before rendering |
| Schema Validation | Verifying data structure matches expected format (Zod, Pydantic) |
| Audit Log | Immutable record of security-relevant actions for accountability |
| Blast Radius | Scope of damage if a component is compromised |

---

## Anti-Patterns / Quick Block Triggers

| Anti-Pattern | Risk | CWE |
|-------------|------|-----|
| `eval(userInput)` / `exec(code)` | Arbitrary code execution | CWE-94 |
| `f"SELECT * WHERE id = '{input}'"` | SQL injection | CWE-89 |
| `dangerouslySetInnerHTML={{ __html: raw }}` | XSS | CWE-79 |
| `globals()[tool_name](**params)` | Unrestricted tool execution | CWE-749 |
| `API_KEY = "sk_live_..."` | Hardcoded secret | CWE-798 |
| `allow_origins=["*"]` with credentials | CORS misconfiguration | CWE-942 |
| No auth check on DELETE/PUT endpoints | Broken access control | CWE-862 |
| `console.log(apiKey)` / `logging.info(secret)` | Secret leakage in logs | CWE-532 |
| Unlimited input length accepted | Denial of service | CWE-400 |
| Agent output executed without validation | Indirect code injection | CWE-94 |

---

## Quick Security Checklist

Use before shipping production code.

### Input/Output
- [ ] All external inputs validated (type, format, range via Zod/Pydantic)
- [ ] Input length limits enforced
- [ ] HTML escaped before rendering (XSS prevention)
- [ ] JSON schema validated before parsing
- [ ] Error messages don't leak sensitive info
- [ ] Agent outputs validated before execution

### Auth & Data
- [ ] Authentication verified on protected routes
- [ ] Permission checks before sensitive operations (authn + authz)
- [ ] Session management secure (HTTPS, httpOnly cookies)
- [ ] Secrets loaded from environment (not hardcoded)
- [ ] Sensitive data redacted from logs
- [ ] Database queries parameterized
- [ ] PII encrypted at rest and in transit

### Agent Security
- [ ] Tool calls validated against allowlist
- [ ] Tool permissions enforced (READ/WRITE/EXECUTE/ADMIN)
- [ ] Agent autonomy limits set (action/cost caps)
- [ ] High-risk actions require multi-step confirmation

### Network & Production
- [ ] HTTPS enforced (no HTTP in production)
- [ ] CORS restricted to specific origins
- [ ] Security headers set (CSP, X-Frame-Options, X-Content-Type-Options)
- [ ] Rate limiting on public endpoints
- [ ] Dependency vulnerabilities scanned (`npm audit`, `safety check`)
- [ ] Secrets rotation plan documented

---

## When to Use / Skip

**Invoke when:**
- Building production-facing features or public APIs
- Working with authentication, authorization, or session management
- Handling payments, financial data, or PII
- Before deploying to production or public-facing environments
- User requests security review or audit
- Implementing rate limiting, API throttling, or abuse prevention

**Skip when:**
- Local experiments or prototypes
- Internal tools with no external access
- Configuration or documentation changes
- Pure backend with no user input

---

## Agent Security Patterns (Summary)

These patterns apply to AI agents and autonomous systems.

| Pattern | Key Rule | Detail |
|---------|----------|--------|
| **Validate Tool Calls** | Allowlist + schema validation before execution | Never `globals()[name]()` |
| **Permission Boundaries** | Categorize tools: READ/WRITE/EXECUTE/ADMIN | Limit blast radius of compromised agents |
| **Validate Agent Outputs** | Check generated code/SQL/paths before execution | AST parsing, path traversal checks |
| **Multi-Step Confirmation** | Require explicit confirmation for destructive ops | Warn -> Confirm -> Log -> Execute |

---

## Web Security Patterns (Summary)

OWASP-aligned patterns for TypeScript and Python.

| Pattern | Key Rule | Tools/Libraries |
|---------|----------|-----------------|
| **Input Validation** | Validate type, format, range on all external data | Zod (TS), Pydantic (Python) |
| **Output Escaping** | Escape HTML before rendering user content | React auto-escapes, DOMPurify, Jinja2 autoescape |
| **Parameterized Queries** | Never concatenate SQL strings | Prisma, SQLAlchemy, `$queryRaw` |
| **Auth Checks** | Verify authn + authz before sensitive operations | next-auth, FastAPI Depends |
| **No Secrets in Code** | Load from env vars, never hardcode or log | `process.env`, `os.getenv()` |
| **Secure Headers** | Set CSP, X-Frame-Options, CORS on all responses | next.config.js headers, FastAPI middleware |

---

## AI/Prompt Security Patterns (Summary)

| Pattern | Key Rule |
|---------|----------|
| **Prompt Injection Prevention** | Sanitize user input before passing to LLM; filter instruction-like patterns |
| **LLM Output Validation** | Escape/sanitize LLM output before rendering; validate JSON schema |
| **Input Length Limits** | Enforce max length, validate UTF-8, block control characters |

---

## Consultation Gate

For detailed code examples and implementation patterns (TypeScript + Python for every pattern above), READ `references/security-patterns.md`.

---

## When in Doubt

1. **Ask "What's the worst that could happen?"** -- Threat modeling mindset
2. **Consult OWASP Top 10** -- https://owasp.org/Top10/
3. **Run automated scans** -- `npm audit`, `bandit`, `semgrep`
4. **Request human security review** -- Flag for expert review

**Default to secure:** Choose security over convenience for production code.

---

## Questions This Skill Answers

- How do I prevent SQL injection in TypeScript/Python?
- How do I sanitize user input before passing it to an LLM?
- What security headers should I set on HTTP responses?
- How do I validate agent tool calls before execution?
- What permission model should I use for agent tools?
- How do I prevent XSS when rendering user-generated content?
- How do I handle secrets without hardcoding them?
- What's the right way to validate LLM output before rendering?
- How do I implement multi-step confirmation for destructive actions?
- What should my pre-production security checklist cover?
- How do I set up CORS correctly without being too permissive?
- How do I validate file paths to prevent path traversal?

---

## See Also

- `gco-code-patterns` -- Anti-pattern detection and error handling
- `gco-completion-checklist` -- Pre-merge verification
- [OWASP Top 10](https://owasp.org/Top10/) -- Web application security risks
- [OWASP Cheat Sheets](https://cheatsheetseries.owasp.org/) -- Implementation guidance
