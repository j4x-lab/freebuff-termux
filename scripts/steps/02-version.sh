# Step 2 · Version — resolve which wrapper version to install.
step 2 $TOTAL_STEPS "resolve version"

# read the installed wrapper version WITHOUT executing the binary:
# `freebuff --version` spawns the 130MB binary (first run downloads it),
# so probing it here is slow and can race step 5. package.json is instant.
if [[ -f "$MOD_DIR/package.json" ]]; then
  PREV_FB_VER="$(node -p "require('$MOD_DIR/package.json').version" 2>/dev/null || echo "none")"
  [[ -n "$PREV_FB_VER" ]] || PREV_FB_VER="none"
else
  PREV_FB_VER="none"
fi

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
