#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$DOTFILES_DIR/lib/symlinks.sh"

verify_symlinks portable

echo "All required symlinks are present and point to this repo."
