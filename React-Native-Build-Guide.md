# Building React Native APKs in Termux PRoot Debian

Complete guide for setting up and building React Native Android APKs in Termux PRoot Debian (ARM64) environment.

---

## Part 1: Environment Setup (One-Time)

### Step 1: Install System Packages

```bash
# Update apt and install Java JDK 17
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y openjdk-17-jdk-headless git unzip wget curl python3 make g++

# Verify Java installation
java -version
javac -version
```

### Step 2: Install Android SDK

```bash
# Create SDK directory
mkdir -p /opt/android-sdk
cd /tmp

# Download Android SDK command-line tools
wget -q "https://dl.google.com/android/repository/commandlinetools-linux-12265704_latest.zip" -O cmdline-tools.zip
unzip -q cmdline-tools.zip
mkdir -p /opt/android-sdk/cmdline-tools
mv cmdline-tools /opt/android-sdk/cmdline-tools/latest
rm cmdline-tools.zip

# Accept licenses and install SDK components
export ANDROID_HOME=/opt/android-sdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"

yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;35.0.0" "ndk;27.1.12297006"
```

### Step 3: Install Node.js and yarn

```bash
# Node.js is usually available via NodeSource
# Verify installation
node -v
npm -v

# Install yarn
npm install -g yarn
yarn --version
```

### Step 4: Apply ARM64 Fixes (Critical)

**Problem**: Android build tools (aapt2, aapt, zipalign) from Google are x86_64 binaries that cannot run on ARM64.

**Solution**: Copy native ARM64 binaries from the Debian proot environment.

```bash
# Copy Debian ARM64 aapt2/aapt/zipalign
PROOT=/data/data/com.termux/files/usr/var/lib/proot-distro/containers/debian/rootfs
mkdir -p /opt/android-sdk/build-tools/debian

cp $PROOT/usr/lib/android-sdk/build-tools/debian/aapt2 /opt/android-sdk/build-tools/debian/
cp $PROOT/usr/lib/android-sdk/build-tools/debian/aapt /opt/android-sdk/build-tools/debian/
cp $PROOT/usr/lib/android-sdk/build-tools/debian/zipalign /opt/android-sdk/build-tools/debian/

# Copy required Android shared libraries
mkdir -p /usr/lib/aarch64-linux-gnu/android
cp $PROOT/usr/lib/aarch64-linux-gnu/android/*.so* /usr/lib/aarch64-linux-gnu/android/

# Copy missing system libraries
cp $PROOT/usr/lib/aarch64-linux-gnu/libprotobuf.so.32* /usr/lib/aarch64-linux-gnu/ 2>/dev/null
cp $PROOT/usr/lib/aarch64-linux-gnu/7z.so* /usr/lib/aarch64-linux-gnu/ 2>/dev/null
cp $PROOT/usr/lib/aarch64-linux-gnu/libzopfli.so* /usr/lib/aarch64-linux-gnu/ 2>/dev/null

# Upgrade libstdc++ to support newer binaries
cp $PROOT/usr/lib/aarch64-linux-gnu/libstdc++.so.6.0.33 /lib/aarch64-linux-gnu/libstdc++.so.6.0.33.debian
ln -sf libstdc++.so.6.0.33.debian /lib/aarch64-linux-gnu/libstdc++.so.6

# Copy additional libraries needed by cmake and other tools
cp $PROOT/usr/lib/aarch64-linux-gnu/libarchive.so.13 /usr/lib/aarch64-linux-gnu/ 2>/dev/null
cp $PROOT/usr/lib/aarch64-linux-gnu/librhash.so.1 /usr/lib/aarch64-linux-gnu/ 2>/dev/null
cp $PROOT/usr/lib/aarch64-linux-gnu/libuv.so.1 /usr/lib/aarch64-linux-gnu/ 2>/dev/null
cp $PROOT/usr/lib/aarch64-linux-gnu/libjsoncpp.so.26 /usr/lib/aarch64-linux-gnu/ 2>/dev/null
cp $PROOT/usr/lib/aarch64-linux-gnu/libunistring.so.5 /usr/lib/aarch64-linux-gnu/ 2>/dev/null
cp $PROOT/usr/lib/aarch64-linux-gnu/libbrotlidec.so.1 /usr/lib/aarch64-linux-gnu/ 2>/dev/null
cp $PROOT/usr/lib/aarch64-linux-gnu/libzstd.so.1 /usr/lib/aarch64-linux-gnu/ 2>/dev/null
cp $PROOT/usr/lib/aarch64-linux-gnu/libnghttp2.so.14 /usr/lib/aarch64-linux-gnu/ 2>/dev/null
cp $PROOT/usr/lib/aarch64-linux-gnu/libidn2.so.0 /usr/lib/aarch64-linux-gnu/ 2>/dev/null
cp $PROOT/usr/lib/aarch64-linux-gnu/libssl.so.3 /usr/lib/aarch64-linux-gnu/ 2>/dev/null
cp $PROOT/usr/lib/aarch64-linux-gnu/libcrypto.so.3 /usr/lib/aarch64-linux-gnu/ 2>/dev/null

echo "ARM64 fixes applied"
```

