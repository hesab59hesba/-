# Android Build Guide for Termux Proot (ARM64)

Covers building **Capacitor** and **NativeScript** Android APKs from Termux Proot on ARM64 Linux.

## Environment Variables

Already set in `~/.bashrc`:

```bash
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
export ANDROID_HOME=/root/android-sdk
export ANDROID_SDK_ROOT=/root/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/emulator
# NativeScript: skip environment checks (Termux proot quirk)
export NS_SKIP_ENV_CHECK=1
```

Reload after editing: `source ~/.bashrc`

## The aapt2 Fix

**Problem:** Android Gradle Plugin (AGP) bundles an x86-64 `aapt2` binary that won't run on ARM64.

**Fix:** Override it with the Debian ARM64 `aapt2`.

**Global** (`~/.gradle/gradle.properties`):
```properties
android.aapt2FromMavenOverride=/usr/lib/android-sdk/build-tools/debian/aapt2
org.gradle.jvmargs=-Djava.net.preferIPv4Stack=true -Xmx1536m
```

**Per-project** (`android/gradle.properties`): Same as above if not using global config.

## Gradle Wrapper

The Gradle wrapper defaults to downloading version 8.2.1, which often times out in Termux. **Gradle 8.14** is already cached in `/root/.gradle/`.

Update `android/gradle/wrapper/gradle-wrapper.properties`:
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.14-all.zip
```

## NativeScript

### Setup

```bash
npm install -g @nativescript/cli
ns create my-app --template @nativescript/template-blank
cd my-app
```

### Permanent Fixes

**1. Force compileSdk 34** in `App_Resources/Android/before-plugins.gradle`:

Prevents the dynamically-generated tempPlugin from defaulting to SDK 35 (which requires a newer aapt2):
```groovy
project.ext {
  compileSdk = 34
  targetSdk = 34
}
```

**2. Webpack `uv_interface_addresses` patch**:
In `node_modules/@nativescript/webpack/dist/helpers/host.js`, replace `os.networkInterfaces();` with:
```js
try {
  interfaces = os.networkInterfaces();
} catch (e) {
  interfaces = {};
}
```

Termux proot can't enumerate IPv6 interfaces; this prevents the webpack crash.

**3. Always export `NS_SKIP_ENV_CHECK=1`** (already in `~/.bashrc`).

### Build

```bash
ns clean
ns build android
```

APK at: `platforms/android/app/build/outputs/apk/debug/app-debug.apk`

## Capacitor

### Version

Capacitor 8.x requires `compileSdk 35+`. On this system, the Debian `aapt2` is too old for API 36's resource format.

**Use Capacitor 6.x** with `compileSdk 34`:

```bash
npm install @capacitor/cli@^6.0.0 @capacitor/core@^6.0.0 @capacitor/android@^6.0.0
```

Then set `android/variables.gradle`:
```groovy
compileSdkVersion = 34
targetSdkVersion = 34
```

### Build

```bash
npx cap sync android
cd android
export GRADLE_OPTS="-Djava.net.preferIPv4Stack=true"
./gradlew assembleDebug
```

APK at: `android/app/build/outputs/apk/debug/app-debug.apk`

### Quick Setup for New Projects

```bash
npm install -g @capacitor/cli@6
mkdir my-app && cd my-app
npm init -y
npm install @capacitor/core@^6.0.0 @capacitor/android@^6.0.0
npx cap init "My App" com.example.myapp
npx cap add android
npx cap sync android

# Fix compileSdk in android/variables.gradle
sed -i 's/compileSdkVersion = 36/compileSdkVersion = 34/' android/variables.gradle
sed -i 's/targetSdkVersion = 36/targetSdkVersion = 34/' android/variables.gradle

# Update gradle wrapper to 8.14
sed -i 's/gradle-8\.[0-9]*/gradle-8.14/' android/gradle/wrapper/gradle-wrapper.properties

# Build
export GRADLE_OPTS="-Djava.net.preferIPv4Stack=true"
cd android && ./gradlew assembleDebug
```

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `Temporary failure in name resolution` | DNS issues in proot | Add `-Djava.net.preferIPv4Stack=true` to `GRADLE_OPTS` or `org.gradle.jvmargs` |
| `AAPT2 Daemon startup failed` | x86-64 aapt2 on ARM64 | Set `android.aapt2FromMavenOverride` to `/usr/lib/android-sdk/build-tools/debian/aapt2` |
| `Cannot find symbol VANILLA_ICE_CREAM` | Capacitor 8.x needs API 35+ | Use Capacitor 6.x with compileSdk 34 |
| `Could not determine java version` | Wrong Java version | Set `JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64` |
| Gradle download times out | Network slow in Termux | Update wrapper to use cached Gradle 8.14 (already in `~/.gradle/`) |
| `uv_interface_addresses` error in webpack | Termux proot limitation | Patch `host.js` with try/catch around `os.networkInterfaces()` |
| `compileSdk = 35` forced by tempPlugin | NativeScript template | Set `project.ext.compileSdk = 34` in `before-plugins.gradle` |

## Installed SDK Components

- **Android SDK:** `/root/android-sdk/`
  - Platforms: android-34, android-36
  - Build-tools: 34.0.0, 35.0.0, 36.1.0
- **Java:** OpenJDK 21 (`/usr/lib/jvm/java-21-openjdk-arm64`)
- **Gradle:** 8.14 (cached at `~/.gradle/wrapper/dists/`)
- **Capacitor CLI:** v6 (fallback) / v8 (available)
- **NativeScript CLI:** v9.0.6
- **Node.js:** Available via Termux
- **QEMU:** `qemu-user` available for x86 emulation (not needed after the aapt2 override fix)
