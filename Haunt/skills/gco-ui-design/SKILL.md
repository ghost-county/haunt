---
name: gco-ui-design
description: Comprehensive UI/UX design standards for frontend work. Invoke when generating UI components, creating layouts, or implementing visual elements. Contains 10 mandatory standards (8px grid, contrast ratios, interactive states, touch targets, accessibility).
---

# UI Design Standards

This skill provides comprehensive UI/UX design principles for Frontend Mode work.

## Core Principle

**Consistency over creativity. Accessibility over aesthetics. User experience over developer convenience.**

AI-generated UIs commonly fail in 3 areas:
1. **Inconsistent spacing** - Arbitrary values instead of systematic grid
2. **Missing states** - Only default state defined, no hover/focus/disabled
3. **Accessibility gaps** - Poor contrast, no keyboard navigation, missing semantics

This skill prevents those failures through mandatory checks and standards.

## Auto-Enforced Standards

### 1. 8px Grid System (REQUIRED)

**Rule:** ALL spacing MUST use 8px increments.

**Why:** Creates visual consistency, aligns with pixel density, works across devices.

**Implementation:**
- Base unit: 8px
- Scale: 8, 16, 24, 32, 40, 48, 56, 64, 72, 80...
- Fine-tuning: 4px allowed ONLY for icon alignment or optical balance
- NEVER: 10px, 15px, 20px, 25px, 30px (arbitrary values)

**Examples:**

```css
/* CORRECT */
.card {
  padding: 24px;        /* 8 × 3 */
  margin-bottom: 32px;  /* 8 × 4 */
  gap: 16px;            /* 8 × 2 */
}

.button {
  padding: 12px 24px;   /* Vertical 12px (fine-tuning), Horizontal 24px */
}

/* WRONG */
.card {
  padding: 20px;        /* Not divisible by 8 */
  margin-bottom: 30px;  /* Arbitrary value */
  gap: 15px;            /* Inconsistent */
}
```

**Tailwind Utilities (Correct):**
- `p-2` (8px), `p-4` (16px), `p-6` (24px), `p-8` (32px)
- `m-3` (12px - fine-tuning acceptable), `m-4` (16px), `m-6` (24px)
- `gap-2` (8px), `gap-4` (16px), `gap-6` (24px)

**Enforcement:** Before outputting CSS/JSX, verify all spacing values are 8px multiples (or 4px for fine-tuning).

---

### 2. 4.5:1 Contrast Minimum (REQUIRED)

**Rule:** Text on background MUST have 4.5:1 contrast ratio minimum (WCAG AA).

**Why:** Ensures readability for users with low vision, color blindness, or bright sunlight conditions.

**Implementation:**
- Body text: 4.5:1 minimum (WCAG AA)
- Large text (18px+ or 14px+ bold): 3:1 minimum
- Preferred: 7:1 (WCAG AAA) for better accessibility
- Check BEFORE outputting: Use WebAIM Contrast Checker or browser DevTools

**Examples:**

```css
/* CORRECT (4.5:1 minimum) */
.text-primary {
  color: #1F2937;        /* Dark gray on white: 12.6:1 ✓ */
  background: #FFFFFF;
}

.text-link {
  color: #1E40AF;        /* Blue on white: 8.6:1 ✓ */
}

/* WRONG (poor contrast) */
.text-muted {
  color: #D1D5DB;        /* Light gray on white: 1.8:1 ✗ FAIL */
  background: #FFFFFF;
}

.text-error {
  color: #FCA5A5;        /* Light red on white: 2.3:1 ✗ FAIL */
  background: #FFFFFF;
}
```

