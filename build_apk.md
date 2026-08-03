# Build APK Workflow

## Constraints (ARM64 Termux Proot)
- `compileSdk` MUST be `34` or lower — the Debian ARM64 `aapt2` doesn't support SDK 35/36 resources
- Gradle 8.14 is cached at `~/.gradle/wrapper/dists/gradle-8.14-all/` — use it to avoid download timeouts
- aapt2 override MUST be set: `android.aapt2FromMavenOverride=/usr/lib/android-sdk/build-tools/debian/aapt2`
- Flutter SDK is at `/opt/flutter` (NOT `/root/android-sdk`)

## Per-project Gradle Properties
`android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx1536M
android.useAndroidX=true
android.enableJetifier=true
flutter.sdk=/opt/flutter
```

## Global Gradle Properties
`~/.gradle/gradle.properties`:
```properties
android.aapt2FromMavenOverride=/usr/lib/android-sdk/build-tools/debian/aapt2
org.gradle.jvmargs=-Djava.net.preferIPv4Stack=true -Xmx1536m
```

## Gradle Wrapper
If missing, generate from any temp directory (NOT inside the android project — Flutter plugin will trigger NDK download):
```bash
mkdir -p /tmp/gradlewrap && cd /tmp/gradlewrap
touch settings.gradle
gradle wrapper --gradle-version 8.14
cp gradlew gradle/wrapper/gradle-wrapper.jar /path/to/app/android/
```

## Build Command
```bash
cd /path/to/app
flutter build apk --debug
```

Output: `app/build/app/outputs/flutter-apk/app-debug.apk`

## Verify First
```bash
cd /path/to/app
flutter analyze --no-fatal-infos --no-fatal-warnings
```

## Troubleshooting

| Error | Fix |
|-------|-----|
| `AAPT2 Daemon startup failed` | Set `android.aapt2FromMavenOverride=/usr/lib/android-sdk/build-tools/debian/aapt2` |
| `flutter.sdk not set` | Point to `/opt/flutter` in `android/gradle.properties` |
| Gradle download timeout | Use `gradle wrapper --gradle-version 8.14` (cached) |
| NDK downloads during `gradle wrapper` | Run wrapper from an empty temp dir, not inside the android project |
