# Android/Termux patches

## 0001-android-glibc-loader.patch (launcher.js)

Three hunks, all gated on `process.platform === 'android'` (no-op elsewhere):

1. **`getTargetOverride()`** — after the env-var loop, default to
   `linux-arm64` on android so `stageBinary()` finds a download target.
   Explicit `FREEBUFF_BINARY_TARGET` / `CODEBUFF_BINARY_TARGET` /
   `CLI_BINARY_TARGET` still wins.
2. **`spawnInstalledBinary()`** — new `getTermuxLoader()` helper resolves the
   glibc loader (`$PREFIX/glibc/lib/ld-linux-aarch64.so.1`, overridable via
   `FREEBUFF_GLIBC_LOADER` / `FREEBUFF_GLIBC_LIB`); the binary is spawned as
   `loader --library-path <lib> <binary> …args` instead of direct exec.
   The child's env also strips the Bionic `LD_PRELOAD` (Termux sets
   `LD_PRELOAD=libtermux-exec.so` globally — leaking it into the glibc
   loader aborts the child with `libc.so: invalid ELF header`) and strips
   any glibc dir from `LD_LIBRARY_PATH` (never pins it: the loader's
   `--library-path` already resolves the main binary, and leaking a glibc
   dir breaks every bionic child — `curl`, `git`, `ssh` — with
   `CANNOT LINK EXECUTABLE "curl": ".../glibc/lib/libc.so" has bad ELF
   magic: 2f2a2047`, because glibc's `libc.so` is a text linker script,
   not ELF). Plus two `tree-sitter.wasm` fixes: under the explicit loader
   Bun's `process.execPath` is the loader, not the binary, so the sibling
   wasm lookup misses and the TUI falls back to CDN download via `curl`
   (which then hits the env bug above) — the patch exports
   `CODEBUFF_TREE_SITTER_WASM_PATH` pointing at the real sibling and
   best-effort seeds a copy next to the loader for the env-blind pre-init
   scan (re-seeded when sizes differ, so glibc updates self-heal).

Deliberately NOT done: patchelf on the downloaded binary (segfaults — see
`docs/PLATFORM.md`), `/lib` loader symlink via root (doesn't survive reboot,
needs root for no benefit).
