# Rust + egui + macroquad Android Build Guide for Termux Proot (ARM64)

Build cross-platform mobile apps with Rust, egui, and macroquad from Termux Proot on ARM64 Linux.

## Project Structure

```
my-app/
├── build-apk.sh        # APK packaging script (required for Android)
├── Cargo.toml          # Package config + Android metadata
├── Android.toml        # (unused - config goes in Cargo.toml)
└── src/
    ├── lib.rs           # App code with #[macroquad::main]
    └── main.rs          # (optional) Desktop entry point
```

## Prerequisites

### 1. Rust Toolchain

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"

# Add Android targets
rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android
```

### 2. Android SDK & NDK

Already installed at `/root/android-sdk/` with:
- platforms: android-30, android-34, android-35, android-36
- build-tools: 34.0.0, 35.0.0, 35.0.1, 36.1.0
- NDK: 28.2.13676358

If missing a platform (e.g. android-30):

```bash
export ANDROID_HOME=/root/android-sdk
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platforms;android-30"
```

### 3. cargo-apk

```bash
cargo install cargo-apk
```

### 4. Native Libraries (for x86_64 QEMU emulation)

```bash
dpkg --add-architecture amd64
apt update
apt install -y libc6:amd64 libstdc++6:amd64 zlib1g:amd64 libedit2:amd64 libncursesw6:amd64 libxml2:amd64
```

### 5. Debian Clang/LLD (native ARM64)

```bash
apt install -y clang lld
```

## NDK Setup (the fix)

The Google NDK ships **x86_64** prebuilt binaries (clang, lld, etc.) that **cannot run** on ARM64 without QEMU. The NDK's clang is PGO/BOLT-optimized and crashes QEMU with "Illegal instruction".

**The fix:** Use Debian's native ARM64 `clang` as a cross-compiler with the NDK's Android sysroot.

### Create Native Linker Wrapper

```bash
cat > /root/android-sdk/ndk-qemu/native-linker-wrapper.sh << 'EOF'
#!/bin/bash
NDK_TOOLCHAIN=/root/android-sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64
exec clang \
  --sysroot=$NDK_TOOLCHAIN/sysroot \
  -resource-dir=$NDK_TOOLCHAIN/lib/clang/19 \
  -rtlib=compiler-rt \
  -target aarch64-linux-android21 \
  "$@"
EOF
chmod +x /root/android-sdk/ndk-qemu/native-linker-wrapper.sh
```

### Create Modified NDK Copy with Native Wrapper

```bash
ORIG_NDK=/root/android-sdk/ndk/28.2.13676358
DEST_NDK=/root/android-sdk/ndk-qemu
NATIVE_WRAPPER=$DEST_NDK/native-linker-wrapper.sh

rm -rf "$DEST_NDK"

# Copy NDK excluding the x86_64 bin directory
cd "$ORIG_NDK"
tar cf - --exclude='toolchains/llvm/prebuilt/linux-x86_64/bin' . \
  | (mkdir -p "$DEST_NDK" && cd "$DEST_NDK" && tar xf -)

# Set up bin directory with native wrapper
mkdir -p "$DEST_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin"
cp "$NATIVE_WRAPPER" "$DEST_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/clang"
cp "$NATIVE_WRAPPER" "$DEST_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++"
cp "$NATIVE_WRAPPER" "$DEST_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/clang-19"
```

### Wrap Remaining x86_64 Build-Tools with QEMU

Some SDK tools (aapt, aidl, dexdump, zipalign) are also x86_64 but work fine via QEMU (they don't use JIT):

```bash
BT_DIR=/root/android-sdk/build-tools/36.1.0
BACKUP_DIR=/root/android-sdk/build-tools/backup-36.1.0
mkdir -p "$BACKUP_DIR"

