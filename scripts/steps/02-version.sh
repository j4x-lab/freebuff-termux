# Step 2 · Version — resolve which wrapper version to install.
step 2 $TOTAL_STEPS "resolve version"

# capture the currently-installed wrapper BEFORE we replace it (done report)
PREV_FB_VER="$(freebuff --version 2>/dev/null || echo "none")"

if [[ "$VER" == "latest" ]]; then
  FB_VER="$(npm view freebuff version 2>/dev/null || echo "")"
  [[ -n "$FB_VER" ]] || die "could not resolve latest freebuff version (npm registry reachable?)"
else
  FB_VER="$VER"
fi
export FB_VER
log "target v$FB_VER (installed: $PREV_FB_VER)"
export PREV_FB_VER

step_done 0
