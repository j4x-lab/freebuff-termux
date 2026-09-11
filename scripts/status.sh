#!/usr/bin/env bash
# status.sh — show freebuff-termux state: wrapper, binary, patches, platform.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

WVER="$(freebuff --version 2>/dev/null || echo "not working")"
NPMV="$(npm view freebuff version 2>/dev/null || echo "?")"
BIN="$HOME/.config/manicode/freebuff"
if [[ -x "$BIN" ]]; then BSIZE="$(du -h "$BIN" | cut -f1)"; else BSIZE="missing"; fi
PATCHED="missing"; [[ -f "$MOD_DIR/launcher.js" ]] && {
  grep -q "freebuff-termux" "$MOD_DIR/launcher.js" && PATCHED="applied" || PATCHED="NOT applied"
}
LOADER="$PREFIX/glibc/lib/ld-linux-aarch64.so.1"
[[ -f "$LOADER" ]] && LOADER="ok" || LOADER="missing"

printf '  platform : %s/%s\n' "$PLATFORM" "$ARCH"
printf '  wrapper  : v%s (npm latest: %s)\n' "$WVER" "$NPMV"
printf '  binary   : %s (%s)\n' "$BIN" "$BSIZE"
printf '  patches  : %s\n' "$PATCHED"
printf '  loader   : %s\n' "$LOADER"
