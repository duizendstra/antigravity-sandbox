# ==========================================
# Antigravity Secure Desktop Dockerfile
# Base: Debian 12 (Bookworm) Slim
# ==========================================
FROM debian:bookworm-slim

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive
# Default password (overridden at runtime)
ENV PASSWORD=password
# Set locale variables to prevent terminal issues
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# ------------------------------------------
# 1. Install Dependencies & Supervisor
# ------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    # System Utilities
    sudo curl gnupg nano ca-certificates procps iproute2 locales \
    # DBus (Critical: 'dbus' provides system.conf, 'dbus-x11' provides session launch)
    dbus dbus-x11 \
    # Remote Access (RDP & VNC)
    xrdp xorgxrdp tigervnc-standalone-server tigervnc-common tigervnc-tools novnc \
    # Desktop Environment (XFCE4)
    xfce4 xfce4-terminal x11-xserver-utils \
    # Browser
    chromium \
    # Process Manager
    supervisor \
    && \
    # Generate Locales (Fixes character encoding issues)
    sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    # Cleanup to reduce image size
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------
# 2. Configure System Defaults
# ------------------------------------------
# Set XFCE Terminal as default
RUN update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/xfce4-terminal 50 && \
    update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal
# Set Chromium as default browser
RUN update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/chromium 50 && \
    update-alternatives --set x-www-browser /usr/bin/chromium

# ------------------------------------------
# 3. Install Antigravity Package
# ------------------------------------------
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | tee /etc/apt/sources.list.d/antigravity.list && \
    apt-get update && apt-get install -y antigravity

# ------------------------------------------
# 4. User Setup (antigravity)
# ------------------------------------------
RUN useradd -m -s /bin/bash antigravity && \
    adduser antigravity sudo && \
    # Create .xsession to tell VNC/XRDP to start XFCE
    echo "exec dbus-launch --exit-with-session startxfce4" > /home/antigravity/.xsession && \
    # Create config directories
    mkdir -p /home/antigravity/.config/xfce4 && \
    mkdir -p /home/antigravity/.vnc && \
    # Ensure ownership
    chown -R antigravity:antigravity /home/antigravity

# ------------------------------------------
# 5. XRDP Configuration
# ------------------------------------------
RUN adduser xrdp ssl-cert && \
    # Use 24-bit color for better performance/compatibility
    sed -i 's/max_bpp=32/max_bpp=24/g' /etc/xrdp/xrdp.ini && \
    # Allow any user to start X sessions (Critical for Docker)
    sed -i 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config || true && \
    # Fix DBus environment variables for XRDP sessions
    echo "unset DBUS_SESSION_BUS_ADDRESS" >> /etc/xrdp/startwm.sh && \
    echo "unset XDG_RUNTIME_DIR" >> /etc/xrdp/startwm.sh

# ------------------------------------------
# 6. Finalize
# ------------------------------------------
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3389 6901
CMD ["/entrypoint.sh"]