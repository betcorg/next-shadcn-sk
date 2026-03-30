---
description: Creates a custom component respecting the project's layered architecture. Use this when the user requests to create a custom component, a wrapper, or a business composition from scratch.
argument-hint: <component name and description>
---

# /new-component — Create custom component

Guided flow to create a new component in the correct project layer.

## Step 1 — Determine the layer

Before writing any code, answer these questions:

- Is it a light adaptation of a component from `ui/` or `registry/`? → `components/extended/`  
- Is it a presentational section or block without business logic (receives everything via props)? → `components/blocks/`  
- Does it have fetches, auth state, stores, or domain-coupled logic? → `components/features/`  
- Is it Header, Sidebar, Footer, or any app shell element? → `components/layout/`  

## Step 2 — Create the file

Use the templates below according to the chosen layer.

### Template for `extended/`

```tsx
import { ComponentProps } from "react"
import { [ComponentBase] } from "@/components/ui/[component]"
import { cn } from "@/lib/utils"

interface [ComponentName]Props extends ComponentProps<typeof [ComponentBase]> {
  // Additional project-specific props
}

export function [ComponentName]({ className, ...props }: [ComponentName]Props) {
  return (
    <[ComponentBase]
      className={cn("[css-token-classes]", className)}
      {...props}
    />
  )
}
```

### Template for `blocks/` (Server Component by default)

```tsx
interface [BlockName]Props {
  // Explicit props — no domain dependencies
  title: string
  description?: string
}

export function [BlockName]({ title, description }: [BlockName]Props) {
  return (
    <section className="...">
      <h2>{title}</h2>
      {description && <p>{description}</p>}
    </section>
  )
}
```

### Template for `features/` (Client Component if interactive)

```tsx
// Add "use client" ONLY if component uses hooks, event handlers, or browser APIs
import { cn } from "@/lib/utils"

export function [FeatureName]() {
  // Business logic: fetches, auth, stores, etc.
  return (
    <div>
      {/* content */}
    </div>
  )
}
```

### Template for `layout/`

```tsx
import { type ReactNode } from "react"

interface [LayoutComponent]Props {
  children?: ReactNode
}

export function [LayoutComponent]({ children }: [LayoutComponent]Props) {
  return (
    <header className="...">
      {/* shell structure */}
      {children}
    </header>
  )
}
```

## Step 3 — Checklist before finishing

- [ ] Named export (no default export except Next.js pages and layouts)  
- [ ] Correct TypeScript — well-typed props, extending base props if applicable  
- [ ] `"use client"` only if using hooks, event handlers, or browser APIs  
- [ ] Classes use CSS tokens (`--brand-primary`, etc.), no hardcoded colors  
- [ ] Use `cn()` for conditional class composition  
- [ ] Use `cva()` if the component has multiple variants  
- [ ] Preserve ARIA attributes if wrapping a Radix primitive  
- [ ] No linting errors