**Enforcement:**
1. When choosing colors, state the contrast ratio in comments
2. Never output light gray (#D1D5DB) on white backgrounds
3. Use online checker if uncertain: https://webaim.org/resources/contrastchecker/

---

### 3. 5 Interactive States (REQUIRED)

**Rule:** ALL interactive elements MUST define 5 states: default, hover, active, focus, disabled.

**Why:** Provides visual feedback for user interactions, clarifies element state, meets accessibility standards.

**Implementation:**

```css
/* CORRECT - All 5 states defined */
.button {
  /* 1. Default */
  background: var(--color-primary);
  color: white;
  cursor: pointer;

  /* 2. Hover */
  &:hover {
    background: var(--color-primary-dark);
    transform: translateY(-1px);
  }

  /* 3. Active (pressed) */
  &:active {
    background: var(--color-primary-darker);
    transform: translateY(0);
  }

  /* 4. Focus (keyboard navigation) */
  &:focus-visible {
    outline: 3px solid var(--color-focus);
    outline-offset: 2px;
  }

  /* 5. Disabled */
  &:disabled {
    background: var(--color-gray-300);
    color: var(--color-gray-500);
    cursor: not-allowed;
    opacity: 0.6;
  }
}

/* WRONG - Only default state */
.button {
  background: blue;
  color: white;
}
```

**Enforcement:** Before outputting interactive component code, verify all 5 states are explicitly defined.

---

### 4. 44×44px Touch Targets (REQUIRED)

**Rule:** ALL clickable/tappable elements MUST be 44×44px minimum.

**Why:** Fitts's Law - larger targets are easier to click. Mobile touch requires minimum target size.

**Implementation:**

```css
/* CORRECT */
.button {
  min-width: 44px;
  min-height: 44px;
  padding: 12px 24px;   /* Ensures 44px height with text */
}

.icon-button {
  width: 48px;          /* Preferred: 48×48px */
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* WRONG */
.icon-button {
  width: 24px;          /* Too small for touch */
  height: 24px;
  padding: 4px;
}
```

**Enforcement:** Before outputting buttons, links, or icons, verify minimum 44×44px size (48×48px preferred).

---

### 5. Skip Links (REQUIRED)

**Rule:** Every page layout MUST include skip-to-content link.

**Why:** Keyboard users can skip repetitive navigation, screen reader users save time.

**Implementation:**

```html
<!-- CORRECT -->
<body>
  <a href="#main-content" class="skip-link">Skip to main content</a>

  <header>
    <nav>...</nav>
  </header>

  <main id="main-content">
    <!-- Page content -->
  </main>
</body>
```

```css
/* Skip link styling (visible on focus) */
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: var(--color-primary);
  color: white;
  padding: 8px 16px;
  text-decoration: none;
  z-index: 100;
}

.skip-link:focus {
  top: 0;
}
```

**Enforcement:** When creating page layouts, include skip link BEFORE header/nav.

---

### 6. Semantic HTML First (REQUIRED)

**Rule:** Use semantic HTML elements BEFORE generic divs.

**Why:** Improves accessibility, SEO, maintainability. Screen readers understand semantic structure.

**Examples:**

```html
<!-- CORRECT -->
<button type="button">Click me</button>
<nav aria-label="Main navigation">...</nav>
<main>...</main>
<article>...</article>
<aside>...</aside>
<footer>...</footer>

<!-- WRONG -->
<div class="button" onclick="...">Click me</div>
<div class="nav">...</div>
<div class="main-content">...</div>
```

**Semantic Element Priority:**
1. `<button>` over `<div onclick>`
2. `<nav>` over `<div class="nav">`
3. `<main>` over `<div id="main">`
4. `<header>`, `<footer>`, `<article>`, `<section>`, `<aside>` over generic divs
5. `<h1>` - `<h6>` for headings (no `<div class="title">`)

**Enforcement:** Before outputting markup, check if a semantic element exists for the use case.

---

### 7. Inline Form Validation (REQUIRED)

**Rule:** ALL form fields MUST validate on blur with inline error messages.

**Why:** Immediate feedback reduces user frustration, catches errors before submission.

**Implementation:**

```html
<!-- CORRECT -->
<form>
  <div class="form-field">
    <label for="email">Email</label>
    <input
      type="email"
      id="email"
      aria-describedby="email-error"
      aria-invalid="false"
    />
    <span id="email-error" class="error-message" role="alert">
      <!-- Error shown on blur if invalid -->
    </span>
  </div>
</form>
```

```javascript
// Validate on blur (not just submit)
emailInput.addEventListener('blur', () => {
  if (!isValidEmail(emailInput.value)) {
    emailInput.setAttribute('aria-invalid', 'true');
    errorMessage.textContent = 'Please enter a valid email address';
    errorMessage.style.display = 'block';
  }
});
```

**Error Message Requirements:**
- Show WHAT is wrong: "Email is required" not "Invalid input"
- Show HOW to fix: "Password must be 8+ characters" not "Invalid password"
- Use `role="alert"` for screen readers
- Red color MUST have 4.5:1 contrast

**Enforcement:** When creating forms, include blur validation handlers and ARIA attributes.

---

### 8. Mobile-First Responsive (REQUIRED)

**Rule:** Start with mobile layout (320px), enhance for desktop.

**Why:** Ensures mobile usability, forces prioritization, reduces CSS complexity.

**Implementation:**

```css
/* CORRECT - Mobile first */
.container {
  padding: 16px;           /* Mobile default */
  width: 100%;
}

@media (min-width: 768px) {
  .container {
    padding: 32px;         /* Tablet enhancement */
    max-width: 768px;
  }
}

@media (min-width: 1024px) {
  .container {
    padding: 48px;         /* Desktop enhancement */
    max-width: 1200px;
  }
}

/* WRONG - Desktop first */
.container {
  padding: 48px;           /* Desktop default */
  max-width: 1200px;
}

@media (max-width: 1024px) {
  .container {
    padding: 32px;         /* Undoing desktop styles */
  }
}
```

**Breakpoints (Standard):**
- Mobile: 320px - 767px (default styles)
- Tablet: 768px - 1023px (`@media (min-width: 768px)`)
- Desktop: 1024px+ (`@media (min-width: 1024px)`)

**Enforcement:** When writing responsive CSS, start with mobile styles, use `min-width` media queries.

---

### 9. Focus Indicators (REQUIRED)

**Rule:** ALL interactive elements MUST have visible focus outline (3px minimum).

**Why:** Keyboard users need to see which element has focus.

**Implementation:**

```css
/* CORRECT */
button:focus-visible,
a:focus-visible,
input:focus-visible {
  outline: 3px solid var(--color-focus);   /* Minimum 3px */
  outline-offset: 2px;
}

/* Use focus-visible (not :focus) to avoid mouse focus outline */
button:focus-visible {
  outline: 3px solid #3B82F6;
  outline-offset: 2px;
}

/* WRONG */
button:focus {
  outline: none;          /* NEVER remove outline without replacement */
}
```

**Enforcement:** Never output `outline: none` without a custom focus indicator. Always use `:focus-visible`.

---

### 10. Design Tokens (REQUIRED)

**Rule:** Use CSS variables/theme tokens, NEVER hardcoded hex colors.

**Why:** Enables theming, dark mode, brand consistency, easier maintenance.

**Implementation:**

```css
/* CORRECT - Design tokens */
:root {
  --color-primary: #3B82F6;
  --color-primary-dark: #2563EB;
  --color-gray-50: #F9FAFB;
  --color-gray-900: #111827;
  --spacing-2: 8px;
  --spacing-4: 16px;
  --spacing-6: 24px;
}

.button {
  background: var(--color-primary);
  padding: var(--spacing-3) var(--spacing-6);
  color: var(--color-white);
}

/* WRONG - Hardcoded values */
.button {
  background: #3B82F6;
  padding: 12px 24px;
  color: #FFFFFF;
}
```

**Required Tokens:**
- Colors: primary, secondary, error, success, warning, gray scale
- Spacing: 2, 4, 6, 8, 10, 12, 16 (8px scale)
- Typography: font-family, font-size, line-height
- Shadows: elevation levels

**Enforcement:** Before outputting CSS, verify all colors and spacing use token variables.

---

## Validation Workflow

### Before Writing UI Code

- [ ] Spacing grid defined (8px base)
- [ ] Color palette checked for 4.5:1 contrast
- [ ] Interactive states documented (5 states)
- [ ] Touch targets sized (44×44px minimum)
- [ ] Semantic HTML structure planned
- [ ] Skip links included
- [ ] Form validation strategy defined
- [ ] Responsive breakpoints planned

### During Code Generation

- [ ] Use design tokens (no hardcoded hex/px values)
- [ ] Check contrast ratio (state in comments if uncertain)
- [ ] Define all 5 interactive states explicitly
- [ ] Size touch targets (44×44px minimum)
- [ ] Use semantic HTML elements

### After Code Generation

- [ ] All spacing divisible by 8 (or 4 for fine-tuning)
- [ ] Contrast verified with online checker
- [ ] All 5 states defined and visible
- [ ] Touch targets measured (44×44px minimum)
- [ ] Keyboard navigation tested (Tab, Enter, Esc)
- [ ] Color blindness tested (grayscale mode)
- [ ] Focus indicators visible (3px outline minimum)
- [ ] Skip links functional
- [ ] Mobile layout tested (320px width)

## Quick Reference

| Standard | Minimum | Preferred |
|----------|---------|-----------|
| **Spacing** | 8px increments | 8px base, 4px fine-tuning only |
| **Contrast** | 4.5:1 (WCAG AA) | 7:1 (WCAG AAA) |
| **Touch Targets** | 44×44px | 48×48px |
| **Focus Outline** | 3px | 3-4px with offset |
| **Mobile Width** | 320px tested | 375px optimized |
| **Interactive States** | 5 (default/hover/active/focus/disabled) | + loading state |

## Non-Negotiable Rules

1. **NEVER output UI code without checking contrast** - Poor contrast = accessibility violation
2. **NEVER use arbitrary spacing** - 8px grid is mandatory, not optional
3. **NEVER define only default state** - All 5 states required for interactive elements
4. **NEVER use `<div onclick>`** - Use semantic `<button>` element
5. **NEVER remove focus outline** without custom indicator - Keyboard users need focus visibility
6. **NEVER hardcode colors** - Use design tokens for themability
7. **NEVER skip skip links** - Required for keyboard accessibility

## See Also

- `.haunt/checklists/ui-generation-checklist.md` - Detailed validation checklist
- `.haunt/docs/research/req-252-ui-ux-summary.md` - Research report
- `Haunt/agents/gco-dev.md` - Dev agent Frontend Mode guidance
