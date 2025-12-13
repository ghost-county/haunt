---
name: gco-context7-usage
description: Provides guidance on when and how to use Context7 for official documentation lookup. Invoke when needing framework docs, API references, or library documentation.
---

# Context7 Usage: Documentation Lookup

## Purpose

Context7 is a documentation lookup tool that provides access to **official documentation** for frameworks, libraries, and APIs. It specializes in authoritative, maintained sources - not tutorials, blog posts, or general web content.

## When to Use Context7

Use Context7 when you need:
- **Official API documentation** (e.g., React API, Django REST Framework)
- **Framework reference guides** (e.g., Next.js routing, FastAPI schemas)
- **Library usage patterns** (e.g., Pandas DataFrame methods, Playwright selectors)
- **Configuration specifications** (e.g., TypeScript tsconfig, Webpack config)
- **Language standard library docs** (e.g., Python stdlib, Go packages)

## When NOT to Use Context7

Do **not** use Context7 for:
- **Tutorials or how-to guides** (use WebSearch instead)
- **Blog posts or articles** (use WebSearch instead)
- **Community discussions** (use WebSearch for Stack Overflow, Reddit, etc.)
- **Code examples from projects** (use Grep/Read on local codebase)
- **Opinions or comparisons** (use WebSearch for reviews, benchmarks)

## Query Format

Structure queries as: **[Framework/Library Name] + [Specific Topic]**

### Good Query Examples

```
react hooks useEffect
django queryset filtering
pytest fixtures
fastapi dependency injection
typescript generics
playwright locators
tailwind responsive design
next.js app router
```

### Bad Query Examples

```
how to build a todo app in react                    # Too broad, tutorial-like
best practices for django                            # Opinion-based
react vs vue                                         # Comparison, not docs
stack overflow react hooks error                     # Community content
awesome python libraries                             # Curated list, not docs
```

## Limitations

Context7 has important constraints:
- **Official docs only**: No community tutorials or blog content
- **No outdated versions**: May not have older library versions
- **No niche libraries**: Coverage limited to popular frameworks
- **No custom/proprietary**: Cannot access internal company docs

## Fallback Strategy

If Context7 cannot find documentation:
1. Use WebSearch for tutorials or community resources
2. Check the project's GitHub repository directly (Read tool)
3. Search local codebase for usage examples (Grep tool)
4. Ask human for internal documentation location

## Success Criteria

Effective Context7 usage means:
- Querying with specific framework + topic format
- Recognizing when official docs vs tutorials are needed
- Using WebSearch as fallback for non-official content
- Avoiding generic or opinion-based queries
