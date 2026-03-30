#!/usr/bin/env bash
# Copies configs of agents, MCPs, and shadcn to the current Next.js project.
# Can be run from the root of the Starter Kit or from the target project.
# =============================================================================

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}ℹ${RESET}  $*"; }
success() { echo -e "${GREEN}✓${RESET}  $*"; }
warn()    { echo -e "${YELLOW}⚠${RESET}  $*"; }
error()   { echo -e "${RED}✗${RESET}  $*"; exit 1; }
ask()     { echo -e "${CYAN}?${RESET}  $*"; }
step()    { echo -e "\n${BOLD}${BLUE}▶ $*${RESET}"; }

# ── Starter kit location ──────────────────────────────────────────────────────
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]:-}" && "$(basename "${BASH_SOURCE[0]}")" == "setup.sh" ]]; then
  # LOCAL execution from the kit
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  KIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  # Remote execution
  KIT_REPO="https://github.com/betcorg/next-shadcn-sk.git"
  TEMP_KIT_DIR="/tmp/next-shadcn-starter-kit-$(date +%s)"
  
  step "Downloading Starter Kit from GitHub"
  info "Cloning into: $TEMP_KIT_DIR"
  
  if ! command -v git &>/dev/null; then
    error "'git' is required to automatically download the kit."
  fi

  git clone --depth 1 "$KIT_REPO" "$TEMP_KIT_DIR" &>/dev/null || error "Failed to clone the kit from $KIT_REPO"
  
  KIT_ROOT="$TEMP_KIT_DIR/src"
  
  # Automatic cleanup on exit or failure
  trap 'rm -rf "$TEMP_KIT_DIR"' EXIT
  
  success "Kit downloaded successfully"
fi

PROJECT_ROOT="$(pwd)"

