# Release Build Guide — Knight (com.appy.knight)

> **Goal:** Build a **signed release APK** (`app-release.apk` ~50 MB) on **ARM64 Termux proot (Debian) under QEMU** without hanging, AAPT2, DNS, or NDK failures.  
> **Project:** `/root/Desktop/projects/knight` — Flutter 3.38 / Dart 3.10 / Flame 1.35 / `compileSdk 34` / `targetSdk 34`  
> **Last verified:** 2026-09-06 — `app-debug 145 MB / 145s` · `app-release 49 MB / 236s` (signed, installed via `adb`)

---

## 1. Environment (must match exactly)

| Component | Version / Path | Verify |
|-----------|----------------|--------|
| Flutter | 3.38.9 stable `67323de28` / `/opt/flutter` | `flutter --version` |
| Dart | 3.10.8 | `flutter --version` |
| Gradle | 8.14 (wrapper) `~/.gradle/wrapper/dists/gradle-8.14-all.zip` | `android/gradle/wrapper/gradle-wrapper.properties` |
| AGP | 8.11.1 (via `flutter.gradle-plugin`) | `flutter build apk --release --info \| grep AGP` |
| Java | 21.0.12 `arm64` `/usr/lib/jvm/java-21-openjdk-arm64` | `java -version` |
| Android SDK | `/root/android-sdk` | `ls /root/android-sdk/build-tools/` |
| NDKs | `25.1.8 / 27.3.1 / 28.2.13676358 / 29.0.14 / 30.0.14` — **use 28.2.13676358** | `ls /root/android-sdk/ndk/` |
| aapt2 (Debian) | `/usr/lib/android-sdk/build-tools/debian/aapt2` (ARM64) | `file /usr/lib/android-sdk/build-tools/debian/aapt2` |
| Device | QEMU ARM64 host + Termux proot Debian | `uname -m` → `aarch64`, `cat /proc/cmdline \| grep qemu` |
| Package | `com.appy.knight` `Knight` `version: 1.0.0+1` | `android/app/build.gradle.kts` |

