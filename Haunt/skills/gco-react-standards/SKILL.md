---
name: gco-react-standards
description: React/TypeScript architecture and coding standards for frontend work. Invoke when working on .tsx/.jsx files, implementing React components, or organizing React project structure.
---

# React Standards

Comprehensive React/TypeScript standards for frontend development based on Bulletproof React architecture principles.

## When to Invoke

- Implementing React components (.tsx/.jsx files)
- Organizing React project structure (features, components)
- Deciding state management approach
- Setting up API layer patterns
- Working with forms and validation
- Implementing security (authentication, authorization)

## Core Principles

1. **Feature-based organization** with unidirectional dependency flow
2. **Colocate code near usage** - components, styles, state together
3. **Separate server state from client state** - React Query/SWR, not Redux
4. **Client-side security is UX only** - ALL authorization validated server-side

## Project Structure

### Recommended Architecture

```
src/
├── app/           # Routes, providers, router (entry point)
│   ├── routes/        # Route definitions
│   ├── providers/     # App-level providers
│   └── index.tsx      # App entry point
├── features/      # Self-contained feature modules
│   └── [feature]/
│       ├── api/          # Feature API calls
│       ├── components/   # Feature components
│       ├── hooks/        # Feature hooks
│       ├── stores/       # Feature state
│       ├── types/        # Feature TypeScript types
│       └── index.ts      # Feature exports
├── components/    # Shared components
├── hooks/         # Shared hooks
├── lib/           # Preconfigured libraries
├── stores/        # Global application state
├── types/         # Shared TypeScript types
└── utils/         # Shared utilities
```

### Architectural Rules

**Dependency flow:** Shared → Features → App (unidirectional)

**Prohibited patterns:**
- ❌ Feature-to-feature imports (creates coupling)
- ❌ App importing from features directly (bypasses feature boundaries)
- ✅ Features import from shared directories
- ✅ App imports feature entry points (`features/[feature]/index.ts`)

**Enforcement:** Use ESLint with `import/no-restricted-paths` to prevent violations.

### Colocation Principle

Keep code close to where it's used:

```
features/
└── authentication/
    ├── api/
    │   └── login.ts              # Login API call
    ├── components/
    │   ├── LoginForm.tsx         # Used only in authentication
    │   └── LoginForm.test.tsx    # Test colocated with component
    ├── hooks/
    │   └── useLogin.ts           # Hook wraps API call
    └── index.ts                   # Public exports
```