### Step 5: Install Working CMake

**Problem**: Termux's cmake fails due to OpenSSL/libcurl symbol mismatch.

**Solution**: Use Debian's cmake with all dependencies.

```bash
# Copy cmake from Debian proot
PROOT=/data/data/com.termux/files/usr/var/lib/proot-distro/containers/debian/rootfs
mkdir -p /opt/android-sdk/cmake/3.22.1/bin
mkdir -p /opt/android-sdk/cmake/3.22.1/share

cp $PROOT/usr/bin/cmake /opt/android-sdk/cmake/3.22.1/bin/cmake
chmod +x /opt/android-sdk/cmake/3.22.1/bin/cmake

# Copy cmake modules
cp -r $PROOT/usr/share/cmake-3.31 /opt/android-sdk/cmake/3.22.1/share/ 2>/dev/null || true

echo "CMake installed: $(/opt/android-sdk/cmake/3.22.1/bin/cmake --version)"
```

### Step 6: Set Up Environment Variables

Add to `~/.bashrc`:

```bash
cat >> ~/.bashrc << 'EOF'

# React Native / Android SDK environment
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=/opt/android-sdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/35.0.0"
export LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu/android:/usr/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH
export GRADLE_OPTS="-Djava.net.preferIPv4Stack=true -Xmx2048m"
EOF

source ~/.bashrc
```

### Step 7: Verify Installation

```bash
echo "=== Verification ==="
echo "Java: $(java -version 2>&1 | head -1)"
echo "Node: $(node -v)"
echo "npm: $(npm -v)"
echo "yarn: $(yarn --version)"
echo "Android SDK: $ANDROID_HOME"
echo "Platforms: $(ls /opt/android-sdk/platforms/ | tr '\n' ', ')"
echo "Build Tools: $(ls /opt/android-sdk/build-tools/ | tr '\n' ', ')"
echo "aapt2: /opt/android-sdk/build-tools/debian/aapt2"
/opt/android-sdk/build-tools/debian/aapt2 2>&1 | head -1
```

---

## Part 2: Building React Native Apps

### Quick Start

