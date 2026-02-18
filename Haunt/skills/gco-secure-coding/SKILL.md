---
name: gco-secure-coding
description: Production security patterns for deployed apps, auth code, payments, and security reviews. Invoke when building production-facing features or when user mentions "production", "deploy", "auth", "security review", "payments", "PII", or "public API".
---

# Secure Coding Best Practices

## When to Use This Skill

**Invoke this skill when:**
- Building production-facing features or public APIs
- Working with authentication, authorization, or session management
- Handling payments, financial data, or personally identifiable information (PII)
- Before deploying to production or public-facing environments
- User explicitly requests security review or security audit
- Implementing rate limiting, API throttling, or abuse prevention

**Skip this skill when:**
- Working on local experiments or prototypes
- Building internal tools with no external access
- Making configuration or documentation changes
- Doing pure backend work with no user input

**Rationale:** Local dev work benefits from low friction. Production-bound code needs security rigor. This skill provides best practices when it matters, without adding overhead to exploration.

---

## Agent Security Patterns

Security patterns specific to AI agents and autonomous systems.

### 1. Validate Tool Calls Before Execution

**DO:** Use allowlists and schema validation for tool calls.

**TypeScript Example:**
```typescript
// Define allowed tools
const ALLOWED_TOOLS = ['read_file', 'search_code', 'run_tests'] as const;
type AllowedTool = typeof ALLOWED_TOOLS[number];

// Validate tool call
function validateToolCall(tool: string, params: unknown): void {
  if (!ALLOWED_TOOLS.includes(tool as AllowedTool)) {
    throw new Error(`Tool not allowed: ${tool}`);
  }

  // Schema validation
  const schema = getToolSchema(tool);
  if (!validateSchema(params, schema)) {
    throw new Error(`Invalid parameters for tool: ${tool}`);
  }
}
```

**DON'T:** Execute tool calls without validation.

**Python Example:**
```python
# WRONG: No validation
def execute_tool(tool_name: str, params: dict):
    return globals()[tool_name](**params)  # Dangerous!

# RIGHT: Allowlist + schema validation
ALLOWED_TOOLS = {'read_file', 'search_code', 'run_tests'}

def execute_tool(tool_name: str, params: dict):
    if tool_name not in ALLOWED_TOOLS:
        raise ValueError(f"Tool not allowed: {tool_name}")

    schema = get_tool_schema(tool_name)
    validate_schema(params, schema)  # Raises if invalid

    return TOOLS[tool_name](**params)
```

**WHY:** Unrestricted tool execution allows arbitrary code execution or data access. Allowlists prevent unauthorized actions; schema validation prevents malformed inputs.

---

### 2. Implement Tool Permission Boundaries

**DO:** Categorize tools by permission level (READ/WRITE/EXECUTE/ADMIN).

**TypeScript Example:**
```typescript
enum Permission {
  READ = 'READ',      // Read files, query data
  WRITE = 'WRITE',    // Write files, update data
  EXECUTE = 'EXECUTE', // Run commands, deploy
  ADMIN = 'ADMIN'     // Delete, modify permissions
}

const TOOL_PERMISSIONS: Record<string, Permission> = {
  read_file: Permission.READ,
  search_code: Permission.READ,
  write_file: Permission.WRITE,
  run_tests: Permission.EXECUTE,
  delete_file: Permission.ADMIN
};

function checkPermission(tool: string, userRole: string): boolean {
  const required = TOOL_PERMISSIONS[tool];
  const allowed = ROLE_PERMISSIONS[userRole];
  return allowed.includes(required);
}
```

**DON'T:** Give all tools the same permission level.

**Python Example:**
```python
# WRONG: Everything has ADMIN permission
def execute_any_tool(tool_name: str):
    return execute(tool_name)

# RIGHT: Permission boundaries
from enum import Enum

class Permission(Enum):
    READ = "READ"
    WRITE = "WRITE"
    EXECUTE = "EXECUTE"
    ADMIN = "ADMIN"

TOOL_PERMISSIONS = {
    "read_file": Permission.READ,
    "search_code": Permission.READ,
    "write_file": Permission.WRITE,
    "run_tests": Permission.EXECUTE,
    "delete_file": Permission.ADMIN
}

def check_permission(tool: str, user_role: str) -> bool:
    required = TOOL_PERMISSIONS[tool]
    allowed = ROLE_PERMISSIONS[user_role]
    return required in allowed
```

**WHY:** Not all operations have equal risk. READ operations are low-risk; ADMIN operations (delete, permission changes) are high-risk. Permission boundaries limit blast radius of compromised agents.

---

### 3. Validate Agent Outputs Before Action

**DO:** Validate agent-generated code/data before execution or storage.

**TypeScript Example:**
```typescript
// Validate generated SQL
function validateSQL(sql: string): void {
  // Block dangerous keywords
  const DANGEROUS = ['DROP', 'DELETE', 'TRUNCATE', 'ALTER'];
  const upperSQL = sql.toUpperCase();

  for (const keyword of DANGEROUS) {
    if (upperSQL.includes(keyword)) {
      throw new Error(`Dangerous SQL keyword: ${keyword}`);
    }
  }

  // Validate structure (parameterized query only)
  if (!sql.includes('$1') && sql.includes('=')) {
    throw new Error('Use parameterized queries only');
  }
}

// Validate file paths (prevent path traversal)
function validatePath(path: string): void {
  const resolved = resolvePath(path);
  const allowed = '/app/data';

  if (!resolved.startsWith(allowed)) {
    throw new Error(`Path outside allowed directory: ${path}`);
  }

  if (path.includes('..')) {
    throw new Error('Path traversal detected');
  }
}
```

**DON'T:** Trust agent-generated output without validation.

**Python Example:**
```python
# WRONG: Execute generated code directly
def run_agent_code(code: str):
    exec(code)  # Dangerous!

# RIGHT: Validate before execution
import ast

def validate_python(code: str) -> None:
    # Parse into AST
    try:
        tree = ast.parse(code)
    except SyntaxError:
        raise ValueError("Invalid Python syntax")

    # Block dangerous operations
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            if any(alias.name in {'os', 'subprocess'} for alias in node.names):
                raise ValueError("Dangerous imports blocked")

        if isinstance(node, ast.Call):
            if isinstance(node.func, ast.Name) and node.func.id in {'eval', 'exec'}:
                raise ValueError("Dangerous function calls blocked")

def run_agent_code(code: str):
    validate_python(code)
    exec(code, {'__builtins__': {}})  # Restricted builtins
```

**WHY:** Agents can hallucinate malicious or incorrect code. Validation prevents SQL injection, path traversal, arbitrary code execution. AST parsing detects dangerous patterns before execution.

---

### 4. Multi-Step Confirmation for High-Risk Actions

**DO:** Require explicit confirmation for destructive operations.

**TypeScript Example:**
```typescript
// High-risk actions require confirmation
async function deleteUserData(userId: string): Promise<void> {
  // Step 1: Warn user
  const warning = `This will permanently delete all data for user ${userId}`;
  console.warn(warning);

  // Step 2: Require explicit confirmation
  const confirmed = await prompt('Type DELETE to confirm: ');
  if (confirmed !== 'DELETE') {
    throw new Error('Operation cancelled');
  }

  // Step 3: Log action
  await auditLog('user_data_deleted', { userId, timestamp: Date.now() });

  // Step 4: Execute
  await db.delete('users', { id: userId });
}
```

**DON'T:** Allow one-step destructive actions.

**Python Example:**
```python
# WRONG: One-step deletion
def delete_user(user_id: str):
    db.delete('users', id=user_id)

# RIGHT: Multi-step confirmation
def delete_user(user_id: str):
    # Step 1: Warn
    print(f"WARNING: This will permanently delete user {user_id}")

    # Step 2: Confirm
    confirmation = input("Type DELETE to confirm: ")
    if confirmation != "DELETE":
        raise ValueError("Operation cancelled")

    # Step 3: Log
    audit_log("user_deleted", {"user_id": user_id, "timestamp": time.time()})

    # Step 4: Execute with transaction
    with db.transaction():
        db.delete('users', id=user_id)
```

**WHY:** Destructive actions (delete, payment, permission changes) are irreversible. Multi-step confirmation prevents accidental execution. Audit logs provide accountability trail.

---

## AI/Prompt Security Patterns

Security patterns for LLM input and output handling.

### 5. Prompt Injection Prevention

**DO:** Sanitize user input before passing to LLM.

