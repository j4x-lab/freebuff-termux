# Step 5 · Verify — prove the binary runs (downloads on first run).
step 5 $TOTAL_STEPS "verify"

GOT_VER="$(freebuff --version 2>/dev/null || echo "")"
[[ -n "$GOT_VER" ]] || die "freebuff --version produced no output"
log "binary reports v$GOT_VER"
freebuff --help >/dev/null 2>&1 || die "freebuff --help failed"

step_done 0
