---
paths:
  - "components/**"
---

# Component Architecture

## Layers and Their Responsibilities

| Directory | Content | Editable? |
|-----------|---------|-----------|
| `components/ui/` | shadcn/ui primitives (Button, Input, Card…) | No — read-only |
| `components/registry/<ns>/` | Components from external registries | No — read-only |
| `components/extended/` | Wrappers/extensions of `ui/` or `registry/` | Yes |
| `components/features/` | Components with business logic | Yes |
| `components/blocks/` | Pure presentational compositions | Yes |
| `components/layout/` | App shell: Header, Sidebar, Footer | Yes |

## Decision Tree — Which Layer Does the Component Belong To?

```
Is it a light adaptation of ui/ or registry/?
  └─ Yes → components/extended/

Is it a presentational section without business logic (props only)?
  └─ Yes → components/blocks/

Does it have fetches, auth state, stores, or domain logic?
  └─ Yes → components/features/

Is it Header, Sidebar, Footer, or the app shell?
  └─ Yes → components/layout/
```

## Critical Difference: blocks/ vs features/

- `blocks/` is domain-agnostic: receives everything via props and could be reused
  in another project without changes.
- `features/` knows the domain: it can have API calls, global state,
  auth context, or other business-coupled logic.

## Modification Rules

1. Never edit `components/ui/` or `components/registry/` — they are read-only.
2. To modify a base component → create a wrapper in `components/extended/`.
3. Always extend the base component’s props (`ComponentProps<typeof Base>`).
4. Use `cn()` from `@/lib/utils` for all class composition.
5. Named exports in all components (no default export except for pages and layouts).