**TypeScript Example:**
```typescript
// Sanitize user input to prevent prompt injection
function sanitizePrompt(userInput: string): string {
  // Remove instruction-like patterns
  const INJECTION_PATTERNS = [
    /ignore\s+previous\s+instructions/i,
    /new\s+instructions?:/i,
    /system\s+prompt/i,
    /you\s+are\s+now/i,
    /act\s+as\s+if/i
  ];

  let sanitized = userInput;
  for (const pattern of INJECTION_PATTERNS) {
    sanitized = sanitized.replace(pattern, '[FILTERED]');
  }

  // Escape special characters
  sanitized = sanitized.replace(/[<>{}]/g, '');

  return sanitized;
}

// Use sanitized input in prompt
function generateResponse(userInput: string): Promise<string> {
  const sanitized = sanitizePrompt(userInput);
  const prompt = `User question: ${sanitized}\n\nProvide a helpful answer.`;
  return callLLM(prompt);
}
```

**DON'T:** Pass raw user input to LLM prompts.

**Python Example:**
```python
# WRONG: Direct user input
def chat(user_input: str) -> str:
    prompt = f"User says: {user_input}\n\nRespond:"
    return llm.generate(prompt)

# RIGHT: Sanitized input
import re

INJECTION_PATTERNS = [
    re.compile(r'ignore\s+previous\s+instructions', re.IGNORECASE),
    re.compile(r'new\s+instructions?:', re.IGNORECASE),
    re.compile(r'system\s+prompt', re.IGNORECASE),
    re.compile(r'you\s+are\s+now', re.IGNORECASE),
]

def sanitize_prompt(user_input: str) -> str:
    sanitized = user_input

    # Filter injection patterns
    for pattern in INJECTION_PATTERNS:
        sanitized = pattern.sub('[FILTERED]', sanitized)

    # Remove special characters
    sanitized = re.sub(r'[<>{}]', '', sanitized)

    # Limit length (prevent DOS)
    return sanitized[:1000]

def chat(user_input: str) -> str:
    sanitized = sanitize_prompt(user_input)
    prompt = f"User question: {sanitized}\n\nProvide a helpful answer."
    return llm.generate(prompt)
```

**WHY:** Prompt injection allows users to override system instructions, leak prompts, or bypass safety filters. Sanitization removes instruction-like patterns before LLM sees them.

---

### 6. LLM Output Validation

**DO:** Validate and escape LLM output before rendering or execution.

**TypeScript Example:**
```typescript
import DOMPurify from 'dompurify';

// Validate JSON output
function parseJSONResponse(llmOutput: string): object {
  try {
    const parsed = JSON.parse(llmOutput);

    // Validate schema
    if (!isValidSchema(parsed)) {
      throw new Error('LLM output does not match schema');
    }

    return parsed;
  } catch (error) {
    throw new Error(`Invalid JSON from LLM: ${error.message}`);
  }
}

// Escape HTML output
function renderLLMResponse(llmOutput: string): string {
  // Sanitize HTML to prevent XSS
  return DOMPurify.sanitize(llmOutput);
}
```

**DON'T:** Render LLM output directly without escaping.

**Python Example:**
```python
# WRONG: Direct rendering of LLM output
def display_response(llm_output: str):
    return f"<div>{llm_output}</div>"  # XSS risk!

# RIGHT: Escape before rendering
import html
import json

def parse_json_response(llm_output: str) -> dict:
    try:
        parsed = json.loads(llm_output)
    except json.JSONDecodeError:
        raise ValueError("Invalid JSON from LLM")

    # Validate schema
    if not is_valid_schema(parsed):
        raise ValueError("LLM output does not match schema")

    return parsed

def render_llm_response(llm_output: str) -> str:
    # Escape HTML entities
    escaped = html.escape(llm_output)
    return f"<div>{escaped}</div>"
```

**WHY:** LLMs can generate malicious HTML, JavaScript, or invalid JSON. Escaping prevents XSS attacks. Schema validation ensures output matches expected structure.

---

### 7. Input Length Limits and Sanitization

**DO:** Limit input length to prevent denial-of-service.