# ── Smart project detection ────────────────────────────────────────────────────
# If we are at the root of the Starter Kit (where .git and src folder are),
# try to locate the Next.js project the user initialized.
if [[ -d "$PROJECT_ROOT/src" && -f "$PROJECT_ROOT/src/scripts/setup.sh" && ! -f "$PROJECT_ROOT/package.json" ]]; then
  step "Detecting project inside the Starter Kit"
  
  # Search directories that have package.json and are not 'src'
  EXCLUDE_DIRS=("src" "." "..")
  PROJECTS=()
  
  for dir in */; do
    dir=${dir%/}
    if [[ ! " ${EXCLUDE_DIRS[@]} " =~ " ${dir} " ]] && [[ -f "$dir/package.json" ]]; then
      PROJECTS+=("$dir")
    fi
  done

  if [[ ${#PROJECTS[@]} -eq 1 ]]; then
    PROJECT_ROOT="$(cd "${PROJECTS[0]}" && pwd)"
    info "Project automatically detected: ${PROJECTS[0]}"
  elif [[ ${#PROJECTS[@]} -gt 1 ]]; then
    echo "Multiple projects detected in the root:"
    for i in "${!PROJECTS[@]}"; do
      echo "  $((i+1))) ${PROJECTS[$i]}"
    done
    ask "Select the project to configure [1-${#PROJECTS[@]}]:"
    read -r P_CHOICE
    if [[ "$P_CHOICE" =~ ^[0-9]+$ ]] && [ "$P_CHOICE" -ge 1 ] && [ "$P_CHOICE" -le "${#PROJECTS[@]}" ]; then
      PROJECT_ROOT="$(cd "${PROJECTS[$((P_CHOICE-1))]}" && pwd)"
    else
      error "Invalid selection."
    fi
  else
    error "No Next.js project found in the Starter Kit subfolders. Make sure you have initialized it first."
  fi
fi

# ── Final project validations ──────────────────────────────────────────────────
step "Validating environment"

if [[ ! -f "$PROJECT_ROOT/package.json" ]]; then
  error "package.json not found in $PROJECT_ROOT. Run this script from your Next.js project root or from the Starter Kit root with the project already created."
fi

if ! grep -q '"next"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
  warn "Next.js not detected in package.json. Make sure you are in the correct project."
  ask "Continue anyway? [y/N]"
  read -r CONTINUE
  [[ "$CONTINUE" =~ ^[yY]$ ]] || exit 0
fi

success "Next.js project detected at: $PROJECT_ROOT"

# ── Package manager ───────────────────────────────────────────────────────────
step "Selecting package manager"
echo "  1) pnpm  (recommended)"
echo "  2) npm"
echo "  3) yarn"
echo "  4) bun"
ask "Select your package manager [1-4, default: 1]:"
read -r PM_CHOICE

case "${PM_CHOICE:-1}" in
  1) PKG_MANAGER="pnpm";;
  2) PKG_MANAGER="npm";;
  3) PKG_MANAGER="yarn";;
  4) PKG_MANAGER="bun";;
  *) warn "Invalid option, using pnpm"; PKG_MANAGER="pnpm";;
esac

success "Package manager: $PKG_MANAGER"

# ── shadcnstudio license ──────────────────────────────────────────────────────
step "License configuration"
ask "Do you have a Pro license from shadcnstudio.com? [y/N]:"
read -r HAS_SS_PRO

SS_PRO=false
SS_EMAIL=""
SS_LICENSE_KEY=""

if [[ "$HAS_SS_PRO" =~ ^[yY]$ ]]; then
  SS_PRO=true
  ask "Your shadcnstudio account email:"
  read -r SS_EMAIL
  ask "License Key (from shadcnstudio.com/billing):"
  read -r SS_LICENSE_KEY
  success "Credentials received"
else
  info "Using Free configuration"
fi

# ── Project name ──────────────────────────────────────────────────────────────
PROJECT_NAME=$(basename "$PROJECT_ROOT")
ask "Project name [default: $PROJECT_NAME]:"
read -r INPUT_NAME
PROJECT_NAME="${INPUT_NAME:-$PROJECT_NAME}"

# ── Copy Claude Code configuration ────────────────────────────────────────────
step "Configuring Claude Code (.claude/)"

if [[ -d "$KIT_ROOT/.claude" ]]; then
  cp -r "$KIT_ROOT/.claude" "$PROJECT_ROOT/"
  success "Folder .claude/ copied to project root"
else
  warn "Folder .claude/ not found in the starter kit"
fi

# ── Configure MCP (.mcp.json) ──────────────────────────────────────────────────
step "Configuring MCPs (.mcp.json)"

if [[ "$SS_PRO" == true ]]; then
  MCP_SRC="$KIT_ROOT/configs/mcp/.mcp.json.pro.template"
else
  MCP_SRC="$KIT_ROOT/configs/mcp/.mcp.json.free.template"
fi

MCP_DEST="$PROJECT_ROOT/.mcp.json"

if [[ -f "$MCP_SRC" ]]; then
  cp "$MCP_SRC" "$MCP_DEST"
  success ".mcp.json configured (using $([ "$SS_PRO" = true ] && echo 'Pro' || echo 'Free') template)"
else
  warn "MCP template not found ($MCP_SRC), skipping"
fi

# ── Update components.json (Registries) ───────────────────────────────────────
step "Configuring shadcn Registries"

COMP_DEST="$PROJECT_ROOT/components.json"

if [[ -f "$COMP_DEST" ]]; then
  if [[ "$SS_PRO" == true ]]; then
    REG_SRC="$KIT_ROOT/configs/registries/pro_registries.template"
  else
    REG_SRC="$KIT_ROOT/configs/registries/free_registries.template"
  fi

  if [[ -f "$REG_SRC" ]]; then
    # Read registries content and escape for sed
    REG_CONTENT=$(cat "$REG_SRC")
    # Use a temporary file to build the new JSON
    sed -e "/\"registries\": {}/r $REG_SRC" -e "/\"registries\": {}/d" "$COMP_DEST" > "${COMP_DEST}.tmp"
    mv "${COMP_DEST}.tmp" "$COMP_DEST"
    success "shadcn registries updated in components.json"
  else
    warn "Registries file not found: $REG_SRC"
  fi
else
  warn "components.json not found in the project. Have you run 'shadcn init' yet?"
fi

# ── Generate .env (Pro only) ───────────────────────────────────────────────────
step "Generating .env"

ENV_DEST="$PROJECT_ROOT/.env"

if [[ "$SS_PRO" == true ]]; then
  ENV_SRC="$KIT_ROOT/configs/.env.example"
  if [[ -f "$ENV_SRC" ]]; then
    cp "$ENV_SRC" "$ENV_DEST"
    # Replace placeholders in .env
    sed -i.bak "s|{{SS_EMAIL}}|$SS_EMAIL|g" "$ENV_DEST"
    sed -i.bak "s|{{SS_LICENSE_KEY}}|$SS_LICENSE_KEY|g" "$ENV_DEST"
    rm -f "${ENV_DEST}.bak"
    success ".env generated with your Pro credentials"
  else
    warn ".env.example not found in the starter kit"
  fi
else
  info "Free user: no .env file with credentials required"
fi

# Add project name at the end of .env if it exists or create it if it doesn't
if [[ ! -f "$ENV_DEST" ]]; then touch "$ENV_DEST"; fi
if ! grep -q "^PROJECT_NAME=" "$ENV_DEST" 2>/dev/null; then
  echo "PROJECT_NAME=$PROJECT_NAME" >> "$ENV_DEST"
fi
success "PROJECT_NAME variable set in .env"

# ── Generate CLAUDE.md ────────────────────────────────────────────────────────
step "Generating CLAUDE.md"

CLAUDE_SRC="$KIT_ROOT/CLAUDE.md"
CLAUDE_DEST="$PROJECT_ROOT/CLAUDE.md"

if [[ -f "$CLAUDE_SRC" ]]; then
  if [[ -f "$CLAUDE_DEST" ]]; then
    warn "CLAUDE.md already exists."
    ask "Overwrite? [y/N]:"
    read -r OW_CLAUDE
    [[ "$OW_CLAUDE" =~ ^[yY]$ ]] || { info "CLAUDE.md preserved"; SKIP_CLAUDE=true; }
  fi

  if [[ "${SKIP_CLAUDE:-false}" != true ]]; then
    # Replace generic placeholders
    sed "s|{{PROJECT_NAME}}|$PROJECT_NAME|g; s|{{PKG_MANAGER}}|$PKG_MANAGER|g" \
      "$CLAUDE_SRC" > "$CLAUDE_DEST"
    success "CLAUDE.md generated for: $PROJECT_NAME"
  fi
fi

# ── Copy AGENTS.md ─────────────────────────────────────────────────────────────
AGENTS_SRC="$KIT_ROOT/AGENTS.md"
AGENTS_DEST="$PROJECT_ROOT/AGENTS.md"

if [[ -f "$AGENTS_SRC" ]]; then
  cp "$AGENTS_SRC" "$AGENTS_DEST"
  success "AGENTS.md copied"
fi

# ── Configure next.config.mjs ──────────────────────────────────────────────────
step "Configuring next.config.mjs"

NEXT_CONFIG_SRC="$KIT_ROOT/configs/next-config/next.config.template"
NEXT_CONFIG_DEST="$PROJECT_ROOT/next.config.mjs"

if [[ -f "$NEXT_CONFIG_SRC" ]]; then
  cp "$NEXT_CONFIG_SRC" "$NEXT_CONFIG_DEST"
  success "next.config.mjs updated"
else
  warn "next.config.template not found"
fi

# ── Check .gitignore ───────────────────────────────────────────────────────────
step "Checking .gitignore"

GITIGNORE="$PROJECT_ROOT/.gitignore"
touch "$GITIGNORE"

add_gitignore() {
  grep -qxF "$1" "$GITIGNORE" || echo "$1" >> "$GITIGNORE"
}

add_gitignore ".env"
add_gitignore ".env.local"
add_gitignore ".env.*.local"

success "Credentials protected"

# ── Check .next-docs ───────────────────────────────────────────────────────────
step "Installing Next-docs"

# Extract Next.js version from package.json
NEXT_VERSION=$(grep '"next":' "$PROJECT_ROOT/package.json" | head -1 | sed -E 's/.*"next": *"([^"]+)".*/\1/' | sed 's/^[~^]//' || echo "")

if [[ -z "$NEXT_VERSION" ]]; then
  warn "Could not detect Next.js version in package.json. Continuing with --version 16.1.7."
  VERSION_FLAG="--version 16.1.7"
else
  info "Detected Next.js version: $NEXT_VERSION"
  VERSION_FLAG="--version $NEXT_VERSION"
fi

cd $PROJECT_ROOT

if [[ "$PKG_MANAGER" == "npm" ]]; then
  npx @next/codemod@canary agents-md $VERSION_FLAG --output AGENTS.md
else
  $PKG_MANAGER dlx @next/codemod@canary agents-md $VERSION_FLAG --output AGENTS.md
fi

success "Next-docs installed"

# ── Summary ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════${RESET}"
echo -e "${BOLD}${GREEN}  Setup completed for: $PROJECT_NAME${RESET}"
echo -e "${BOLD}${GREEN}═══════════════════════════════════════════${RESET}"
