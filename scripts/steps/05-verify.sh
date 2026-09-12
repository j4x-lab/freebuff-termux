# Step 5 · Verify — prove the binary runs (downloads on first run).
step 5 $TOTAL_STEPS "verify"

# NOTE: `freebuff --version` spawns the real binary through the glibc
# loader — empty stdout means the spawn/download failed. Keep stderr so a
# failure is diagnosable instead of "produced no output" with no clue.
VERIFY_ERR="$FB_TMPDIR/fb-verify-$$.log"
GOT_VER="$(freebuff --version 2>"$VERIFY_ERR" || true)"
if [[ -z "$GOT_VER" ]]; then
  [[ -s "$VERIFY_ERR" ]] && tail -8 "$VERIFY_ERR" | while IFS= read -r l; do log "$l"; done
  log "binary: ${HOME}/.config/manicode/freebuff"
  log "loader: ${PREFIX}/glibc/lib/ld-linux-aarch64.so.1"
  rm -f "$VERIFY_ERR"
  die "freebuff --version produced no output (stderr above)"
fi
rm -f "$VERIFY_ERR"
export GOT_VER
log "binary reports v$GOT_VER"
freebuff --help >/dev/null 2>&1 || die "freebuff --help failed"

# TUI regression guard: under the explicit glibc loader, Bun's execPath is
# the loader, so the sibling tree-sitter.wasm lookup used to miss and the TUI
# fell back to a CDN download via curl (which then failed on the leaked
# LD_LIBRARY_PATH). The launcher patch covers both; fail here if it regresses.
freebuff --smoke-tree-sitter >/dev/null 2>&1 \
  || die "tree-sitter smoke failed — run: freebuff --smoke-tree-sitter"

step_done 0
