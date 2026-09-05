# Expo Compatibility Fixes for Termux PRoot Debian

Complete guide for fixing Expo SDK compatibility issues in Termux PRoot Debian (ARM64) environment.

---

## Problem Summary

When building React Native apps with Expo in this environment, multiple version compatibility issues occur:

1. **Expo Go version mismatch** - App shows "Project is incompatible with this version of Expo Go"
2. **TurboModuleRegistry errors** - `PlatformConstants could not be found`
3. **Module resolution failures** - `Unable to resolve "react-native/Libraries/Utilities/DevLoadingView"`
4. **SDK version cache issues** - Expo Go shows old SDK version

---

## Root Causes

### 1. Expo Go App Version vs Project SDK Version

**Error:**
```
Project is incompatible with this version of Expo Go
The installed version of Expo Go is for SDK 57.
The project you opened uses SDK 54.
```

**Cause:** The `app.json` file had an outdated `sdkVersion` that didn't match the installed Expo package.

**Fix:**
```json
{
  "expo": {
    "name": "MyExpoApp",
    "slug": "MyExpoApp",
    "version": "1.0.0",
    "sdkVersion": "57.0.0"  // Must match installed Expo version
  }
}
```

---

### 2. React Native Version Mismatch

**Error:**
```
Invariant Violation: Turbo ModuleRegistry.getEnforcing(...): 
'PlatformConstants' could not be found.
```

**Cause:** Installing wrong React Native version for the Expo SDK.

**Expo SDK 57 Requirements (from official docs):**
| Package | Required Version |
|---------|------------------|
| expo | 57.0.19 |
| react | 19.2.3 |
| react-native | 0.86.3 |

**Fix:**
```bash
cd ~/Desktop/projects/MyExpoApp
rm -rf node_modules package-lock.json
npm install expo@57.0.19 react@19.2.3 react-native@0.86.3 --legacy-peer-deps
```

---

### 3. Metro Bundler Cache Issues

**Error:**
```
An unknown error occurred while installing React Native DevTools
ENOENT: no such file or directory, watch '...negotiator/lib'
```

**Cause:** Stale Metro cache from previous builds.

**Fix:**
```bash
npx expo start --clear
```

---

### 4. npm Dependency Conflicts

**Error:**
```
npm error code ETARGET
notarget No matching version found for expo-status-bar@~7.0.0
```

**Cause:** Trying to install incompatible package versions.

**Fix:** Use `--legacy-peer-deps` flag:
```bash
npm install expo@57.0.19 react@19.2.3 react-native@0.86.3 --legacy-peer-deps
```

---

## Complete Fix Script

Run this to fix all Expo compatibility issues:

```bash
#!/bin/bash
set -e

PROJECT_DIR="$HOME/Desktop/projects/MyExpoApp"
cd "$PROJECT_DIR"

# 1. Clean everything
echo "Cleaning project..."
rm -rf node_modules package-lock.json .expo

# 2. Create proper package.json
cat > package.json << 'EOF'
{
  "name": "myexpoapp",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "expo start",
    "android": "expo start --android",
    "ios": "expo start --ios",
    "web": "expo start --web"
  },
  "dependencies": {
    "expo": "~57.0.0",
    "expo-status-bar": "~2.0.0",
    "react": "19.2.3",
    "react-native": "0.86.3"
  },
  "devDependencies": {
    "@types/react": "~19.2.0",
    "typescript": "~5.3.3"
  },
  "private": true
}
EOF

# 3. Fix app.json SDK version
cat > app.json << 'EOF'
{
  "expo": {
    "name": "MyExpoApp",
    "slug": "MyExpoApp",
    "version": "1.0.0",
    "sdkVersion": "57.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "userInterfaceStyle": "light",
    "ios": {
      "supportsTablet": true
    },
    "android": {
      "adaptiveIcon": {
        "backgroundColor": "#E6F4FE"
      }
    }
  }
}
EOF

# 4. Install with legacy peer deps
echo "Installing dependencies..."
npm install --legacy-peer-deps

# 5. Verify versions
echo ""
echo "=== Installed Versions ==="
node -e "console.log('Expo:', require('./node_modules/expo/package.json').version)"
node -e "console.log('React:', require('./node_modules/react/package.json').version)"
node -e "console.log('React Native:', require('./node_modules/react-native/package.json').version)"
echo ""
echo "=== Starting Expo ==="
npx expo start --clear
```

---

## Expo SDK Version Compatibility Table

| Expo SDK | React Native | React | Minimum Node.js |
|----------|--------------|-------|-----------------|
| 57.0.0   | 0.86         | 19.2.3| 22.13.x         |
| 56.0.0   | 0.85         | 19.2.3| 20.19.x         |
| 55.0.0   | 0.83         | 19.2.0| 20.19.x         |
| 54.0.0   | 0.81         | 19.1.0| 20.19.x         |

**Important:** Always check [docs.expo.dev](https://docs.expo.dev/versions/) for the latest compatibility matrix.

---

## Expo Go Version Issues

### Problem
Expo Go app version doesn't match project SDK version.

### Solutions

**Option 1: Update Expo Go from GitHub**
```
https://github.com/expo/expo-go/releases
```
Download the latest APK and install manually.

**Option 2: Match project SDK to Expo Go version**
If your Expo Go shows SDK 54, create project with SDK 54:
```bash
npm install expo@54.0.0 expo-status-bar@2.0.0 --legacy-peer-deps
```
And update `app.json`:
```json
{
  "expo": {
    "sdkVersion": "54.0.0"
  }
}
```

---

## Common Errors and Fixes

### Error: "Unable to resolve react-native/Libraries/Utilities/DevLoadingView"

**Fix:** Ensure React Native version matches Expo SDK requirement:
```bash
npm install react-native@0.86.3 --legacy-peer-deps
```

### Error: "Cannot find module './node_modules/expo/package.json'"

**Fix:** Reinstall dependencies:
```bash
rm -rf node_modules
npm install --legacy-peer-deps
```

### Error: "Project is incompatible with this version of Expo Go"

**Fix:** Update `app.json` sdkVersion to match installed Expo:
```bash
node -e "console.log(require('./node_modules/expo/package.json').version)"
# Update app.json with this version
```

---

## Verification Commands

Check if everything is compatible:
```bash
cd ~/Desktop/projects/MyExpoApp

# Check installed versions
echo "Expo:" && node -e "console.log(require('./node_modules/expo/package.json').version)"
echo "React:" && node -e "console.log(require('./node_modules/react/package.json').version)"
echo "React Native:" && node -e "console.log(require('./node_modules/react-native/package.json').version)"

# Check app.json
cat app.json | grep sdkVersion

# Start with clean cache
npx expo start --clear
```

---

## Notes

- Always use `--legacy-peer-deps` when installing Expo packages
- Keep `app.json` sdkVersion in sync with installed Expo version
- Clear Metro cache (`--clear`) when switching between versions
- Expo Go must be updated separately from Play Store or GitHub