```bash
# 1. Source environment
source ~/.bashrc

# 2. Create new project
cd ~/Desktop/projects
npx @react-native-community/cli@latest init MyNewApp --skip-install

# 3. Install dependencies
cd MyNewApp
yarn install

# 4. Configure project for ARM64
cd android
cat > gradle.properties << 'EOF'
# React Native configuration
android.useAndroidX=true
android.enableJetifier=true

# ARM64 fixes - use Debian native tools
android.aapt2FromMavenOverride=/opt/android-sdk/build-tools/debian/aapt2
android.aaptFromMavenOverride=/opt/android-sdk/build-tools/debian/aapt
android.zipalignFromMavenOverride=/opt/android-sdk/build-tools/debian/zipalign

# Gradle settings
org.gradle.jvmargs=-Djava.net.preferIPv4Stack=true -Xmx2048m -XX:MaxMetaspaceSize=512m
org.gradle.daemon=false
reactNativeArchitectures=arm64-v8a,armeabi-v7a

# Disable Hermes (uses JavaScriptCore instead)
hermesEnabled=false

# Disable CMake native builds
android.disableCMake=true
android.disableNativeLibs=true
android.native.buildSupport=false
EOF

# 5. Update build.gradle
sed -i 's/compileSdkVersion = 36/compileSdkVersion = 34/' build.gradle
sed -i 's/targetSdkVersion = 36/targetSdkVersion = 34/' build.gradle

# 6. Build debug APK
export LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu/android:/usr/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH
./gradlew assembleDebug

# 7. Find APK
find . -name "*.apk" -type f
```

### Complete Build Script

Create `~/Desktop/build-rn.sh`:

```bash
#!/bin/bash
set -e

# Source environment
source ~/.bashrc

# Navigate to project
if [ -z "$1" ]; then
    echo "Usage: $0 <project-path>"
    exit 1
fi

cd "$1" || exit 1
cd android || exit 1

# Clean previous builds
rm -rf .gradle app/build

# Set library path for ARM64 tools
export LD_LIBRARY_PATH=/usr/lib/aarch64-linux-gnu/android:/usr/lib/aarch64-linux-gnu:$LD_LIBRARY_PATH

# Build debug APK
echo "Starting build..."
./gradlew assembleDebug

# Show result
APK=$(find app/build/outputs/apk/debug -name "*.apk" -type f | head -1)
if [ -f "$APK" ]; then
    echo ""
    echo "✓ BUILD SUCCESSFUL"
    echo "APK: $APK"
    ls -lh "$APK"
else
    echo ""
    echo "✗ BUILD FAILED: APK not found"
    exit 1
fi
```

Usage:
```bash
chmod +x ~/Desktop/build-rn.sh
~/Desktop/build-rn.sh ~/Desktop/projects/MyApp
```

---

## Project Configuration Reference

### Required gradle.properties

```properties
# ARM64 fixes
android.aapt2FromMavenOverride=/opt/android-sdk/build-tools/debian/aapt2
android.aaptFromMavenOverride=/opt/android-sdk/build-tools/debian/aapt
android.zipalignFromMavenOverride=/opt/android-sdk/build-tools/debian/zipalign

# Memory and network
org.gradle.jvmargs=-Djava.net.preferIPv4Stack=true -Xmx2048m
org.gradle.daemon=false

# Architecture
reactNativeArchitectures=arm64-v8a,armeabi-v7a

# Feature flags
hermesEnabled=false
android.disableCMake=true
android.disableNativeLibs=true
```

### Recommended build.gradle

```groovy
buildscript {
    ext {
        buildToolsVersion = "35.0.0"
        minSdkVersion = 24
        compileSdkVersion = 34
        targetSdkVersion = 34
        ndkVersion = "27.1.12297006"
    }
    // ... rest of buildscript
}
```

---

## Troubleshooting

### DNS/Network Issues
```bash
# Fix DNS resolution
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf
```

### Out of Memory
```bash
# Reduce memory usage
export GRADLE_OPTS="-Djava.net.preferIPv4Stack=true -Xmx1024m"
```

### Kill Competing Builds
```bash
# Kill other gradle/flutter processes
pkill -f "gradle" 2>/dev/null
pkill -f "flutter" 2>/dev/null
```

### Clean Build Cache
```bash
rm -rf android/.gradle
rm -rf android/app/build
```

### aapt2 Not Found Error
```bash
# Verify Debian tools exist
ls -la /opt/android-sdk/build-tools/debian/
/opt/android-sdk/build-tools/debian/aapt2 --version
```

### Library Loading Errors
```bash
# Ensure libraries are in place
ls /usr/lib/aarch64-linux-gnu/android/
ldconfig
```

