# Frontend Mode Guidance

## Overview

Frontend mode applies to:
- UI components, pages, client-side state, styles
- File paths: `*/components/*`, `*/pages/*`, `*/styles/*`, `*/ui/*`

## Test Commands

```bash
# Unit/component tests
npm test

# E2E tests (REQUIRED for all UI work)
npx playwright test

# E2E tests with visible browser (debugging)
npx playwright test --headed

# Interactive debugging
npx playwright test --ui
```

## Focus Areas

1. **Component behavior** - User interactions, state management, props handling
2. **Accessibility** - Keyboard navigation, screen reader support, ARIA labels
3. **Responsive design** - Mobile-first approach, breakpoints, flexible layouts
4. **User interactions** - Forms, modals, navigation, error states, loading states

## Tech Stack Awareness

Common frontend technologies:
- **Frameworks**: React, Vue, Svelte, Angular
- **TypeScript** - Type safety for better DX
- **Styling**: Tailwind, CSS Modules, Styled Components
- **Testing**: Jest, Vitest, Playwright
- **State Management**: React Context, Zustand, Redux (for server cache: React Query, SWR)

## Frontend Mode Startup (REQUIRED)

**When entering Frontend Mode, ASK the user:**

> "I'm starting frontend work on [feature]. Would you like me to use the **frontend-design plugin** for this task? It provides:
> - Component scaffolding and templates
> - Responsive design utilities
> - Accessibility checks
> - Browser preview integration
>
> **Options:**
> 1. Yes, use the plugin (Recommended for UI-heavy work)
> 2. No, standard implementation
> 3. Check if plugin is installed first"

**If user chooses option 3 or is unsure:**
```bash
claude plugin list | grep frontend-design
```

**If not installed:**
```bash
claude plugin install frontend-design@claude-code-plugins
```

**Why this matters:** The frontend-design plugin catches UI/UX issues early (spacing, contrast, accessibility) that are expensive to fix later.

## E2E Testing Requirements (CRITICAL)

**All user-facing UI changes REQUIRE E2E tests using Playwright.**

### Workflow

1. **BEFORE Writing Tests (REQUIRED):** Map the user journey
   - Ask: "What is the user trying to accomplish?" (JTBD Framework)
   - Map complete journey from user's perspective
   - Define expected outcome for EACH step
   - Write Gherkin scenarios (Given-When-Then format)
   - Use journey template (`.haunt/templates/user-journey-template.md`) for M-sized features

2. **Before Implementation (Optional):** Use Chrome Recorder
   - Open Chrome DevTools → Recorder
   - Record user interaction
   - Export as Playwright
   - Refine selectors to use `data-testid`

3. **During Implementation (TDD):**
   - Write failing E2E test first (RED) based on mapped journey
   - Implement feature to pass test (GREEN)
   - Refactor while keeping test green (REFACTOR)

4. **Before Marking Complete:**
   - Run `npx playwright test` to verify all tests pass
   - Verify tests use proper selectors (`data-testid` preferred)
   - Verify tests cover happy path AND error recovery paths
   - Verify E2E test design checklist (`.haunt/checklists/e2e-test-design-checklist.md`)

### E2E Test Commands

```bash
# Run all E2E tests
npx playwright test

# Run specific test file
npx playwright test tests/e2e/login.spec.ts

# Interactive debugging mode
npx playwright test --ui

# Run with visible browser (debugging)
npx playwright test --headed

# Generate tests interactively
npx playwright codegen
```

### Prohibitions

- ❌ NEVER mark UI requirement 🟢 without E2E tests
- ❌ NEVER skip `npx playwright test` before marking complete
- ❌ NEVER use brittle selectors (CSS nth-child, complex CSS paths)
- ❌ NEVER test only happy path (error cases are REQUIRED)

## Visual Validation with Playwright MCP

**Use Playwright MCP tools to visually validate your UI work:**

1. `mcp__playwright__playwright_navigate` to the page
2. `mcp__playwright__playwright_screenshot` at 3 widths:
   - Mobile: `mcp__playwright__playwright_resize` with `device: "iPhone 13"`
   - Tablet: `mcp__playwright__playwright_resize` with `device: "iPad"`
   - Desktop: `mcp__playwright__playwright_resize` with `width: 1280, height: 720`
3. `mcp__playwright__playwright_console_logs` - check for errors/warnings
4. Visually compare screenshots against design spec (if provided)
5. Fix discrepancies, re-screenshot until correct

**Device testing:** Playwright MCP supports 143+ device presets. Use natural language: "iPhone 13", "iPad Pro", "Pixel 7", "Galaxy S24".