**TypeScript Example:**
```typescript
const MAX_INPUT_LENGTH = 10000; // 10KB

function validateInput(userInput: string): void {
  // Check length
  if (userInput.length > MAX_INPUT_LENGTH) {
    throw new Error(`Input exceeds maximum length: ${MAX_INPUT_LENGTH}`);
  }

  // Validate UTF-8 encoding
  try {
    new TextEncoder().encode(userInput);
  } catch {
    throw new Error('Invalid UTF-8 encoding');
  }

  // Block control characters
  if (/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/.test(userInput)) {
    throw new Error('Control characters not allowed');
  }
}
```

**DON'T:** Accept unlimited input length.

**Python Example:**
```python
# WRONG: No length limit
def process_input(user_input: str):
    return llm.generate(user_input)

# RIGHT: Enforce limits
MAX_INPUT_LENGTH = 10000  # 10KB

def validate_input(user_input: str) -> None:
    # Check length
    if len(user_input) > MAX_INPUT_LENGTH:
        raise ValueError(f"Input exceeds {MAX_INPUT_LENGTH} characters")

    # Validate UTF-8
    try:
        user_input.encode('utf-8')
    except UnicodeEncodeError:
        raise ValueError("Invalid UTF-8 encoding")

    # Block null bytes
    if '\x00' in user_input:
        raise ValueError("Null bytes not allowed")

def process_input(user_input: str):
    validate_input(user_input)
    return llm.generate(user_input[:MAX_INPUT_LENGTH])
```

**WHY:** Unlimited input can exhaust memory or token limits (denial-of-service). Length limits prevent resource exhaustion. UTF-8 validation prevents encoding attacks.

---

## Web Security (OWASP) for TypeScript/Python

Key OWASP patterns relevant to Haunt's tech stack.

### 8. Input Validation on External Data

**DO:** Validate type, format, and range for all external inputs.

**TypeScript Example:**
```typescript
import { z } from 'zod';

// Define schema
const UserSchema = z.object({
  email: z.string().email().max(255),
  age: z.number().int().min(0).max(120),
  username: z.string().min(3).max(20).regex(/^[a-zA-Z0-9_]+$/)
});

// Validate input
function createUser(input: unknown): User {
  const validated = UserSchema.parse(input); // Throws if invalid
  return saveUser(validated);
}
```

**DON'T:** Trust external input without validation.

**Python Example:**
```python
# WRONG: No validation
def create_user(data: dict):
    return db.insert('users', **data)  # SQL injection risk

# RIGHT: Validate with Pydantic
from pydantic import BaseModel, EmailStr, conint, constr

class UserInput(BaseModel):
    email: EmailStr
    age: conint(ge=0, le=120)
    username: constr(min_length=3, max_length=20, regex=r'^[a-zA-Z0-9_]+$')

def create_user(data: dict):
    validated = UserInput(**data)  # Raises ValidationError if invalid
    return db.insert('users', validated.dict())
```

**WHY:** External inputs (API requests, form submissions) can contain malicious data. Schema validation enforces type safety, format constraints, and range limits.

---

### 9. Output Escaping (XSS Prevention)

**DO:** Escape HTML entities before rendering user content.

**TypeScript Example (React):**
```typescript
// React automatically escapes
function UserProfile({ username }: { username: string }) {
  return <div>{username}</div>; // Safe - React escapes by default
}

// If using dangerouslySetInnerHTML, sanitize first
import DOMPurify from 'dompurify';

function RichContent({ html }: { html: string }) {
  const sanitized = DOMPurify.sanitize(html);
  return <div dangerouslySetInnerHTML={{ __html: sanitized }} />;
}
```

**DON'T:** Render unsanitized user content.

**Python Example (Jinja2):**
```python
# WRONG: Manual HTML construction
def render_profile(username: str) -> str:
    return f"<div>Welcome {username}</div>"  # XSS risk

# RIGHT: Use template engine with auto-escaping
from jinja2 import Environment, select_autoescape

env = Environment(autoescape=select_autoescape(['html', 'xml']))
template = env.from_string("<div>Welcome {{ username }}</div>")

def render_profile(username: str) -> str:
    return template.render(username=username)  # Auto-escaped
```

**WHY:** User-provided content can contain `<script>` tags or event handlers. Escaping converts `<` to `&lt;`, preventing script execution (XSS attacks).

---

### 10. Parameterized Queries (SQL Injection Prevention)

**DO:** Use parameterized queries or ORM methods.

