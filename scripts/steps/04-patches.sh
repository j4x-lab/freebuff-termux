# Step 4 · Patches — apply the Termux launcher patch.
step 4 $TOTAL_STEPS "apply Termux patches"

bash "$ROOT_DIR/scripts/apply-patches.sh" || die "patch step failed"
grep -q "freebuff-termux" "$MOD_DIR/launcher.js" || die "patch marker missing after apply"

step_done 0