---

## Environment Summary

| Component | Version | Location |
|-----------|---------|----------|
| Node.js | v24.19.0 | System |
| npm | 11.17.0 | System |
| yarn | 1.22.22 | `/usr/bin/yarn` |
| Java (JDK) | 17.0.20 | `/usr/lib/jvm/java-17-openjdk-arm64` |
| Gradle | 8.14 | Cached in `~/.gradle/wrapper/dists/` |
| Android SDK | Latest | `/opt/android-sdk` |
| Android Platforms | 34, 35, 36 | `/opt/android-sdk/platforms/` |
| Build Tools | 35.0.0, 36.0.0 | `/opt/android-sdk/build-tools/` |
| NDK | 27.1.12297006 | `/opt/android-sdk/ndk/` |
| CMake | 3.31.6 | `/opt/android-sdk/cmake/3.22.1/bin/` |

### ARM64 Fixes Applied
- **aapt2/aapt/zipalign**: Debian ARM64 binaries in `/opt/android-sdk/build-tools/debian/`
- **Android libraries**: Copied to `/usr/lib/aarch64-linux-gnu/android/`
- **libstdc++**: Upgraded to support GLIBCXX_3.4.32
- **System libraries**: protobuf, zopfli, archive, etc. copied from Debian proot

---

## Notes

- **Hermes**: Disabled by default (uses JavaScriptCore instead to avoid CMake issues)
- **New Architecture**: Can be enabled by setting `newArchEnabled=true`
- **Build Time**: ~3-5 minutes on this hardware
- **Memory**: Requires ~2GB available RAM during build
- **Architecture**: Builds for arm64-v8a and armeabi-v7a

---

## APK Installation

```bash
# Via ADB (if device connected)
adb install app/build/outputs/apk/debug/app-debug.apk

# Or copy to device
cp app/build/outputs/apk/debug/app-debug.apk /sdcard/Download/
```

---

# Part 3: Expo Workflow (Recommended for Most Projects)

Expo is a framework built on top of React Native that simplifies development.

## Why Expo?

| Feature | React Native CLI | Expo |
|---------|------------------|------|
| Setup | Manual configuration | Automatic |
| Testing | Build APK every time | Expo Go (instant) |
| Native modules | Manual setup | Managed or custom |
| Build process | Gradle directly | EAS Build or expo run |
| Learning curve | Steeper | Easier |

## Expo Setup (Already Done)

```bash
# Expo CLI is installed
expo --version  # 57.0.21

# Expo project created at:
/root/Desktop/projects/ExpoTest
```

## Using Expo

### 1. Instant Testing (No Build Needed!)

```bash
cd /root/Desktop/projects/ExpoTest
expo start
```

Then:
1. Install "Expo Go" app from Play Store on your phone
2. Scan the QR code shown in terminal
3. App runs instantly on your phone!
4. Hot reload: Save files, see changes immediately

### 2. Build APK with Expo

```bash
# Local build
npx expo run:android

# Or use EAS Build (cloud - recommended)
npx eas build --platform android
```

### 3. Create New Expo Project

```bash
npx create-expo-app@latest MyExpoApp --template blank-typescript
cd MyExpoApp
expo start
```

## Expo Requirements

Same as React Native CLI:
- ✅ Java JDK 17+
- ✅ Android SDK
- ✅ Node.js + npm
- ✅ Gradle (downloaded automatically)

Our environment has everything!

## Expo vs React Native CLI

Use **Expo** when:
- Building most mobile apps
- Want fast development cycle
- Don't need custom native code
- Prefer simpler workflow

Use **React Native CLI** when:
- Need full native control
- Using custom native modules
- Performance-critical apps
- Already have native codebase

## Quick Commands

```bash
# Start Expo development server
expo start

# Build Android APK locally
npx expo run:android

# Build with EAS (cloud)
npx eas build --platform android

# Create new Expo project
npx create-expo-app MyProject --template blank-typescript
```

