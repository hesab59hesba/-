#!/data/data/com.termux/files/usr/bin/bash

# ============================================================
# How to use:
#   chmod +x /data/data/com.termux/files/home/desktop4.sh
#   ln -sf /data/data/com.termux/files/home/desktop4.sh ~/bin/desktop4
#   desktop4
# ============================================================
# ubuntu4 — first-run setup (run once inside the container):
#   proot-distro login ubuntu4 --shared-tmp -- bash -c "
#     apt-get update && apt-get install -y xfce4 xfce4-goodies \
#       xrdp tightvncserver gvfs \
#       thunar thunar-archive-plugin \
#       pulseaudio-utils pavucontrol htop neofetch curl wget \
#       file-roller geany libreoffice \
#       fonts-noto fonts-noto-cjk fonts-liberation \
#       git nodejs npm firefox
#   "
# ============================================================

# Cleanup
pkill -f com.termux.x11
pkill -f virgl
pkill -9 pulseaudio
rm -rf $TMPDIR/.X11-unix /tmp/.X11-unix

# 1. Start VirGL Server
virgl_test_server_android &

# 2. Start PulseAudio in TCP Mode (Android Side)
# This removes the need for the Unix socket which often fails in PRoot
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1

# 3. Start Termux-X11 (Add the MIT-SHM extension fix)
termux-x11 :3 -ac -legacy-drawing -extension MIT-SHM &

am start -n com.termux.x11/com.termux.x11.MainActivity
sleep 2

# 4. Login to Ubuntu4
proot-distro login ubuntu4 --shared-tmp -- bash -c "
    export DISPLAY=:3
    # Tell Ubuntu to use the network for sound
    export PULSE_SERVER=127.0.0.1
    export GALLIUM_DRIVER=virpipe
    export MESA_GL_VERSION_OVERRIDE=4.0
# These two lines stop the 'Failed to attach to x11 shm' errors
    export GDK_DISABLE_XSHM=1
    export QT_X11_NO_MITSHM=1

    # Fix: Disable power management signals that cause blinking
    xset -dpms s off

    # Add this line to your script before to solve copilot signin in vscode
    eval \$(gnome-keyring-daemon --start --components=secrets)

    # Fix: Use dbus-run-session for a more stable taskbar
    dbus-run-session startxfce4
"
