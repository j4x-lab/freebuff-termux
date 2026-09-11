#!/usr/bin/env bash
# update-freebuff.sh — update the freebuff npm wrapper, then re-apply Termux patches.
# Usage: ./scripts/update-freebuff.sh [version]   (default: latest)
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VER="${1:-${FREEBUFF_VERSION:-latest}}"

npm install -g "freebuff@$VER" --force
termux-fix-shebang "$PREFIX/lib/node_modules/freebuff/index.js" \
  "$PREFIX/lib/node_modules/freebuff/launcher.js"
bash "$ROOT_DIR/scripts/apply-patches.sh"

# Refresh the glibc binary through the patched launcher (android→linux-arm64
# alias + explicit-loader spawn are active now).
freebuff --version
echo "update-freebuff: done (freebuff@$VER)"
