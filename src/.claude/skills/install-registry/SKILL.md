---
description: Installs a component from any shadcn registry (official, shadcn/studio, or third parties) and places it in the correct project directory.
argument-hint: <namespace/component-name>
---

# /install-registry — Install from registry

Installs components or blocks from any shadcn registry and places them  
in the appropriate layer of the project.

## Namespace and Destination Table

| Namespace           | Command                                      | Destination                          |
|---------------------|----------------------------------------------|------------------------------------|
| Official shadcn/ui  | `npx shadcn@latest add [name]`                | `components/ui/`                   |
| `@shadcn-studio`    | `npx shadcn@latest add @shadcn-studio/[name]`| `components/registry/shadcn-studio/` |
| `@ss-components`    | `npx shadcn@latest add @ss-components/[name]`| `components/registry/shadcn-studio/` |
| `@ss-blocks`        | `npx shadcn@latest add @ss-blocks/[name]`    | `components/registry/shadcn-studio/` |
| `@ss-themes`        | `npx shadcn@latest add @ss-themes/[name]`    | `styles/`                         |
| Custom registries   | `npx shadcn@latest add @<ns>/[name]`          | `components/registry/<ns>/`       |

## Process

1. Identify the namespace of the component to install.  
2. If it is Pro (shadcn/studio), verify `.env` contains `EMAIL` and `LICENSE_KEY`.  
3. Run the corresponding install command from the table.  
4. Confirm the component was placed in the correct directory.  
   If the CLI placed it elsewhere, move it manually to the correct destination.  
5. Review generated imports — fix paths with `@/` aliases if needed.  
6. Fix linting errors before proceeding.  
7. Report what was installed, where it was placed, and which dependencies were added to the project.

## Critical Post-Installation Rule

Components in `components/ui/` and `components/registry/` are **read-only**.  
If the project needs to modify behavior or styles of an installed component,  
create a wrapper inside `components/extended/` — never edit the original files.

## Common Errors and Solutions

| Error             | Likely Cause           | Solution                                  |
|-------------------|-----------------------|-------------------------------------------|
| "Block not found"  | Incorrect name        | Verify exact name at shadcnstudio.com/blocks |
| "Access denied"   | Missing Pro credentials | Check `EMAIL` and `LICENSE_KEY` in `.env` |
| Broken imports    | Alias not configured  | Verify `paths` in `tsconfig.json`         |
| CLI installed in wrong place | `components.json` config | Move manually to the correct destination   |