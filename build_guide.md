# RShare — Android APK Build Guide (Termux Proot / ARM64)

How to build the **RShare** Flutter + Rust APK on an ARM64 Linux environment
(Termux Proot) where the stock Android NDK and SDK tools are x86_64 and
cannot run natively.

This guide captures the exact, working configuration discovered while building
the project. Follow it whenever the environment is reset.

---

## TL;DR — Build now

```bash
# One-time (only if the NDK wrapper is missing):
./setup-ndk-wrapper.sh

# Every build:
./build-apk.sh            # release APK
./build-apk.sh --debug    # debug APK
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## 1. Environment

This build runs on **ARM64 Linux (Termux Proot)**. Three stock Android tools
are x86_64 and break natively:

| Tool | Problem | Fix |
|------|---------|-----|
| NDK `clang` | PGO/BOLT-optimized x86_64 binary → "Illegal instruction" | Native ARM64 `clang` wrapper using the NDK sysroot |
| SDK `aapt2` | x86_64, can't load API 35/36 resource tables | Debian native `/usr/bin/aapt2` (handles ≤ API 34 only) |
| `gen_snapshot` | x86_64 | Runs under `qemu-x86_64` (slow but works) |

### Installed at:
- **Android SDK**: `/root/android-sdk/` (platforms 30/34/35/36, build-tools 34/35/36)
- **NDK**: `/root/android-sdk/ndk/28.2.13676358/`
- **Java**: `/usr/lib/jvm/java-21-openjdk-arm64`
- **Gradle**: 8.14 (cached at `~/.gradle/wrapper/dists/`)
- **Flutter**: `/opt/flutter` (3.38.9)
- **Rust**: stable (with `aarch64-linux-android` target)

### Global Gradle config (`~/.gradle/gradle.properties`)
Already set:
```properties
android.aapt2FromMavenOverride=/usr/lib/android-sdk/build-tools/debian/aapt2
org.gradle.jvmargs=-Djava.net.preferIPv4Stack=true -Xmx1536m
```
This forces Gradle to use the Debian ARM64 aapt2 instead of the x86_64 one.

---

## 2. The native clang NDK wrapper (one-time setup)

Run `./setup-ndk-wrapper.sh`, which:

1. Creates `/root/android-sdk/ndk-qemu/native-linker-wrapper.sh`:
   ```bash
   #!/bin/bash
   NDK_TOOLCHAIN=/root/android-sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64
   exec clang \
     --sysroot=$NDK_TOOLCHAIN/sysroot \
     -resource-dir=$NDK_TOOLCHAIN/lib/clang/19 \
     -rtlib=compiler-rt \
     -fuse-ld=lld \
     "$@"
   ```
2. Backs up and replaces the NDK's x86_64 `clang`/`clang++`/`clang-19`/
   `clang-aarch64-linux-android` binaries with this wrapper (they're moved to
   `bin-x86_64-backup/`).

> **Why:** The NDK's clang is x86_64 and crashes on ARM64. Debian's native
> `clang 19` + the NDK sysroot produces correct ARM64 Android object code and
> links with `lld` (which honors `--sysroot`).

---

## 3. The linker target trick

The wrapper itself is **target-agnostic** (no hardcoded `--target`). Rust's
link invocation doesn't pass `--target`, so the clang driver would default to
the host and fail to find Android CRT objects (`crti.o`, `-lc`, `-llog`).

**Fix:** set the cargo linker to the NDK's *target-specific* clang script:
```
CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER=$NDK_BIN/aarch64-linux-android24-clang
```
That script (`aarch64-linux-android24-clang`, untouched x86_64 shell script)
calls `$bin_dir/clang --target=aarch64-linux-android24 "$@"` — and `$bin_dir/clang`
is now the native wrapper. So the chain is native end-to-end and the clang
driver resolves the correct CRT + system libraries for API 24.

This is the key difference from the simple wrapper in
`rust-egui-android-build-guide.md`: that guide's project (macroquad) links
almost no system libraries, so the host GNU `ld` worked. RShare pulls in
`tokio`/`mio`/etc. which need `-lc`/`-ldl`/`-llog`/`-lm`, requiring lld +
correct target resolution.

---

## 4. compileSdk must be 34 (NOT 35/36)

The Debian aapt2 can only parse Android resource tables up to **API 34**. API
35/36 jars fail with:
```
RES_TABLE_TYPE_TYPE entry offsets overlap actual entry data.
Failed to load resources table in APK '.../android-36/android.jar'.
```

Three places set compileSdk and all must be 34:

### 4a. Flutter's default (`flutter.compileSdkVersion`)
Flutter 3.38 hardcodes `compileSdkVersion = 36` in:
`/opt/flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt`
```kotlin
val compileSdkVersion: Int = 34   // was 36
val targetSdkVersion: Int = 34    // was 36
```
This is picked up because `android/settings.gradle.kts` uses
`includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")` (composite build
from source — Gradle recompiles it).

### 4b. The `jni` / `jni_flutter` plugins (from flutter_rust_bridge)
These hardcode `compileSdk 35` in their own `android/build.gradle`. Edit:
- `/root/.pub-cache/hosted/pub.dev/jni-1.0.0/android/build.gradle` → `compileSdk 34`
- `/root/.pub-cache/hosted/pub.dev/jni_flutter-1.0.1/android/build.gradle` → `compileSdk 34`

