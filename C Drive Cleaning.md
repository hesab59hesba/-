# C: Drive Cleaning Checklist

Run these when C: drive gets full again (reclaim ~12-16 GB total).

> **Note**: The system-level `C:\.gradle\caches` (5+ GB) is separate from the user-profile one and was the biggest space hog. Don't skip it.

## 1. Package Manager Caches
```powershell
npm cache clean --force
yarn cache clean
```

## 2. Gradle Build Cache
```powershell
Remove-Item -Path "$env:USERPROFILE\.gradle\caches" -Recurse -Force
Remove-Item -Path "C:\.gradle\caches" -Recurse -Force
```

## 3. Dart/Flutter Pub Cache
```powershell
Remove-Item -Path "$env:LOCALAPPDATA\Pub" -Recurse -Force
```

## 4. Temp Folders
```powershell
Get-ChildItem -Path "$env:LOCALAPPDATA\Temp" -Recurse -Force | Remove-Item -Recurse -Force
Get-ChildItem -Path "C:\Windows\Temp" -Recurse -Force | Remove-Item -Recurse -Force
```

## 5. All-in-One (run in admin PowerShell)
```powershell
npm cache clean --force
yarn cache clean
Remove-Item -Path "$env:USERPROFILE\.gradle\caches" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\.gradle\caches" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\Pub" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
```
