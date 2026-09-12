# Android/Termux patches

## 0001-android-glibc-loader.patch (launcher.js)

Two hunks, both gated on `process.platform === 'android'` (no-op elsewhere):

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
   loader aborts the child with `libc.so: invalid ELF header`) and pins
   `LD_LIBRARY_PATH` to the glibc lib dir.

Deliberately NOT done: patchelf on the downloaded binary (segfaults — see
`docs/PLATFORM.md`), `/lib` loader symlink via root (doesn't survive reboot,
needs root for no benefit).