> These edits are lost if you run `flutter pub cache clean` or change the
> package versions. Re-apply them, or pin them via `dependency_overrides`.

### 4c. The app module
`android/app/build.gradle.kts`:
```kotlin
compileSdk = 34
// ...
minSdk = 21
targetSdk = 34
ndkVersion = "28.2.13676358"
ndk { abiFilters += listOf("arm64-v8a") }
```

---

## 5. arm64-only (avoid armv7)

Build only `arm64-v8a`:

- **`abiFilters += listOf("arm64-v8a")`** in `app/build.gradle.kts` — restricts
  the packaged native libs.
- **`CARGOKIT_TARGET_PLATFORMS=android-arm64`** — tells cargokit to compile
  Rust for arm64 only. The armv7 target fails because NDK 28's CRT layout
  mismatches Rust's expectations, and the 32-bit sysroot headers don't resolve.
- **`--target-platform=android-arm64`** on `flutter build apk` — limits Dart
  AOT compilation to **one** `gen_snapshot` run instead of three (arm/arm64/x64).
  Three parallel QEMU x86_64 gen_snapshot processes are extremely slow; one
  completes in a few minutes.

---

## 6. The build command

All environment variables in one place (this is what `build-apk.sh` sets):

```bash
export ANDROID_NDK_HOME=/root/android-sdk/ndk/28.2.13676358
export ANDROID_SDK_ROOT=/root/android-sdk
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
export CARGOKIT_TARGET_PLATFORMS=android-arm64
export CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER=/root/android-sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android24-clang
export CC_aarch64_linux_android=/root/android-sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android24-clang
export CXX_aarch64_linux_android=/root/android-sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android24-clang++
export AR_aarch64_linux_android=/root/android-sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-ar
export GRADLE_OPTS="-Djava.net.preferIPv4Stack=true"

flutter build apk --release --target-platform=android-arm64
```

Expected runtime: ~4–6 minutes (Rust cross-compile + one gen_snapshot under
QEMU + Gradle packaging).

---

## 7. Verifying the APK

```bash
APK=build/app/outputs/flutter-apk/app-release.apk
ls -lh "$APK"
/usr/bin/aapt2 dump badging "$APK" | grep -E "package|sdkVersion|launchable-activity"
```
Expected:
```
package: name='com.rshare.app' versionCode='1' versionName='1.0.0' ...
sdkVersion:'24'
launchable-activity: name='com.rshare.app.MainActivity'
```

---

## 8. Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Illegal instruction` from clang | NDK x86_64 clang running natively | Run `setup-ndk-wrapper.sh` |
| `cannot open crti.o` / `cannot find -llog` | Linker missing `--target`; clang used host GNU ld | Ensure `CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER` points to `aarch64-linux-android24-clang` (not the bare wrapper) |
| `RES_TABLE_TYPE_TYPE entry offsets overlap` / `failed to load android-35/36/android.jar` | aapt2 can't parse API 35/36 | Set compileSdk 34 in FlutterExtension.kt + jni/jni_flutter plugins |
| `It is too late to set compileSdk` | Trying to force compileSdk from root `build.gradle.kts` after evaluation | Don't — fix it at the source (FlutterExtension.kt + plugin build.gradle) instead |
| Build hangs forever on one `clang` process | Wrapper hardcoded `-target aarch64` causing build-script probes to loop | Use the **target-agnostic** wrapper (no `-target`); rely on the `aarch64-linux-android24-clang` script to add it |
| Very slow build (many `gen_snapshot`) | Building 3 ABIs under QEMU | Add `--target-platform=android-arm64` |
| `flutter pub cache clean` wiped the jni plugin edits | pub-cache restored original `compileSdk 35` | Re-apply step 4b, or use `dependency_overrides` with a local patched copy |
| `bits/wordsize.h not found` compiling `dart_api_dl.c` for armv7 | armv7 target on NDK 28 | Force arm64 only (`CARGOKIT_TARGET_PLATFORMS=android-arm64` + `abiFilters`) |
| `aapt2` not found at override path | Debian android-sdk build-tools not installed | `apt install google-android-build-tools` or whatever provides `/usr/bin/aapt2` |

---

## 9. After changing Rust code

After editing any file under `rust/src/`:
```bash
flutter_rust_bridge_codegen generate   # if API signatures changed
./build-apk.sh
```
Cargokit will detect the source change and recompile only the Rust crate
(cached otherwise). The Dart side (`flutter_rust_bridge_codegen generate`) only
needs re-running when `rust/src/api/mod.rs` public signatures change.

---

## 10. Project layout (for reference)

```
rshare/
├── build-apk.sh              # one-command build (sets all env vars)
├── setup-ndk-wrapper.sh      # one-time NDK clang wrapper setup
├── build_guide.md             # this file
├── guide-document.md          # original architecture guide
├── lib/                       # Flutter/Dart UI
│   ├── main.dart
│   └── src/{state,ui}/
├── rust/                      # Rust core (cross-compiled to arm64)
│   ├── Cargo.toml
│   └── src/{api,crypto,fs,net,protocol,error}.rs
├── rust_builder/              # cargokit glue (Flutter <-> Rust)
└── android/                   # Gradle (compileSdk 34, arm64 only)
    └── app/build.gradle.kts
```