**Do NOT** upgrade without re-pinning (#1-5 below). `aapt2` Debian cannot handle `compileSdk 35+` resources — stay on **34**.

---

## 2. Prerequisites Checklist (run before every agent / fresh shell)

Copy-paste:

```bash
# 1. Shell env (every terminal, every agent)
source /etc/profile.d/flutter-termux.sh
echo "JAVA_HOME=$JAVA_HOME"
echo "ANDROID_NDK_HOME=$ANDROID_NDK_HOME"
java -version 2>&1 | head -1
ls /root/android-sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64/bin/clang 2>&1 | head

# 2. aapt2 override (must be ARM64, not x86_64 from AGP)
grep -r aapt2FromMavenOverride android/gradle.properties ~/.gradle/gradle.properties 2>/dev/null
file /usr/lib/android-sdk/build-tools/debian/aapt2 | head -1
# expected: ELF 64-bit LSB executable, ARM aarch64

# 3. Gradle wrapper (must be 8.14, pre-cached)
grep distributionUrl android/gradle/wrapper/gradle-wrapper.properties

# 4. DNS (proot+QEMU have no IPv6 route — 60% of "stuck builds")
cat /etc/hosts | tail -5
getent ahostsv4 dl.google.com | head -1    # must return 142.x, not 2607::
getent ahostsv4 repo.maven.apache.org | head -1
getent ahostsv4 services.gradle.org | head -1

# 5. NDK (30.0 is a stub, 28.2 is real)
ls /root/android-sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-ar 2>&1 | head
ls /root/android-sdk/ndk/30.0.14904198/toolchains 2>&1 | head  # should be missing/empty

# 6. Signing
ls -lh android/app/knight-release.jks android/key.properties
cat android/key.properties
cat android/app/build.gradle.kts | grep -A5 signingConfigs

# 7. Project
cd /root/Desktop/projects/knight
flutter analyze 2>&1 | tail -3   # must be 0 errors (infos OK)
flutter pub get 2>&1 | tail -5
# re-apply SDK-34 patch after every pub get (see §4.5)
grep compileSdk /root/.pub-cache/hosted/pub.dev/audioplayers_android-5.2.1/android/build.gradle
```

If any check fails, fix it **before** calling `flutter build`.

---

## 3. Signing Setup (already done — verify, don't recreate)

`android/key.properties` (relative to `android/`):

```properties
storePassword=knight2026
keyPassword=knight2026
keyAlias=knight
storeFile=knight-release.jks
```

> `storeFile` is **relative to `android/app/`**. `app/app/…` double-prefix is a failure — keep `knight-release.jks`, not `app/knight-release.jks`.

`android/app/build.gradle.kts` (excerpt):

```kotlin
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) load(FileInputStream(f))
}
android {
    namespace = "com.appy.knight"
    compileSdk = 34
    ndkVersion = flutter.ndkVersion
    // ...
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    buildTypes { release { signingConfig = signingConfigs.getByName("release") } }
}
```

`android/app/knight-release.jks` is the release keystore (gitignored). Back it up off-device — losing it = new Play Store package.

---

## 4. Critical Fixes — QEMU + Termux Proot (the other agent's stuck builds)

These 6 are **already applied** in this repo; a fresh agent proot must re-apply them or the build will hang/fail the same way.

### 4.1 aapt2 — x86_64 binary cannot run under QEMU AArch64

*Symptom:* `AAPT2 Daemon startup failed` / `Failed to compile`  
*Root:* AGP ships `/android-sdk/build-tools/35.x/aapt2` built for `x86_64`. QEMU user-mode cannot exec x86_64 on ARM64 host.  
*Fix:* Override with Debian's native ARM64 `aapt2`:

`android/gradle.properties` **and** `~/.gradle/gradle.properties`:

```properties
org.gradle.jvmargs=-Xmx2g -Djava.net.preferIPv4Stack=true -Dnetworkaddress.cache.ttl=0 -Dnetworkaddress.cache.negative.ttl=0
org.gradle.parallel=true
android.useAndroidX=true
android.aapt2FromMavenOverride=/usr/lib/android-sdk/build-tools/debian/aapt2
```

Verify: `file /usr/lib/.../aapt2` → `ARM aarch64`.

### 4.2 Gradle 8.14 pinned (not 7.x / 8.7)

`android/gradle/wrapper/gradle-wrapper.properties`:

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.14-all.zip
```

8.14 is pre-cached in `~/.gradle/wrapper/dists/` so no download under QEMU NAT. If you bump, QEMU will stall downloading `gradle-8.x-all.zip`.

### 4.3 DNS — proot has no IPv6, but `getent hosts` returns IPv6 first

*Symptom:* `Running Gradle task 'assembleRelease'...` hangs 10+ min, or `Temporary failure in name resolution` for `dl.google.com / repo.maven.apache.org / services.gradle.org`.  
*Root:* Proot's `/etc/resolv.conf` + QEMU SLIRP returns `2607:...` IPv6; host has no IPv6 route → Gradle retries forever.  
*Fix:* Force IPv4 via `/etc/hosts` pins + Java + Gradle flags:

`/etc/hosts` tail (refresh if stale — IPs rotate):

```
142.251.208.142 dl.google.com
104.18.18.12    repo.maven.apache.org
104.16.72.101   services.gradle.org
```

Refresh script (run when pins return `NXDOMAIN`):

```bash
for h in dl.google.com repo.maven.apache.org services.gradle.org; do
  ip=$(getent ahostsv4 $h | head -1 | awk '{print $1}')
  sed -i "/ $h$/d" /etc/hosts; echo "$ip $h" >> /etc/hosts
done
cat /etc/hosts | tail -5
```

Also:

* `JAVA_TOOL_OPTIONS="-Djava.net.preferIPv4Stack=true -Dnetworkaddress.cache.ttl=0 -Dnetworkaddress.cache.negative.ttl=0"` (in `gradle.properties` + `flutter-termux.sh`).
* Test before building: `getent ahostsv4 dl.google.com` must give `142.x`, not empty. `getent hosts dl.google.com` alone may still show `2607:` — ignore, use `ahostsv4`.

### 4.4 NDK — 30.0 is a stub, 28.2 is the only full NDK

*Symptom:* `Android NDK Clang could not be found` / `toolchains/llvm/prebuilt/.../clang: No such file`.  
*Root:* Flutter picks **latest** `ndk/<version>`. `30.0.14904198` on this image is a stub (no `toolchains/`). Real NDK is `28.2.13676358`; its `clang / llvm-ar / ld.lld` are **bash wrappers** around Debian's native `clang` with the NDK sysroot — they work under QEMU.  
*Fix:* **Never** export `ANDROID_NDK_HOME` to `30.0`. Pin to 28.2:

`/etc/profile.d/flutter-termux.sh`:

```bash
export ANDROID_NDK_HOME=/root/android-sdk/ndk/28.2.13676358
```

If calling `flutter build` without the wrapper, export it first. If calling `./gradlew`, export before `android/`.

Verify:

```bash
ls $ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/clang
cat $ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/clang | head -5
# should be: #!/bin/bash ... native clang ...
```

### 4.5 `compileSdk 34` lock (Debian aapt2 + QEMU)

*Symptom:* `One or more plugins require higher compileSdk 35` / `checkDebugAarMetadata` fails only on **release**.  
*Root:* `audioplayers_android 5.2.1` declares `compileSdk 35`. Debian's `aapt2` cannot parse SDK-35 resources, so this project locks `android/app/build.gradle.kts` to `compileSdk = 34`.  
*Fix:* After **every** `flutter pub get` / `flutter clean`, patch the cached plugin:

```bash
sed -i 's/compileSdk 35/compileSdk 34/' /root/.pub-cache/hosted/pub.dev/audioplayers_android-5.2.1/android/build.gradle
grep compileSdk /root/.pub-cache/hosted/pub.dev/audioplayers_android-5.2.1/android/build.gradle
# must show 34
```

Debug warns, **release fails hard** if unpatched. Automate in CI with post-`pub get` hook.

### 4.6 `flutter termux build apk` alias (single entry point)

`/etc/profile.d/flutter-termux.sh`:

```bash
flutter() {
  if [ "$1" = "termux" ] && [ "$2" = "build" ] && [ "$3" = "apk" ]; then
    export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
    export JAVA_TOOL_OPTIONS="-Djava.net.preferIPv4Stack=true -Dnetworkaddress.cache.ttl=0 -Dnetworkaddress.cache.negative.ttl=0"
    export ANDROID_NDK_HOME=/root/android-sdk/ndk/28.2.13676358
    if [ "$4" = "--release" ]; then
      command flutter build apk --release 2>&1
    else
      command flutter build apk --debug 2>&1
    fi
    echo "===EXIT CODE: $?==="
  else
    command flutter "$@"
  fi
}
```

*Why:* Hides QEMU env, makes builds copy-paste safe for agents. **Never** call bare `flutter build apk --release` from a fresh agent without sourcing this file — NDK/JAVA will be wrong.

### 4.7 QEMU-specific extra pitfalls (the "other agent stuck")

* **Gradle daemon survives across agents.** It caches `JAVA_TOOL_OPTIONS` from the first build. If the first agent used `x86_64` or IPv6, the daemon is poisoned. Kill it: `cd android && ./gradlew --stop; pkill -9 java` then rebuild.
* **Proot `proot -r / -b ...` loses `/proc/net` on long builds.** If `assembleRelease` shows `Could not reserve enough space for 2GB` under QEMU, drop `org.gradle.jvmargs` to `-Xmx1g`.
* **Clock skew:** QEMU may drift. `date; ntpdate -q time.google.com` — Gradle rejects snapshots if clock is 2024.
* **`AssetManifest` clash (Phase 3):** `flutter/services.dart` now exports `AssetManifest` (SDK 3.38). This repo's `lib/assets/asset_manifest.dart` clashed. Fix is `import 'assets/asset_manifest.dart' as knight_assets;` and `await knight_assets.AssetManifest.preload(this)` in `knight_game.dart`.
* **`Route` clash:** `flame/game.dart` exports `Route` and `flutter/material.dart` does too. `lib/main.dart` imports `flame/game.dart` as `hide Route`.

---

## 5. Build — Release APK (signed)

### 5.1 Quick (recommended — uses alias, handles all of §4)

```bash
source /etc/profile.d/flutter-termux.sh
cd /root/Desktop/projects/knight

# Sanity (must be 0 errors)
flutter analyze 2>&1 | tail -5
flutter test 2>&1 | tail -5   # 9/9 in test/collision_and_spec_test.dart

# Debug (for smoke via `flutter run -d`)
flutter termux build apk
ls -lh build/app/outputs/flutter-apk/app-debug.apk   # ~145 MB

# Release (signed, tree-shaken, 3 ABIs) — the one you ship
flutter termux build apk --release
ls -lh build/app/outputs/flutter-apk/app-release.apk # ~49 MB
cat build/app/outputs/flutter-apk/app-release.apk.sha1
```

First release after a fresh `flutter clean` or new dep: **3–6 min** (236.2s last). Warm incremental: **70–90s**. If `Running Gradle task 'assembleRelease'...` shows nothing for >10 min, it's DNS (§4.3) — `Ctrl-C`, `getent ahostsv4`, fix `/etc/hosts`, `--stop`, retry.

### 5.2 Manual (bypass alias, proves env)

```bash
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
export JAVA_TOOL_OPTIONS="-Djava.net.preferIPv4Stack=true -Dnetworkaddress.cache.ttl=0 -Dnetworkaddress.cache.negative.ttl=0"
export ANDROID_NDK_HOME=/root/android-sdk/ndk/28.2.13676358
cd /root/Desktop/projects/knight/android
./gradlew assembleRelease --info 2>&1 | tail -30
ls -lh ../build/app/outputs/flutter-apk/app-release.apk
```

### 5.3 Full clean (use only when `flutter analyze` / cache is suspect)

```bash
cd /root/Desktop/projects/knight
flutter clean
flutter pub get
sed -i 's/compileSdk 35/compileSdk 34/' /root/.pub-cache/hosted/pub.dev/audioplayers_android-5.2.1/android/build.gradle
flutter termux build apk --release
```

---

## 6. Verify the Release Artifact

```bash
cd /root/Desktop/projects/knight

# 1. Size & signature
ls -lh build/app/outputs/flutter-apk/app-release.apk
# -rw-r--r-- 49M app-release.apk   (debug is ~145M — release must be <60M)
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk 2>&1 | head
# must show DN: CN=... O=... and “Verified using v1/v2/v3”

# 2. Package & SDK
aapt2 dump badging build/app/outputs/flutter-apk/app-release.apk 2>&1 | grep -E "package|sdkVersion|targetSdk"
# package: name='com.appy.knight' versionCode='1' versionName='1.0.0'
# sdkVersion:'24' -- targetSdk:'34'
# (use Debian aapt2: /usr/lib/android-sdk/build-tools/debian/aapt2 dump ...)

# 3. Install smoke (use debug for quick smoke, release for final)
adb install -r build/app/outputs/flutter-apk/app-release.apk
adb logcat -s flutter:V | grep -E "\[Main\]|\[FlutterError\]|\[WidgetError\]" &
# launch Knight on device → MainMenu → LEVELS → pick 01_desert → play → no FLUTTER_ERROR
```

Debug smoke via `flutter run -d` is now reliable (no qemu DNS block) — use:

```bash
flutter run -d 23073RPBFG 2>&1 | tee /tmp/run.log
adb logcat -s flutter:V | grep -E "\[Navigation\]|\[Level\]|\[.*ERROR\]"
```

---

## 7. Troubleshooting (QEMU-first)

| Symptom | QEMU / Proot cause | Fix (one-liner) |
|---------|-------------------|-----------------|
| `assembleRelease` hangs, no output | DNS IPv6 → no route (§4.3) | `grep -q dl.google.com /etc/hosts \|\| echo "142.251.208.142 dl.google.com" >> /etc/hosts; getent ahostsv4 dl.google.com` |
| `AAPT2 Daemon startup failed` | x86_64 aapt2 on ARM64 QEMU | `grep aapt2FromMavenOverride android/gradle.properties` must show `debian/aapt2` |
| `Android NDK Clang could not be found` | NDK 30 stub + Flutter picks latest | `echo $ANDROID_NDK_HOME` must be `.../28.2.13676358` |
| `compileSdk 35` error only on release | `audioplayers` declares 35 (§4.5) | `sed -i 's/compileSdk 35/compileSdk 34/' .../audioplayers_android-5.2.1/android/build.gradle` |
| `validateSigningRelease: keystore ... not found` | `storeFile=app/...` double prefix | `grep storeFile android/key.properties` → `knight-release.jks` (not `app/...`) |
| `AssetManifest is imported from both` | SDK 3.38+ exports it (§4.7) | `grep "as knight_assets" lib/knight_game.dart` |
| `Route` ambiguous | `flame/game.dart` + `flutter/material.dart` | `grep "hide Route" lib/main.dart` |
| `Could not download gradle-8.14-all.zip` | QEMU NAT DNS fail | Fix §4.3, then `ls ~/.gradle/wrapper/dists/gradle-8.14*` must exist |
| `java.lang.OutOfMemoryError` | QEMU + `-Xmx2g` too large | `sed -i 's/-Xmx2g/-Xmx1g/' android/gradle.properties; ./gradlew --stop` |
| `kernel_snapshot_program failed` | `flutter analyze` error not fixed | `flutter analyze` → fix first, then build |
| `flutter: command not found` in new agent | agent didn't `source /etc/profile.d/flutter-termux.sh` | `source` first, or `command flutter` will be `/opt/flutter/bin/flutter` without env |

**If stuck with no output for >2 min:** Don't kill immediately — check `ls -la build/app/outputs/flutter-apk/` mtime is ticking; Gradle is buffering. `tail -f ~/.gradle/daemon/*/daemon-*.log` shows real progress.

---

## 8. Do / Don't for QEMU Agents

**Do:**
- `source /etc/profile.d/flutter-termux.sh` at the top of every agent script.
- Always use `flutter termux build apk [--release]`, never bare `flutter build apk`.
- Gate every build with the checklist in §2.
- Re-apply §4.5 after `flutter pub get`.

**Don't:**
- `flutter clean` unless `analyze` is red — cold builds are 148 Gradle tasks + 3-ABI AOT, 5× slower under QEMU.
- Install `ndk;30.0` via `sdkmanager` — it shadows 28.2 and breaks builds.
- Bump `compileSdk` to 35 without swapping `aapt2` to a 35-capable ARM64 build (none in Debian yet).
- Run two `assembleRelease` in parallel — QEMU + proot will deadlock on `~/.gradle`.

---

## 9. Quick Copy-Paste — One-Shot Release

```bash
#!/bin/bash
set -e
source /etc/profile.d/flutter-termux.sh
cd /root/Desktop/projects/knight
flutter analyze
flutter test
flutter termux build apk --release
ls -lh build/app/outputs/flutter-apk/app-release.apk
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk 2>&1 | head -5
echo "OK — release ready: build/app/outputs/flutter-apk/app-release.apk"
```

---

## 10. Where logs live

* Gradle daemon: `~/.gradle/daemon/<version>/daemon-*.log`
* Build: `build/flutter_build/*.log` (tree-shake log)
* App: `adb logcat -s flutter:V` → `[Main]`, `[KnightGame]`, `[Level]`, `[FlutterError]`, `[Perf]`
* APKs: `build/app/outputs/flutter-apk/app-{debug,release}.apk{,.sha1}`

*This doc is the QEMU-aware superset of `build-apk.md`. Keep both — `build-apk.md` for day-to-day, this file for release + new agents.*
