---
last-verified: 2026-04-03
name: gco-react-standards
description: React/TypeScript architecture and coding standards for frontend work. Invoke when working on .tsx/.jsx files, implementing React components, or organizing React project structure.
---

# React Standards

**Core:** Feature-based organization. Server state ≠ client state. Composition over props. Security server-side only.

## Anti-Patterns (Never Do)

| Pattern | Fix |
|---------|-----|
| Redux for server data | React Query/SWR |
| Tokens in localStorage | Memory (useState) + HttpOnly cookie |
| Feature-to-feature imports | Import from shared only |
| Barrel files (`index.ts`) | Direct imports |
| Roles (`user.role === 'admin'`) | Permissions (`user.permissions.includes(...)`) |
| `dangerouslySetInnerHTML` | DOMPurify.sanitize() first |
| State lifted too high | Keep local to component |

## State Management

| Type | Tool | Use Case |
|------|------|----------|
| Component | useState | Local UI (toggle, input) |
| Application | Context, Zustand | Theme, modals, notifications |
| Server | React Query, SWR | Remote data (API) |
| Form | React Hook Form + Zod | Validation, submission |
| URL | React Router | Filters, pagination, params |

**Decision tree:**
```
Remote data? → React Query/SWR
URL-based? → React Router
Global app state? → Context/Zustand
Form? → React Hook Form + Zod
Component-local? → useState
```

## File Naming

| Item | Convention | Example |
|------|------------|---------|
| Files | kebab-case | `user-profile.tsx` |
| Components | PascalCase | `export const UserProfile` |
| Hooks | `use` + camelCase | `export const useAuth` |
| Folders | kebab-case | `features/user-management/` |
| Tests | `.test.tsx` | `UserProfile.test.tsx` |

## Project Structure

```
src/
├── app/          # Routes, providers
├── features/     # Self-contained modules
│   └── [name]/
│       ├── api/       # API calls
│       ├── components/
│       ├── hooks/
│       ├── stores/
│       ├── types/
│       └── index.ts   # Public exports
├── components/   # Shared components
├── hooks/        # Shared hooks
├── lib/          # Preconfigured libraries
└── utils/        # Shared utilities
```

**Dependency flow:** Shared → Features → App (unidirectional, no feature-to-feature)

## Component Patterns

**Extract nested maps:**
```tsx
// Wrong: <div>{users.map(u => <div>{u.posts.map(...)}</div>)}</div>
// Right: <UserList users={users} /> → <UserItem /> → <PostList />
```

**Composition over props:**
```tsx
// Wrong: <Modal title={...} content={...} footer={...} />
// Right: <Modal><ModalHeader>...</ModalHeader>...</Modal>
```

**API layer (3-layer):**
```
types/index.ts       → LoginRequest, LoginResponse
api/login.ts         → login(data): Promise<LoginResponse>
hooks/useLogin.ts    → useMutation({ mutationFn: login })
```

## Security Essentials

| Item | Rule | Anti-Pattern |
|------|------|--------------|
| Tokens | Memory (useState) + HttpOnly cookie | localStorage, sessionStorage |
| Authorization | Server-side validation | Client-side only |
| Permissions | `user.permissions.includes(...)` | `user.role === 'admin'` |
| HTML injection | DOMPurify.sanitize() | dangerouslySetInnerHTML raw |
| Client auth | UX only (hide UI) | Security enforcement |

**Permission component:**
```tsx
<Restricted to="delete:projects"><DeleteButton /></Restricted>
// Server MUST also validate permissions
```

## Forms (React Hook Form + Zod)

```tsx
const schema = z.object({ email: z.string().email(), password: z.string().min(8) });
const { register, handleSubmit, formState: { errors } } = useForm({
  resolver: zodResolver(schema),
});
```

## Testing Requirements

- Unit: Complex logic (utils, hooks)
- Integration: Component interactions (Testing Library)
- E2E: User flows (Playwright - see `gco-ui-testing` skill)

## Completion Checklist

- [ ] Feature-based organization (no feature-to-feature imports)
- [ ] Server state in React Query, client state in useState/Context
- [ ] Tokens in memory (not localStorage)
- [ ] Permissions checked (not roles)
- [ ] Authorization validated server-side
- [ ] No barrel files (direct imports with `@/` alias)
- [ ] E2E tests exist (see `gco-ui-testing`)

## See Also

- `gco-ui-testing` - Playwright E2E testing requirements
- `gco-ui-design` - UI/UX design standards
