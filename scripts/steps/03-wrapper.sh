# Step 3 · Wrapper — install the freebuff npm launcher.
step 3 $TOTAL_STEPS "get freebuff wrapper"

if [[ -f "$MOD_DIR/launcher.js" && "${REFRESH:-0}" != "1" ]]; then
  log "wrapper already installed (REFRESH=0, skipping — make update to refresh)"
else
  # --force: npm sees Termux as os=android, the package only lists
  # darwin,linux,win32. The bin entry is pure JS, installs fine.
  log "npm install -g freebuff@$FB_VER"
  npm install -g "freebuff@$FB_VER" --force >"$FB_TMPDIR/fb-npm.log" 2>&1 &
  spinner $! "npm install" || { tail -5 "$FB_TMPDIR/fb-npm.log"; die "npm install failed"; }
  [[ -f "$MOD_DIR/launcher.js" ]] || die "wrapper installed but launcher.js missing"
fi

# Termux has no /usr/bin/env — fix the npm shebangs (no-op on Linux).
if [[ "$IS_ANDROID" == "1" ]] && command -v termux-fix-shebang >/dev/null 2>&1; then
  termux-fix-shebang "$MOD_DIR/index.js" "$MOD_DIR/launcher.js" >/dev/null 2>&1 || true
  log "shebangs fixed"
fi

step_done 0
