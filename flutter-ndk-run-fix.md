# Flutter `flutter run` NDK Fix for Termux Proot (ARM64)

Fixes `flutter run` failing with `Android NDK Clang could not be found` while `flutter termux build apk` works.

**Environment:** ARM64 Termux proot (Debian), Flutter 3.38.9, Dart 3.10.8, Gradle 8.14, AGP 8.11.1, Java 21, `compileSdk 34` — same as `build-apk.md`, `capacitor-android-build-fix.md`, `rust-egui-android-build-guide.md`.

## Symptom

```bash
flutter run -d 10.86.91.232:5555 --debug
# ...
# Target dart_build failed: Error: Android NDK Clang could not be found.
# FAILURE: Build failed with an exception.
# * What went wrong:
# Execution failed for task ':app:compileFlutterBuildDebug'.
# > Process 'command '/opt/flutter/bin/flutter'' finished with non-zero exit value 1
```

`flutter doctor -v` is `[✓] No issues` — it does not check NDK clang.

`flutter termux build apk` (debug/release) **works** — same project, same device.

## Root Cause

`/etc/profile.d/flutter-termux.sh` is a `flutter()` shell function:

```bash
flutter() {
  if [ "$1" = "termux" ] && [ "$2" = "build" ] && [ "$3" = "apk" ]; then
    export ANDROID_NDK_HOME=/root/android-sdk/ndk/28.2.13676358 # <- only here
    command flutter build apk ...
  else
    command flutter "$@" # <- flutter run lands here, no NDK export
  fi
}
```

* `28.2.13676358` is the only complete NDK (`toolchains/llvm/prebuilt/linux-x86_64/bin/{clang,llvm-ar,ld.lld}` are wrappers around Debian native `clang` — see `rust-egui-android-build-guide.md` for the original ARM64 workaround).
* `30.0.14904198 / 29.0.14206865 / 27.3.13750724 / 25.1.8937393` in `/root/android-sdk/ndk/` are **empty stubs** (`11K`, only `.installer`, no `toolchains/`). `sdkmanager --list` warns: `Observed package id 'ndk;28.2.13676358' in inconsistent location '/root/android-sdk/ndk-qemu'`.
* `packages/flutter_tools/lib/src/android/android_sdk.dart:356` `getNdkBinaryPath()` picks the **newest `Version`** in `ndk/` (`30.0.14904198`) and checks `toolchains/llvm/prebuilt/linux-x86_64/bin/clang` **only in that dir** — no fallback. Empty stub -> `null` -> `packages/flutter_tools/lib/src/isolated/native_assets/android/native_assets.dart:109` `throwToolExit('Android NDK Clang could not be found.')` during `DartBuild.build` / `runFlutterSpecificHooks` (triggered by `audioplayers`/`flame_audio` via `jni` code_assets, even if you don't use native assets directly).
* Host is `aarch64` (`uname -m`) but `android_sdk.dart:341` hardcodes `linux -> linux-x86_64` — real NDK `clang-19.orig` is `ELF x86-64`, only works via the `28.2` wrapper (`exec /usr/bin/clang --sysroot=...`).

`flutter termux build apk` exports `ANDROID_NDK_HOME` and bypasses auto-detection. `flutter run` does not, so it hits the stub.

## Fix — Without Changing What Works

No change to `android/app/build.gradle.kts` (`ndkVersion = flutter.ndkVersion`), `android/gradle.properties` (`aapt2FromMavenOverride`), `~/.gradle/gradle.properties`, `/etc/hosts` DNS pins, or `audioplayers_android` patch. Keep `build-apk.md` §Critical Fixes as-is.

### Immediate (per-command, zero file change)

Already documented in `build-apk.md:15` for `build`, same for `run`:

```bash
export ANDROID_NDK_HOME=/root/android-sdk/ndk/28.2.13676358
flutter run -d 10.86.91.232:5555 --debug
# or one-liner:
ANDROID_NDK_HOME=/root/android-sdk/ndk/28.2.13676358 flutter run -d 10.86.91.232:5555 --debug
```

Requires `JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64` (already in `~/.bashrc`) and `JAVA_TOOL_OPTIONS="-Djava.net.preferIPv4Stack=true ..."` for Gradle DNS (already in wrapper).

### Permanent (additive, keeps `flutter termux build apk` identical)

Add 3 global exports to the top of `/etc/profile.d/flutter-termux.sh` — outside the function so **every** `flutter` invocation inherits them:

```bash
# /etc/profile.d/flutter-termux.sh
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
export JAVA_TOOL_OPTIONS="-Djava.net.preferIPv4Stack=true -Dnetworkaddress.cache.ttl=0 -Dnetworkaddress.cache.negative.ttl=0"
export ANDROID_NDK_HOME=/root/android-sdk/ndk/28.2.13676358

flutter() {
  if [ "$1" = "termux" ] && [ "$2" = "build" ] && [ "$3" = "apk" ]; then
    export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
    export JAVA_TOOL_OPTIONS="-Djava.net.preferIPv4Stack=true -Dnetworkaddress.cache.ttl=0 -Dnetworkaddress.cache.negative.ttl=0"
    export ANDROID_NDK_HOME=/root/android-sdk/ndk/28.2.13676358
    # ... existing build logic
  else
    command flutter "$@"
  fi
}
```

Apply: `source /etc/profile.d/flutter-termux.sh` or open new shell.

Alternative: add `export ANDROID_NDK_HOME=/root/android-sdk/ndk/28.2.13676358` to `~/.bashrc` alongside `ANDROID_HOME` (from `capacitor-android-build-fix.md:12`).

### Optional Cleanup (makes auto-detection safe even without env)

Remove empty stubs so Flutter would pick `28.2.13676358` even if `ANDROID_NDK_HOME` is unset. Matches `gradle_utils.dart:28` `const ndkVersion = '28.2.13676358'`:

```bash
rm -rf /root/android-sdk/ndk/25.1.8937393 /root/android-sdk/ndk/27.3.13750724 /root/android-sdk/ndk/29.0.14206865 /root/android-sdk/ndk/30.0.14904198
ls -l /root/android-sdk/ndk/ # should show only 28.2.13676358
```

`sdkmanager --list` warning about `ndk-qemu` then disappears. `ndk-qemu/` and `ndk-qemu-wrapper/` (Rust guide) stay untouched.

## Verification

```bash
echo $ANDROID_NDK_HOME # -> /root/android-sdk/ndk/28.2.13676358
ls /root/android-sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64/bin/clang # wrapper exists
cat /root/android-sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64/bin/clang # -> exec /usr/bin/clang --sysroot=...
flutter run -d 10.86.91.232:5555 --debug --verbose 2>&1 | grep -A2 "cCompilerConfig"
# no "Clang could not be found"
```

## Relationship to Existing Guides

* `build-apk.md` §4 NDK pinning — same fix, now applied to `flutter run` (not just `build apk`).
* `capacitor-android-build-fix.md` §aapt2 / Gradle 8.14 / IPv4 — still required, `flutter run` uses same Gradle.
* `rust-egui-android-build-guide.md` §NDK Setup — explains why `28.2` wrappers exist (x86-64 NDK `clang` PGO/BOLT crashes `qemu-x86_64` with `Illegal instruction`, replaced by native `clang` wrapper).

No project files changed — only env.
