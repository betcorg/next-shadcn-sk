# Registry Protocol

## Never Copy Code Manually

Always install via CLI. Copying code from documentation skips dependency resolution and can leave the project in an inconsistent state.

## Namespace and Destination Table

| Namespace | Install Command | Destination |
|-----------|-----------------|-------------|
| Official shadcn/ui | `npx shadcn@latest add [name]` | `components/ui/` |
| `@shadcn-studio` | `npx shadcn@latest add @shadcn-studio/[name]` | `components/registry/shadcn-studio/` |
| `@ss-components` | `npx shadcn@latest add @ss-components/[name]` | `components/registry/shadcn-studio/` |
| `@ss-blocks` | `npx shadcn@latest add @ss-blocks/[name]` | `components/registry/shadcn-studio/` |
| `@ss-themes` | `npx shadcn@latest add @ss-themes/[name]` | `styles/` |
| Own registries | `npx shadcn@latest add @<ns>/[name]` | `components/registry/<ns>/` |

If the CLI installs to an incorrect directory, manually move it to the table’s destination before continuing.

## Read-Only Rule

The directories `components/ui/` and `components/registry/` are **read-only**.  
To modify an installed component → create a wrapper in `components/extended/`.  
This separation allows updating the registry in the future without losing project-specific modifications.

## Pro Credentials (shadcn/studio)

- `EMAIL` and `LICENSE_KEY` only in `.env`. Never in code or comments.  
- `.env` is never committed. The CLI automatically reads them from environment variables at install time.

## Step-by-Step Installation Protocol

1. Verify that `components.json` is configured correctly.  
2. If Pro, confirm `.env` has `EMAIL` and `LICENSE_KEY`.  
3. Run the install command.  
4. Verify the component landed in the correct directory (see table above).  
5. Review generated imports — fix paths with `@/` alias if necessary.  
6. Fix linting errors before continuing.  
7. Report: what was installed, where it was placed, what dependencies were added.

## Common Errors

- **"Block not found"**: check the exact name at shadcnstudio.com/blocks.  
- **"Access denied"**: verify `EMAIL` and `LICENSE_KEY` in `.env`.  
- **Broken imports post-install**: check `@/` aliases in `tsconfig.json`.