for f in "$BT_DIR"/*; do
  base=$(basename "$f")
  if [ -x "$f" ] && [ ! -d "$f" ]; then
    filetype=$(file -b "$f" 2>/dev/null)
    if echo "$filetype" | grep -q "x86-64"; then
      cp "$f" "$BACKUP_DIR/$base"
      cat > "$f" << WRAPPER
#!/bin/bash
export LD_LIBRARY_PATH="/root/android-sdk/ndk/28.2.13676358/toolchains/llvm/prebuilt/linux-x86_64/lib/x86_64-unknown-linux-gnu:\$LD_LIBRARY_PATH"
exec qemu-x86_64 "$BACKUP_DIR/$base" "\$@"
WRAPPER
      chmod +x "$f"
    fi
  fi
done
```

> **Warning:** The backup directory is named `backup-36.1.0` (not `36.1.0.backup`) because `cargo-apk` scans directories starting with a digit to find build-tools versions.

## Cargo.toml Configuration

```toml
[package]
name = "my-app"
version = "0.1.0"
edition = "2024"

[package.metadata.android]
apk_name = "MyApp"
package = "com.example.myapp"
build_targets = ["aarch64-linux-android"]

[package.metadata.android.sdk]
min_sdk_version = 21
target_sdk_version = 30

[lib]
name = "my_app"
crate-type = ["cdylib", "staticlib"]

[dependencies]
macroquad = "0.4"
egui = "0.31"
egui-macroquad = "0.17"
```

> **Key points:**
> - Android config goes in `[package.metadata.android]` inside `Cargo.toml` (NOT in `Android.toml`).
> - The library must be `crate-type = ["cdylib"]` for Android (produces a `.so` loaded by NativeActivity).
> - `build_targets` selects which ABIs to build.

## Source Code Template (src/lib.rs)

```rust
use macroquad::prelude::*;

// Required for Android: provides the entry point called by miniquad's JNI glue
#[unsafe(no_mangle)]
pub extern "C" fn quad_main() {
    main();
}

#[macroquad::main("MyApp")]
async fn main() {
    loop {
        clear_background(BLACK);

        egui_macroquad::ui(|ctx| {
            egui::SidePanel::left("nav")
                .resizable(false)
                .default_width(200.0)
                .show(ctx, |ui| {
                    ui.heading("MyApp");
                    ui.separator();
                    ui.label("built with Rust");
                    ui.monospace("macroquad + egui");
                });

            egui::CentralPanel::default().show(ctx, |ui| {
                ui.heading("Home");
                ui.label("Hello from Rust!");
            });
        });

        egui_macroquad::draw();
        next_frame().await
    }
}
```

### Why `quad_main()` is required

On Android, the flow is:
1. Android's `NativeActivity` loads `libmy_app.so`
2. JVM finds `JNI_OnLoad` (from miniquad) and calls `Java_quad_1native_QuadNative_activityOnCreate`
3. That function calls `quad_main()` — an `extern "C"` function **declared** by miniquad but **expected to be defined** by the top-level crate
4. `quad_main()` calls `main()` (generated by `#[macroquad::main]`), which starts the window/game loop

**Without `quad_main()`**, the symbol is undefined and the app crashes immediately on launch with a linker error.

> `#[macroquad::main("MyApp")]` renames the original `async fn main()` to `amain()` and generates a `fn main()` that starts the window via `macroquad::Window::new(...)`.

## Building

### Android APK

> **Important:** `cargo apk` generates APKs using `android.app.NativeActivity`, but miniquad requires a custom Java `MainActivity` with `quad_native.QuadNative` JNI callbacks. Use the `build-apk.sh` script instead.

```bash
./build-apk.sh
```

APK output: `target/aarch64-linux-android/release/MyApp.apk` (debug, auto-signed)

### Desktop (for testing)

```bash
cargo run
```

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `clang: error: unable to execute command: Illegal instruction` | x86_64 NDK clang can't run on ARM64 via QEMU (PGO/BOLT instructions) | Use native ARM64 clang wrapper (see NDK setup above) |
| `Bin is not compatible with Cdylib` | Binary crate type instead of library | Add `[lib] crate-type = ["cdylib"]` and remove `main.rs` |
| `Platform 30 is not installed` | Missing Android platform | Run `sdkmanager "platforms;android-30"` |
| `Configure a release keystore` | Release builds need a signing key | Use `cargo apk build` (debug) or add signing config |
| `No such file or directory` on NDK tool | QEMU wrapper pointing to wrong path | Check backup directory name doesn't start with a digit |
| `quad_main` undefined / app crashes immediately | Missing Android entry point | Add `#[unsafe(no_mangle)] pub extern "C" fn quad_main() { main(); }` to `lib.rs` |
| `AAPT2 Daemon startup failed` | x86_64 aapt2 on ARM64 | Use Debian native `/usr/bin/aapt2` instead of SDK one |
| `Illegal instruction` on zipalign/aapt2/d8 | x86_64 binary on ARM64 | Use Debian native `/usr/bin/aapt2` and `/usr/bin/zipalign`; build-tools shell-scripts (d8, apksigner) invoke Java and work fine |
| App crashes on launch ("continues to stop") | APK uses `android.app.NativeActivity` but miniquad needs custom `MainActivity` | Use `build-apk.sh` instead of `cargo apk` (see Building section) |
| `Unsupported class file major version 65` | Java 21 class files incompatible with old d8 | Compile Java with `--release 11` (handled by `build-apk.sh`) |

## Environment Variables

Add to `~/.bashrc`:

```bash
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
export ANDROID_HOME=/root/android-sdk
export ANDROID_SDK_ROOT=/root/android-sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

## How It Works

```
┌───────────────────────────────────────────────────┐
│  Rust Source (lib.rs)                             │
│  #[macroquad::main] async fn main()               │
│      ↓ cargo build --target aarch64-linux-android │
│  libmy_app.so (ARM64 ELF)                         │
│                                                   │
│  Java Source (from miniquad crate)                │
│  ├── MainActivity.java  (custom Activity)         │
│  └── QuadNative.java    (JNI native method decls) │
│      ↓ javac + d8                                 │
│  classes.dex                                      │
│                                                   │
│      ↓ build-apk.sh packages                      │
│  MyApp.apk                                        │
│  ├── AndroidManifest.xml  (.MainActivity)         │
│  ├── classes.dex          (MainActivity + Quad)   │
│  ├── lib/arm64-v8a/libmy_app.so                   │
│  └── META-INF/            (signing)               │
└───────────────────────────────────────────────────┘
```

Android launches `MainActivity` (a custom `android.app.Activity` subclass). It calls `System.loadLibrary("my_app")`, then invokes `QuadNative.activityOnCreate()` via JNI. miniquad's `Java_quad_1native_QuadNative_activityOnCreate` starts the event loop by calling `quad_main()` (from your `lib.rs`), which runs the macroquad window + egui UI.

## build-apk.sh Script

Place this in your project root:

```bash
#!/usr/bin/env bash
set -eo pipefail

APP_NAME="MyApp"
PACKAGE_NAME="com.example.myapp"
LIB_NAME="my_app"
TARGET="aarch64-linux-android"
ANDROID_JAR="/root/android-sdk/platforms/android-30/android.jar"
BT="/root/android-sdk/build-tools/35.0.1"
AAPT2="/usr/bin/aapt2"
ZIPALIGN="/usr/bin/zipalign"
KEYSTORE="\$PROJECT_DIR/debug.keystore"
KEYSTORE_PASS="android"
KEY_ALIAS="androiddebugkey"

PROJECT_DIR="\$(dirname "\$0")"
TARGET_DIR="\$PROJECT_DIR/target/\$TARGET/release"
STAGING_DIR="/tmp/apk-build-\$APP_NAME"

echo "=== Build Rust .so ==="
CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER=/root/android-sdk/ndk-qemu/native-linker-wrapper.sh \\
  cargo build --target \$TARGET --release

echo "=== Prepare Java ==="
rm -rf "\$STAGING_DIR"
mkdir -p "\$STAGING_DIR/java/quad_native"
# Locate miniquad in cargo registry
MINIQUAD_JAVA=\$(find /root/.cargo/registry/src -path "*/miniquad-*/java" -type d | head -1)
cp "\$MINIQUAD_JAVA/QuadNative.java" "\$STAGING_DIR/java/quad_native/"
sed -e "s/TARGET_PACKAGE_NAME/\$PACKAGE_NAME/g" \\
    -e "s/LIBRARY_NAME/\$LIB_NAME/g" \\
    -e '/^[[:space:]]*\/\/%/d' \\
    "\$MINIQUAD_JAVA/MainActivity.java" > "\$STAGING_DIR/java/MainActivity.java"

