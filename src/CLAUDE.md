# {{PROJECT_NAME}}

Project context for Claude Code. Read this file at the start of each session.

## Tech stack

- **Framework**: Next.js 16.2 (App Router, Turbopack)  
- **UI**: shadcn/ui (CLI v4) + shadcn/studio Pro + React Bits  
- **Styling**: Tailwind CSS v4 (CSS-first via `@theme`)  
- **Language**: Strict TypeScript  
- **Package manager**: {{PKG_MANAGER}}  

## Component architecture

```
components/
├── ui/                    # shadcn/ui base — CLI-installed, NEVER edit
├── registry/
│   └── shadcn-studio/     # @ss-components, @ss-blocks — raw install, NEVER edit
├── extended/              # Custom wrappers extending ui/ or registry/
├── features/              # Components coupled to business logic
├── blocks/                # Presentational compositions (hero, pricing, etc.)
└── layout/                # App shell: Header, Sidebar, Footer
```

## Available MCPs

- **shadcn**: official shadcn/ui registry  
- **shadcn-studio**: Pro library from shadcnstudio.com  
- **next-devtools**: Next.js runtime diagnostics  

Check they are active with `/mcp` before using them.

## Available skills

| Skill               | Purpose                                   |
|---------------------|-------------------------------------------|
| `/cui`              | Create UI from shadcn/studio blocks       |
| `/iui`              | Generate creative UI (Pro only)            |
| `/rui`              | Refine existing block                      |
| `/new-component`    | Create a custom component in the correct layer |
| `/install-registry` | Install from any registry with verification |

## Component installation

```bash
# official shadcn/ui → components/ui/
npx shadcn@latest add [name]

# shadcn/studio → components/registry/shadcn-studio/
npx shadcn@latest add @shadcn-studio/[name]
npx shadcn@latest add @ss-components/[name]
npx shadcn@latest add @ss-blocks/[name]
```

## Before writing Next.js code

Always read the local docs in `.next-docs` before  
implementing any routing, caching, or rendering feature.  
Your training knowledge may be outdated.

## Reference documentation

- Project methodology: `docs/`  
- shadcn/ui: https://ui.shadcn.com/docs  
- shadcn/studio: https://shadcnstudio.com/docs  
- Next.js: https://nextjs.org/docs  

@AGENTS.md