**Benefits:**
- Easier to understand feature scope
- Reduced re-renders (components don't share unnecessary state)
- Simpler refactoring (feature is self-contained)
- Clear ownership (feature owns its dependencies)

## State Management

### State Categories

| State Type | Tools | Use Case | Anti-Pattern |
|------------|-------|----------|--------------|
| **Component** | useState, useReducer | Local UI state (toggle, input value) | Using Context for component state |
| **Application** | Context, Zustand | Modals, theme, notifications | Using Redux for simple flags |
| **Server Cache** | React Query, SWR | Remote data (users, products) | Using Redux for server data |
| **Form** | React Hook Form + Zod | Validation, submission | Uncontrolled forms without validation |
| **URL** | React Router | Dynamic params, filters | Storing filters in component state |

### Critical Rule: Server State ≠ Client State

**WRONG (Redux anti-pattern):**
```typescript
// DON'T store server data in Redux
const usersSlice = createSlice({
  name: 'users',
  initialState: { data: [], loading: false },
  reducers: {
    fetchUsersStart: (state) => { state.loading = true },
    fetchUsersSuccess: (state, action) => { state.data = action.payload },
  }
});
```

**RIGHT (React Query pattern):**
```typescript
// DO use React Query for server data
const useUsers = () => {
  return useQuery({
    queryKey: ['users'],
    queryFn: () => api.users.list(),
  });
};

// Usage
const { data, isLoading, error } = useUsers();
```

**Why:** React Query handles caching, invalidation, refetching automatically. Redux requires manual state management for async data.

### State Localization

**Principle:** Keep state as close as possible to components that need it.

```typescript
// BAD - Lifting state too high
function App() {
  const [modalOpen, setModalOpen] = useState(false);  // Only used in UserProfile
  return <UserProfile modalOpen={modalOpen} setModalOpen={setModalOpen} />;
}

// GOOD - State in component that uses it
function UserProfile() {
  const [modalOpen, setModalOpen] = useState(false);
  return <Modal open={modalOpen} onClose={() => setModalOpen(false)} />;
}
```

## API Layer Pattern

### Three-Layer Structure

```typescript
// 1. Types (features/[feature]/types/index.ts)
export type LoginRequest = {
  email: string;
  password: string;
};

export type LoginResponse = {
  token: string;
  user: User;
};

// 2. Fetcher (features/[feature]/api/login.ts)
import { apiClient } from '@/lib/api-client';
import type { LoginRequest, LoginResponse } from '../types';

export const login = (data: LoginRequest): Promise<LoginResponse> => {
  return apiClient.post('/auth/login', data);
};

// 3. Hook (features/[feature]/hooks/useLogin.ts)
import { useMutation } from '@tanstack/react-query';
import { login } from '../api/login';

export const useLogin = () => {
  return useMutation({
    mutationFn: login,
    onSuccess: (data) => {
      // Handle success (redirect, store token, etc.)
    },
  });
};

// 4. Usage in component
import { useLogin } from '../hooks/useLogin';

function LoginForm() {
  const loginMutation = useLogin();

  const handleSubmit = (data: LoginRequest) => {
    loginMutation.mutate(data);
  };

  return (
    <form onSubmit={handleSubmit}>
      {loginMutation.isError && <ErrorMessage error={loginMutation.error} />}
      {loginMutation.isPending && <Spinner />}
      {/* form fields */}
    </form>
  );
}
```

**Benefits:**
- Types ensure request/response match
- Fetcher is testable in isolation
- Hook provides loading/error states
- Component focuses on UI

## File Naming Conventions

| Item | Convention | Example |
|------|------------|---------|
| **Files** | kebab-case | `user-profile.tsx` |
| **Components** | PascalCase export | `export const UserProfile` |
| **Hooks** | camelCase with `use` prefix | `export const useAuth` |
| **Folders** | kebab-case | `features/user-management/` |
| **Test files** | `.test.tsx` or `.spec.tsx` | `UserProfile.test.tsx` |

### Import Conventions

**Use absolute imports with @ alias:**

```typescript
// GOOD
import { Button } from '@/components/Button';
import { useAuth } from '@/features/auth/hooks/useAuth';

// BAD
import { Button } from '../../components/Button';
import { useAuth } from '../../../features/auth/hooks/useAuth';
```

**Configure in tsconfig.json:**
```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
```

**NO barrel files (index.ts re-exports):**

```typescript
// BAD - Barrel file prevents tree-shaking
// components/index.ts
export { Button } from './Button';
export { Input } from './Input';

// Usage
import { Button } from '@/components';  // Imports entire barrel

// GOOD - Direct imports enable tree-shaking
import { Button } from '@/components/Button';
```

## Component Organization

### Extract Nested Renders

```typescript
// BAD - Nested renders create unnecessary re-renders
function UserList({ users }: Props) {
  return (
    <div>
      {users.map(user => (
        <div key={user.id}>
          <h3>{user.name}</h3>
          {user.posts.map(post => (
            <div key={post.id}>
              <p>{post.title}</p>
            </div>
          ))}
        </div>
      ))}
    </div>
  );
}

// GOOD - Extracted components reduce re-renders
function UserList({ users }: Props) {
  return (
    <div>
      {users.map(user => (
        <UserItem key={user.id} user={user} />
      ))}
    </div>
  );
}

function UserItem({ user }: { user: User }) {
  return (
    <div>
      <h3>{user.name}</h3>
      <PostList posts={user.posts} />
    </div>
  );
}

function PostList({ posts }: { posts: Post[] }) {
  return (
    <div>
      {posts.map(post => (
        <PostItem key={post.id} post={post} />
      ))}
    </div>
  );
}
```

### Composition Over Props

```typescript
// BAD - Prop drilling
function Modal({ title, content, footer }: Props) {
  return (
    <div>
      <h2>{title}</h2>
      <div>{content}</div>
      <div>{footer}</div>
    </div>
  );
}

// GOOD - Composition via children/slots
function Modal({ children }: { children: React.ReactNode }) {
  return <div className="modal">{children}</div>;
}

function ModalHeader({ children }: { children: React.ReactNode }) {
  return <h2 className="modal-header">{children}</h2>;
}

function ModalBody({ children }: { children: React.ReactNode }) {
  return <div className="modal-body">{children}</div>;
}

function ModalFooter({ children }: { children: React.ReactNode }) {
  return <div className="modal-footer">{children}</div>;
}

// Usage
<Modal>
  <ModalHeader>Confirm Delete</ModalHeader>
  <ModalBody>Are you sure?</ModalBody>
  <ModalFooter>
    <Button onClick={cancel}>Cancel</Button>
    <Button onClick={confirm}>Confirm</Button>
  </ModalFooter>
</Modal>
```

## Security Standards

### Token Storage

| Token Type | Storage | Why | Anti-Pattern |
|------------|---------|-----|--------------|
| **Access Token** | React state (memory) | XSS can't steal | localStorage, sessionStorage |
| **Refresh Token** | HttpOnly cookie | JS can't access | localStorage, sessionStorage |

**NEVER store tokens in localStorage or sessionStorage:**

```typescript
// WRONG - XSS can steal tokens
localStorage.setItem('token', accessToken);
sessionStorage.setItem('token', accessToken);

// RIGHT - Memory-only storage
function useAuth() {
  const [accessToken, setAccessToken] = useState<string | null>(null);
  // Token only exists in React state, lost on page refresh
}

// RIGHT - Refresh token in HttpOnly cookie (server sets)
// Server response:
// Set-Cookie: refreshToken=...; HttpOnly; Secure; SameSite=Strict
```

### Authorization Patterns

**Check permissions, not roles:**

```typescript
// WRONG - Role-based checks
if (user.role === 'admin') {
  return <DeleteButton />;
}

// RIGHT - Permission-based checks
if (user.permissions.includes('delete:projects')) {
  return <DeleteButton />;
}

// BETTER - Permission component
<Restricted to="delete:projects">
  <DeleteButton />
</Restricted>
```

**Implementation:**

```typescript
// lib/permissions.tsx
type Permission = 'create:projects' | 'delete:projects' | 'view:admin';

interface RestrictedProps {
  to: Permission | Permission[];
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

export function Restricted({ to, children, fallback = null }: RestrictedProps) {
  const { user } = useAuth();

  const permissions = Array.isArray(to) ? to : [to];
  const hasPermission = permissions.some(p => user?.permissions.includes(p));

  return hasPermission ? <>{children}</> : <>{fallback}</>;
}
```

### XSS Prevention

```typescript
// WRONG - Dangerous HTML injection
function Comment({ text }: { text: string }) {
  return <div dangerouslySetInnerHTML={{ __html: text }} />;
}

// RIGHT - React escapes by default
function Comment({ text }: { text: string }) {
  return <div>{text}</div>;
}

// IF dangerouslySetInnerHTML is required (rich text editor):
import DOMPurify from 'dompurify';

function Comment({ html }: { html: string }) {
  const sanitized = DOMPurify.sanitize(html);
  return <div dangerouslySetInnerHTML={{ __html: sanitized }} />;
}
```

**Critical Rule:** NEVER use `dangerouslySetInnerHTML` with unsanitized user input.

### Server-Side Authorization

**Client-side authorization is UX only, not security:**

```typescript
// Client-side: Hide UI based on permissions (UX)
<Restricted to="delete:projects">
  <DeleteButton onClick={handleDelete} />
</Restricted>

// Server-side: MUST verify permissions (SECURITY)
// POST /api/projects/:id/delete
async function deleteProject(req, res) {
  const user = await authenticateUser(req);

  if (!user.permissions.includes('delete:projects')) {
    return res.status(403).json({ error: 'Forbidden' });
  }

  await db.projects.delete(req.params.id);
  res.status(204).send();
}
```

**Rule:** ALWAYS validate permissions server-side. Client checks are for UX convenience only.

## Form Handling

### React Hook Form + Zod Pattern

```typescript
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

// 1. Define schema
const loginSchema = z.object({
  email: z.string().email('Invalid email format'),
  password: z.string().min(8, 'Password must be 8+ characters'),
});

type LoginFormData = z.infer<typeof loginSchema>;

// 2. Component with validation
function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
  });

  const onSubmit = async (data: LoginFormData) => {
    await login(data);
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} type="email" />
      {errors.email && <span role="alert">{errors.email.message}</span>}

      <input {...register('password')} type="password" />
      {errors.password && <span role="alert">{errors.password.message}</span>}

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Logging in...' : 'Log in'}
      </button>
    </form>
  );
}
```

## Testing Integration

React components should have:
1. **Unit tests** for complex logic (utilities, hooks)
2. **Integration tests** for component interactions (Testing Library)
3. **E2E tests** for user flows (Playwright - see `gco-ui-testing` skill)

**For E2E testing requirements, invoke:** `/gco-ui-testing` skill

## Non-Negotiable Rules

### Architecture
- ❌ NEVER allow feature-to-feature imports (creates coupling)
- ❌ NEVER use Redux for server cache (use React Query/SWR)
- ❌ NEVER use barrel files (breaks tree-shaking)
- ✅ ALWAYS use feature-based organization
- ✅ ALWAYS colocate code near usage

### Security
- ❌ NEVER store tokens in localStorage/sessionStorage (XSS risk)
- ❌ NEVER trust client-side authorization (UX only, not security)
- ❌ NEVER use `dangerouslySetInnerHTML` without DOMPurify
- ✅ ALWAYS validate permissions server-side
- ✅ ALWAYS sanitize user input before rendering HTML

### State Management
- ❌ NEVER use Redux for server data (use React Query/SWR)
- ❌ NEVER lift state unnecessarily (keep it local)
- ✅ ALWAYS separate server state from client state
- ✅ ALWAYS use React Query/SWR for remote data

### Imports
- ❌ NEVER use barrel files (prevent tree-shaking)
- ❌ NEVER use relative imports for shared code
- ✅ ALWAYS use absolute imports with @ alias
- ✅ ALWAYS import components directly

## Quick Reference

### State Management Decision Tree

```
Is it remote data (API)? → React Query/SWR
Is it URL-based (filters, pagination)? → React Router params
Is it global app state (theme, auth)? → Context/Zustand
Is it form data? → React Hook Form + Zod
Is it component-local (toggle, input)? → useState
```

### Security Checklist

- [ ] Tokens stored in memory (not localStorage)
- [ ] Permissions checked (not roles)
- [ ] Authorization validated server-side
- [ ] User input sanitized before rendering HTML
- [ ] No `dangerouslySetInnerHTML` without DOMPurify

### Architecture Checklist

- [ ] Feature-based organization (no feature-to-feature imports)
- [ ] Code colocated near usage
- [ ] Absolute imports with @ alias
- [ ] No barrel files (direct imports only)
- [ ] Server state in React Query, client state in useState/Context

## See Also

- `gco-ui-design` skill - UI/UX design standards (8px grid, contrast, states)
- `gco-ui-testing` skill - Playwright E2E testing requirements
- `gco-tdd-workflow` skill - Test-driven development process
- `.haunt/docs/research/bulletproof-react-analysis.md` - Architecture deep dive