echo "=== Compile Java to DEX ==="
javac --release 11 -d "\$STAGING_DIR/classes" -classpath "\$ANDROID_JAR" \\
    "\$STAGING_DIR/java/quad_native/QuadNative.java" "\$STAGING_DIR/java/MainActivity.java"
"\$BT/d8" --lib "\$ANDROID_JAR" --output "\$STAGING_DIR/apk" \\
    \$(find "\$STAGING_DIR/classes" -name "*.class")

echo "=== Create APK ==="
cat > "\$STAGING_DIR/AndroidManifest.xml" << MANIFEST
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
        package="\$PACKAGE_NAME"
        android:versionCode="1"
        android:versionName="0.1.0">
    <uses-sdk android:targetSdkVersion="30" android:minSdkVersion="21" />
    <uses-feature android:glEsVersion="0x00020000" android:required="true"/>
    <application android:hasCode="true" android:label="\$APP_NAME"
            android:theme="@android:style/Theme.DeviceDefault.NoActionBar.Fullscreen">
        <activity android:name=".MainActivity" android:label="\$APP_NAME"
                android:configChanges="orientation|keyboardHidden|screenSize">
            <meta-data android:name="android.app.lib_name" android:value="\$LIB_NAME"/>
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
MANIFEST

"\$AAPT2" link --manifest "\$STAGING_DIR/AndroidManifest.xml" \\
    -I "\$ANDROID_JAR" --auto-add-overlay -o "\$STAGING_DIR/apk/unaligned.apk"

cd "\$STAGING_DIR/apk"
mkdir -p lib/arm64-v8a
zip -q unaligned.apk classes.dex
cp "\$TARGET_DIR/lib\$LIB_NAME.so" lib/arm64-v8a/
zip -q -r unaligned.apk lib/

"\$ZIPALIGN" -p -f -v 4 "\$STAGING_DIR/apk/unaligned.apk" "\$STAGING_DIR/apk/aligned.apk"

if [ ! -f "\$KEYSTORE" ]; then
    keytool -genkey -v -keystore "\$KEYSTORE" -alias "\$KEY_ALIAS" -keyalg RSA -keysize 2048 \\
        -validity 10000 -storepass "\$KEYSTORE_PASS" -keypass "\$KEYSTORE_PASS" \\
        -dname "CN=Android Debug, O=Android, C=US"
fi

"\$BT/apksigner" sign --ks "\$KEYSTORE" --ks-pass "pass:\$KEYSTORE_PASS" \\
    --ks-key-alias "\$KEY_ALIAS" "\$STAGING_DIR/apk/aligned.apk"

cp "\$STAGING_DIR/apk/aligned.apk" "\$TARGET_DIR/\$APP_NAME.apk"
echo "APK: \$TARGET_DIR/\$APP_NAME.apk"
```