**This closes the feedback loop:** You can now SEE what you built, not just assume the code is correct.

## UI/UX Design Principles (Auto-Enforced)

**CRITICAL:** All UI generation MUST follow these 10 essential rules (see `.claude/rules/gco-ui-design-standards.md` for enforcement):

1. **8px Grid System** - ALL spacing uses 8px increments (8, 16, 24, 32, 40, 48, etc.)
2. **4.5:1 Contrast Minimum** - Check contrast ratio BEFORE outputting colors (WCAG AA compliance)
3. **5 Interactive States** - Define default, hover, active, focus, disabled for ALL interactive elements
4. **44×44px Touch Targets** - Minimum clickable/tappable area (Fitts's Law compliance)
5. **Skip Links** - Include skip-to-content link for keyboard navigation
6. **Semantic HTML First** - Use `<button>`, `<nav>`, `<main>`, `<article>` before divs
7. **Inline Form Validation** - Validate fields on blur, show errors immediately
8. **Mobile-First Responsive** - Start with mobile layout, enhance for desktop
9. **Focus Indicators** - Visible focus outline for ALL interactive elements (3px minimum)
10. **Design Tokens** - Use CSS variables/theme tokens, never hardcoded hex colors

### Pre-Generation Checklist

Verify BEFORE writing UI code:
- [ ] Spacing grid defined (8px base, 4px for fine-tuning only)
- [ ] Color palette checked for 4.5:1 contrast minimum
- [ ] Interactive states documented (default/hover/active/focus/disabled)
- [ ] Touch targets sized (44×44px minimum)
- [ ] Semantic HTML structure planned
- [ ] Skip links included in layout
- [ ] Form validation strategy defined (inline + helpful errors)
- [ ] Responsive breakpoints planned (mobile-first)

### During Generation

- Use design tokens: `--color-primary`, `--spacing-4` (not `#3B82F6`, `32px`)
- Check contrast: Text on background must be 4.5:1 minimum (use online checker if unsure)
- Define states explicitly: Don't assume defaults, show all 5 states
- Size touch targets: Buttons/links 44×44px minimum, 48×48px preferred
- Semantic first: `<button>` not `<div onclick>`, `<nav>` not `<div class="nav">`

### Post-Generation Validation

Run BEFORE marking complete:
- [ ] All spacing divisible by 8 (or 4 for fine-tuning)
- [ ] Contrast checked with tool (WebAIM, Stark, etc.)
- [ ] All 5 states defined and visible
- [ ] Touch targets measured (44×44px minimum)
- [ ] Keyboard navigation tested (Tab, Enter, Esc work)
- [ ] Color blindness tested (grayscale/protanopia/deuteranopia)
- [ ] Focus indicators visible (3px outline minimum)
- [ ] Skip links functional
- [ ] Mobile layout tested (320px width minimum)

## Common Frontend Patterns

### Form Handling
```typescript
// Use React Hook Form + Zod for validation
import { useForm } from 'react-hook-form';
import { z } from 'zod';

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8)
});

function LoginForm() {
  const { register, handleSubmit, formState: { errors } } = useForm({
    resolver: zodResolver(schema)
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      {errors.email && <span>{errors.email.message}</span>}
    </form>
  );
}
```

### Loading States
```typescript
// Always show loading state for async operations
function UserProfile() {
  const { data, isLoading, error } = useQuery('/api/user');

  if (isLoading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;

  return <div>{data.name}</div>;
}
```

### Error Recovery
```typescript
// Provide clear error messages and recovery actions
function ErrorMessage({ error }) {
  return (
    <div role="alert">
      <p>{error.message}</p>
      <button onClick={() => retry()}>Try Again</button>
    </div>
  );
}
```

## Completion Checklist (Frontend)

Before marking 🟢 Complete:
- [ ] Component behavior tested (happy path + error cases)
- [ ] E2E tests exist and pass (`npx playwright test`)
- [ ] Accessibility verified (keyboard nav, screen reader, contrast)
- [ ] Responsive design tested (mobile, tablet, desktop)
- [ ] Loading states implemented
- [ ] Error states implemented with recovery
- [ ] Visual validation with Playwright MCP (screenshots)
- [ ] Unit tests passing: `npm test`
- [ ] All 10 UI/UX principles followed

## See Also

- `.claude/rules/gco-ui-design-standards.md` - Auto-enforced UI design standards
- `.haunt/checklists/ui-generation-checklist.md` - Detailed validation checklist
- `.haunt/docs/research/req-252-ui-ux-summary.md` - Full research report
- `gco-playwright-tests` skill - E2E test generation patterns
- `gco-ui-testing` skill - UI testing protocol with user journey mapping
