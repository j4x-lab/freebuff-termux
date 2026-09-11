# Step 6 · Done — summary report.
step 6 $TOTAL_STEPS "done"

NEW_VER="${GOT_VER:-$(freebuff --version 2>/dev/null || echo "?")}"
BIN_PATH="${HOME}/.config/manicode/freebuff"
PATCHED="no"
grep -q "freebuff-termux" "$MOD_DIR/launcher.js" 2>/dev/null && PATCHED="yes"

emit ""
emit "  freebuff-termux installed  ·  $PLATFORM/$ARCH"
emit "  wrapper: ${PREV_FB_VER} → v${NEW_VER}   patches: ${PATCHED}"
emit "  binary:  ${BIN_PATH}"
emit ""
emit "  next: cd ~/my-project && freebuff"
emit ""

step_done 0