**TypeScript Example (Prisma):**
```typescript
// Safe - Prisma uses parameterized queries
async function getUser(email: string): Promise<User | null> {
  return prisma.user.findUnique({
    where: { email } // Automatically parameterized
  });
}

// If using raw SQL, use parameters
async function getUserRaw(email: string): Promise<User | null> {
  return prisma.$queryRaw`SELECT * FROM users WHERE email = ${email}`;
}
```

**DON'T:** Concatenate SQL strings.

**Python Example (SQLAlchemy):**
```python
# WRONG: String concatenation
def get_user(email: str):
    query = f"SELECT * FROM users WHERE email = '{email}'"
    return db.execute(query)  # SQL injection risk

# RIGHT: Parameterized query
def get_user(email: str):
    query = "SELECT * FROM users WHERE email = :email"
    return db.execute(query, {"email": email})  # Safe

# BEST: ORM
from sqlalchemy import select

def get_user(email: str):
    stmt = select(User).where(User.email == email)
    return db.execute(stmt).scalar_one_or_none()
```

**WHY:** String concatenation allows SQL injection (`'; DROP TABLE users; --`). Parameterized queries treat input as data, not code. ORMs automatically parameterize.

---

### 11. Authentication Checks on Sensitive Operations

**DO:** Verify user authentication and authorization before sensitive actions.

**TypeScript Example (Next.js):**
```typescript
import { getServerSession } from 'next-auth';

export async function DELETE(req: Request) {
  // Verify authentication
  const session = await getServerSession();
  if (!session) {
    return new Response('Unauthorized', { status: 401 });
  }

  // Verify authorization
  const userId = new URL(req.url).searchParams.get('userId');
  if (session.user.id !== userId && !session.user.isAdmin) {
    return new Response('Forbidden', { status: 403 });
  }

  // Perform action
  await deleteUser(userId);
  return new Response('User deleted', { status: 200 });
}
```

**DON'T:** Skip authentication checks.

**Python Example (FastAPI):**
```python
# WRONG: No auth check
@app.delete("/users/{user_id}")
async def delete_user(user_id: str):
    db.delete('users', id=user_id)
    return {"status": "deleted"}

# RIGHT: Auth + authz checks
from fastapi import Depends, HTTPException
from auth import get_current_user

@app.delete("/users/{user_id}")
async def delete_user(
    user_id: str,
    current_user: User = Depends(get_current_user)
):
    # Check authentication
    if not current_user:
        raise HTTPException(status_code=401, detail="Unauthorized")

    # Check authorization
    if current_user.id != user_id and not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Forbidden")

    db.delete('users', id=user_id)
    return {"status": "deleted"}
```

**WHY:** Sensitive operations (delete, update, payment) must verify identity (authentication) and permissions (authorization). Skipping checks allows unauthorized access.

---

### 12. No Secrets in Code or Logs

**DO:** Load secrets from environment variables or secure vaults.

**TypeScript Example:**
```typescript
// Load from environment
const API_KEY = process.env.API_KEY;
if (!API_KEY) {
  throw new Error('API_KEY not set in environment');
}

// Use in requests
async function callAPI(data: object): Promise<Response> {
  return fetch('https://api.example.com', {
    headers: {
      'Authorization': `Bearer ${API_KEY}`
    },
    body: JSON.stringify(data)
  });
}

// Never log secrets
console.log('Making API call', { data }); // Good - no API_KEY
console.log('API_KEY:', API_KEY); // BAD - leaks secret
```

**DON'T:** Hardcode secrets or log them.

**Python Example:**
```python
# WRONG: Hardcoded secret
API_KEY = "sk_live_1234567890abcdef"  # Leaked in git!

# RIGHT: Load from environment
import os

API_KEY = os.getenv('API_KEY')
if not API_KEY:
    raise ValueError("API_KEY not set in environment")

# Use in requests
import requests

def call_api(data: dict):
    response = requests.post(
        'https://api.example.com',
        headers={'Authorization': f'Bearer {API_KEY}'},
        json=data
    )
    return response.json()

# Redact secrets from logs
import logging

logging.info(f"API call: {data}")  # Good
logging.info(f"API_KEY: {API_KEY}")  # BAD - leaks secret
```

**WHY:** Hardcoded secrets are leaked in git history, logs, and error messages. Environment variables keep secrets out of source code. Log redaction prevents accidental exposure.

