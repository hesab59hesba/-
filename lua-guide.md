# Guide: Running Lua Game Engines in Termux PRoot

This guide explains how to run lightweight Lua game engines inside a Termux PRoot environment and outlines the most efficient workflow for mobile game development.

---

## 1. Performance Overview by Engine

Because PRoot acts as a translation layer over Android, engines behave differently depending on how they render graphics.

### 📺 GUI-Dependent Engines (Require an X11 Server)
Engines like **LÖVE**, **Defold**, and **Solar2D** require a graphical interface to display windows. 

* **LÖVE (Love2D):** Runs well via `apt install love` inside a Debian/Ubuntu PRoot container. Graphics rely on software rendering or VirGL wrappers, causing a slight framerate drop compared to native execution.
* **Defold:** The desktop editor can launch using Termux:X11, but compiling projects occasionally fails because PRoot intercepts specific internal system calls.
* **Solar2D:** Can run, but manually configuring the Linux build dependencies inside PRoot is highly complex.

### 📟 Headless & Terminal-Friendly Engines (Easiest to Run)
* **TIC-80:** Runs flawlessly. You can compile or run the **headless version** directly inside your PRoot terminal. This allows you to write code and export game cartridge files without launching an Android X11 window server.

---

## 2. Setting Up a Graphical Environment (X11 Method)

To run the visual interfaces of these engines directly inside PRoot, you must bridge the Linux environment to an Android display server.

### Step 1: Install Termux:X11
1. Download and install the latest **Termux:X11 APK** companion app from GitHub.
2. Open Termux (outside PRoot) and install the X11 packages:
   ```bash
   pkg install x11-repo
   pkg install termux-x11-headless
   ```

### Step 2: Configure PRoot Linux
Inside your PRoot container (e.g., Ubuntu or Debian), install a desktop environment and LÖVE:
```bash
apt update
apt install xfce4 xfce4-goodies love -y
```

### Step 3: Launch the Display
1. In a regular Termux session, start the X11 server:
   ```bash
   termux-x11 :1 &
   ```
2. Open your PRoot session, export the display variable, and launch your desktop environment:
   ```bash
   export DISPLAY=:1
   startxfce4 &
   ```
3. Open the Termux:X11 application on your Android device to view your Linux desktop and run your Lua engines.

---

## 3. The Recommended Alternative: The Hybrid Workflow

Forcing a desktop graphical engine to render inside a PRoot translation layer wastes battery and lowers performance. The most efficient method uses PRoot for coding and native Android apps for rendering.

يُرجى استخدام الرمز البرمجي بحذر.+---------------------------+         +----------------------------+|    Termux PRoot (Linux)   |         |      Native Android        ||  - Write Lua code (NeoVim) | ------> |  - Runs LÖVE / TIC-80 APK  ||  - Package into game.love |  Sync   |  - 100% Hardware Speed     |+---------------------------+         +----------------------------+
### Step 1: Install Android Runtime Apps
Install the native Android ports of your preferred engine directly onto your device:
* **LÖVE for Android:** Available via F-Droid or GitHub.
* **TIC-80 Android APK:** Available on GitHub or Itch.io.

### Step 2: Enable Shared Storage
Ensure Termux can access your device's internal storage:
```bash
termux-setup-storage
```

### Step 3: Create an Automated Test Script
Create a bash script inside your PRoot project directory named `run_game.sh`. This script automatically zips your project and pushes it to your Android storage where the native app can run it.

```bash
#!/bin/bash

# Define paths (Adjust "my_game" to your project folder name)
PROJECT_DIR="\$HOME/projects/my_game"
BUILD_DIR="\$HOME/projects/builds"
ANDROID_GAME_DIR="/data/data/com.termux/files/home/storage/shared/Games"

mkdir -p "\$BUILD_DIR"
mkdir -p "\$ANDROID_GAME_DIR"

# 1. Package the Lua files into a standard .love zip file
cd "\$PROJECT_DIR" || exit
zip -9 -r "\$BUILD_DIR/game.love" . -x "*.git*" "run_game.sh"

# 2. Copy to Android shared storage
cp "\(BUILD_DIR/game.love" "\)ANDROID_GAME_DIR/game.love"

echo "Success! Open game.love from your Android 'Games' folder using the LÖVE app."
```

Make the script executable:
```bash
chmod +x run_game.sh
```

Now, write your Lua code inside PRoot using lightweight terminal
