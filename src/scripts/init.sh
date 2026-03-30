#!/usr/bin/env bash
# =============================================================================
# next-shadcn-starter-kit — init.sh
# Initializes a new Next.js project and then runs the setup.
# =============================================================================

set -euo pipefail

# ── Colors ─────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

# ── Helpers ────────────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}ℹ${RESET}  $*"; }
success() { echo -e "${GREEN}✓${RESET}  $*"; }
warn()    { echo -e "${YELLOW}⚠${RESET}  $*"; }
error()   { echo -e "${RED}✗${RESET}  $*"; exit 1; }
ask()     { echo -e "${CYAN}?${RESET}  $*"; }
step()    { echo -e "\n${BOLD}${BLUE}▶ $*${RESET}"; }

# ── Validations ───────────────────────────────────────────────────────────────
if [[ ! -d "src/scripts" ]]; then
  error "This script must be run from the root of the Starter Kit (where the 'src' folder is)."
fi

# ── Package manager selection ──────────────────────────────────────────────────
step "0. Selecting package manager"
echo "  1) pnpm  (recommended)"
echo "  2) npm"
echo "  3) yarn"
echo "  4) bun"
ask "Select your package manager [1-4, default: 1]:"
read -r PM_CHOICE

case "${PM_CHOICE:-1}" in
  1) PM_CMD="pnpm dlx shadcn@latest init -t next" ;;
  2) PM_CMD="npx shadcn@latest init -t next" ;;
  3) PM_CMD="yarn dlx shadcn@latest init -t next" ;;
  4) PM_CMD="bunx --bun shadcn@latest init -t next" ;;
  *) warn "Invalid option, using pnpm"; PM_CMD="pnpm dlx shadcn@latest init -t next" ;;
esac

# ── Running shadcn init ────────────────────────────────────────────────────────
step "1. Initializing project with shadcn/ui"
info "This will launch the shadcn CLI with the Next.js template."
info "IMPORTANT: If shadcn asks for a folder name, the project will be created there."
info "IMPORTANT: After finishing the template installation, run 'bash src/scripts/setup.sh' to configure the rest of the kit."

$PM_CMD

# ── Completion ────────────────────────────────────────────────────────────────
echo ""
success "Basic initialization process completed."
info "You can now configure the rest of the kit by running:"
echo -e "  ${CYAN}bash src/scripts/setup.sh${RESET}"
echo ""