---

### 13. Secure Headers (CORS, CSP, etc.)

**DO:** Set security headers on all HTTP responses.

**TypeScript Example (Next.js):**
```typescript
// next.config.js
module.exports = {
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          // Prevent clickjacking
          { key: 'X-Frame-Options', value: 'DENY' },
          // Block MIME sniffing
          { key: 'X-Content-Type-Options', value: 'nosniff' },
          // Enable XSS filter
          { key: 'X-XSS-Protection', value: '1; mode=block' },
          // Content Security Policy
          {
            key: 'Content-Security-Policy',
            value: "default-src 'self'; script-src 'self'"
          },
          // CORS
          { key: 'Access-Control-Allow-Origin', value: 'https://example.com' }
        ]
      }
    ];
  }
};
```

**DON'T:** Use permissive CORS or skip security headers.

**Python Example (FastAPI):**
```python
# WRONG: Permissive CORS
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows any origin - insecure
    allow_credentials=True
)

# RIGHT: Restrictive CORS + security headers
from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware

app = FastAPI()

# Restrictive CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://example.com"],  # Specific origin only
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type", "Authorization"]
)

# Security headers
@app.middleware("http")
async def add_security_headers(request, call_next):
    response = await call_next(request)
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Content-Security-Policy"] = "default-src 'self'"
    return response
```

**WHY:** Security headers defend against common attacks. CORS restricts cross-origin requests. CSP prevents inline scripts. X-Frame-Options blocks clickjacking.

---

## Quick Security Checklist

Use this before shipping production code:

### Input Validation
- [ ] All external inputs validated (type, format, range)
- [ ] Input length limits enforced (prevent DOS)
- [ ] Special characters sanitized or escaped
- [ ] File upload restrictions (type, size, content)

### Output Handling
- [ ] HTML escaped before rendering (XSS prevention)
- [ ] JSON schema validated before parsing
- [ ] Error messages don't leak sensitive info
- [ ] Agent outputs validated before execution

### Authentication & Authorization
- [ ] User authentication verified on protected routes
- [ ] Permission checks before sensitive operations
- [ ] Session management secure (HTTPS, httpOnly cookies)
- [ ] Password hashing with bcrypt/argon2 (never plaintext)

### Data Protection
- [ ] Secrets loaded from environment (not hardcoded)
- [ ] Sensitive data redacted from logs
- [ ] Database queries parameterized (SQL injection prevention)
- [ ] PII encrypted at rest and in transit

### Agent Security
- [ ] Tool calls validated against allowlist
- [ ] Tool permissions enforced (READ/WRITE/EXECUTE/ADMIN)
- [ ] Agent autonomy limits set (action/cost caps)
- [ ] High-risk actions require multi-step confirmation

### Network Security
- [ ] HTTPS enforced (no HTTP in production)
- [ ] CORS restricted to specific origins
- [ ] Security headers set (CSP, X-Frame-Options, etc.)
- [ ] Rate limiting enabled on public endpoints

### Error Handling
- [ ] Errors logged with context (not swallowed)
- [ ] Error messages user-friendly (no stack traces)
- [ ] Fallback behavior for failures defined
- [ ] Alerting configured for critical errors

### Production Readiness
- [ ] Security audit completed
- [ ] Dependency vulnerabilities scanned (`npm audit`, `safety check`)
- [ ] Secrets rotation plan documented
- [ ] Incident response plan defined

---

## When in Doubt

**If you're unsure whether a security pattern applies:**

1. **Ask "What's the worst that could happen?"** - Threat modeling mindset
2. **Consult OWASP Top 10** - https://owasp.org/Top10/
3. **Run automated scans** - `npm audit`, `bandit`, `semgrep`
4. **Request human security review** - Flag for expert review

**Default to secure:** If choosing between convenience and security, choose security for production code. You can always relax restrictions later with justification.

---

## See Also

- `.claude/rules/gco-ui-testing-reminder.md` - E2E testing enforcement
- `gco-code-patterns` - Anti-pattern detection and error handling
- `gco-completion-checklist` - Pre-merge verification
- [OWASP Top 10](https://owasp.org/Top10/) - Web application security risks
- [OWASP Cheat Sheets](https://cheatsheetseries.owasp.org/) - Implementation guidance
