#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "================================================="
echo "       Antigravity Desktop - Startup Script      "
echo "================================================="

# -------------------------------------------------------
# 1. Dynamic Password Configuration
# -------------------------------------------------------
if [ "$PASSWORD" == "password" ]; then
    echo "[WARN] Using default password 'password'."
    echo "[WARN] Please set the PASSWORD environment variable for security."
else
    echo "[INFO] Setting custom password for user 'antigravity'..."
fi

# Set the system user password (for sudo access)
echo "antigravity:$PASSWORD" | chpasswd

# Set the VNC password (for remote access)
# We run this as the user to ensure file permissions are correct (~/.vnc/passwd)
su - antigravity -c "mkdir -p ~/.vnc && echo '$PASSWORD' | tigervncpasswd -f > ~/.vnc/passwd && chmod 600 ~/.vnc/passwd"

# -------------------------------------------------------
# 2. DBus Initialization
# Critical for XFCE4. Without this, the desktop environment fails.
# -------------------------------------------------------
echo "[INFO] Configuring DBus..."
mkdir -p /var/run/dbus

# Generate a machine-id if it doesn't exist (required by dbus-daemon)
if [ ! -f /var/lib/dbus/machine-id ]; then
    dbus-uuidgen > /var/lib/dbus/machine-id
fi

# -------------------------------------------------------
# 3. Stale Lock Cleanup
# If the container was restarted, old locks might prevent startup.
# -------------------------------------------------------
echo "[INFO] Cleaning up stale X11 locks..."
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1 /var/run/xrdp.pid /var/run/xrdp-sesman.pid

# -------------------------------------------------------
# 4. Start Process Manager
# We use 'exec' so Supervisord becomes PID 1 (handling signals correctly)
# -------------------------------------------------------
echo "[INFO] Starting Supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf