# UI Design Standards (Slim Reference)

## Core Principle

**Consistency over creativity. Accessibility over aesthetics. User experience over developer convenience.**

## 10 Mandatory Standards (Quick Checklist)

When generating UI, verify:

1. **8px Grid** - ALL spacing uses 8px increments (16, 24, 32, etc.; 4px for fine-tuning only)
2. **4.5:1 Contrast** - Text meets WCAG AA minimum contrast ratio
3. **5 Interactive States** - Define default, hover, active, focus, disabled for ALL interactive elements
4. **44×44px Touch Targets** - Minimum clickable/tappable size (48×48px preferred)
5. **Skip Links** - Include skip-to-content link before header/nav
6. **Semantic HTML** - Use `<button>`, `<nav>`, `<main>`, etc. over generic divs
7. **Inline Form Validation** - Validate on blur with clear error messages
8. **Mobile-First Responsive** - Start with 320px width, enhance for desktop
9. **Focus Indicators** - 3px minimum outline on :focus-visible
10. **Design Tokens** - Use CSS variables, never hardcoded hex colors

## When to Invoke Full Skill

For detailed guidance on any standard, examples, enforcement patterns, and validation workflows:

**Invoke:** `/gco-ui-design` skill

The skill contains:
- Complete examples for each standard (correct vs wrong)
- Enforcement strategies (when/how to check)
- Validation checklists (before/during/after code generation)
- Quick reference tables
- See Also references for deeper resources

## Non-Negotiable

- NEVER skip standards "because it's simple UI"
- NEVER output UI without checking contrast ratios
- NEVER define only default state (all 5 states required)
- NEVER use arbitrary spacing (8px grid is mandatory)
