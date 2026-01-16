# Antigravity Sandbox (Debian 12 + XFCE)

A lightweight, containerized remote desktop environment based on Debian 12 (Bookworm) Slim. It provides a full XFCE4 desktop accessible via RDP (Remote Desktop Protocol) or a Web Browser (NoVNC).

**Purpose:** This image is specifically designed to provide a safe, isolated environment to work and play with **Antigravity from Google**. It comes with the Antigravity package pre-installed and includes a secure Chromium browser for interaction and development.

## Project Structure

Ensure the following three files exist in your build directory:

1.  `Dockerfile` - The image definition.
2.  `entrypoint.sh` - Handles user creation, password generation, and DBus setup.
3.  `supervisord.conf` - Manages the VNC, XRDP, and Web processes.

## Build Instructions

Open a terminal in the project directory and run the following command to build the image:

```bash
docker build -t antigravity-sandbox .
```

*Note: If you modify the entrypoint or configuration files, add the `--no-cache` flag to ensure Docker picks up the changes.*

## Run Instructions

To start the container, run the command below. Note the specific security flags required for the browser and GUI stability.

```bash
docker run -d \
  --name antigravity-sandbox \
  --cap-add=SYS_ADMIN \
  --security-opt apparmor=unconfined \
  -p 3390:3389 \
  -p 6901:6901 \
  -e PASSWORD=SecretPassword123 \
  --shm-size=1g \
  -v $(pwd)/antigravity-data:/home/antigravity \
  ghcr.io/duizendstra/antigravity-sandbox:latest
```

> **Note:** The above command pulls the pre-built image from GitHub Container Registry. To build locally instead, replace the image name with `antigravity-sandbox` (after running the build command below).

### Flag Explanations

*   `--cap-add=SYS_ADMIN`: **Required.** Allows Chromium to create new user namespaces for its sandbox.
*   `--security-opt apparmor=unconfined`: **Required.** Prevents Docker's default AppArmor profile from blocking the browser's internal isolation techniques.
*   `--shm-size=1g`: **Critical.** Increases shared memory. Without this, Chromium and XFCE applications will crash frequently.
*   `-p 3390:3389`: Maps the container's RDP port to host port 3390.
*   `-p 6901:6901`: Maps the container's NoVNC port to host port 6901.
*   `-e PASSWORD=...`: Sets the password for the `antigravity` user, `sudo` access, and VNC.
*   `-v $(pwd)/antigravity-data:/home/antigravity`: **Persistence.** Maps the host folder `antigravity-data` to the container's home directory. This ensures your files are saved on your local machine and not lost when the container is deleted.

## Connection Methods

### 1. RDP: macOS "Windows App" (Recommended)
This offers the best performance, clipboard sharing, and retina resolution support.

1.  Open **Windows App** (formerly *Microsoft Remote Desktop*) on your Mac.
2.  Click the **+** button in the top toolbar and select **Add PC**.
3.  **PC name:** `localhost:3390`
    *   *Note for OrbStack:* You can also use `antigravity-sandbox.orb.local:3390`.
4.  **User account:** Click the dropdown and select **Add User Account...**
    *   **Username:** `antigravity`
    *   **Password:** `SecretPassword123` (or your custom password).
    *   **Friendly name:** `Antigravity User`
    *   Click **Add**.
5.  **Friendly name:** `Antigravity Sandbox`
6.  Click **Add**.
7.  Double-click the new icon to connect.
    *   *Certificate Warning:* You will see a warning because the container uses a self-signed certificate. Click **Continue**.

### 2. Web Browser (NoVNC)
Use this for quick access without installing a client.
*   **OrbStack URL:** http://antigravity-sandbox.orb.local:6901/vnc.html
*   **Localhost URL:** http://localhost:6901/vnc.html
*   **Password:** The value set in the `PASSWORD` environment variable.

## Configuration

### Environment Variables

| Variable | Default | Description |
| :--- | :--- | :--- |
| `PASSWORD` | `password` | Sets the password for the system user and VNC. |

### Changing Screen Resolution
The resolution is defined in the `supervisord.conf` file. To change it:
1.  Open `supervisord.conf`.
2.  Locate the `[program:vnc]` section.
3.  Modify the `-geometry 1920x1080` flag to your desired resolution.
4.  Rebuild the Docker image.

## Security Implications

1.  **Sudo Access:** The `antigravity` user has `sudo` privileges. Combined with the known password, this gives the user root access within the container.
2.  **Network Exposure:** Do not expose ports 3390 or 6901 directly to the public internet. RDP is a frequent target for brute-force attacks. Use an SSH tunnel or VPN.
3.  **Container Privileges:** Running with `--cap-add=SYS_ADMIN` reduces the isolation between the container and the host kernel compared to a standard container. This is necessary for the browser sandbox but should be noted for high-security environments.

## Troubleshooting

**Chromium crashes immediately ("Aw, Snap!")**
Ensure you included `--cap-add=SYS_ADMIN` and `--security-opt apparmor=unconfined` in your run command.

**The Desktop is black or apps crash randomly**
Ensure you included `--shm-size=1g`. Modern GUI applications require significant shared memory buffers.

**"exited: dbus (exit status 1; not expected)"**
This indicates the `machine-id` is missing or the `/var/run/dbus` directory was not created. Ensure you are using the latest `entrypoint.sh` provided in the solution, which handles `dbus-uuidgen` generation.

## License & Disclaimer

**License:** This project is licensed under the MIT License. See the `LICENSE` file for details.

**Disclaimer:**
1.  **Not an Official Product:** This project is an independent, community-driven tool designed to facilitate the use of the "Antigravity" package. It is **not** affiliated with, endorsed by, or maintained by Google LLC.
2.  **Security Warning:** This container is configured with reduced security isolation (`--cap-add=SYS_ADMIN`, `apparmor=unconfined`) to enable specific browser functionalities. It also includes `sudo` access for the default user.
    *   **Do not** expose this container directly to the public internet.
    *   **Do not** use this container to process sensitive personal or financial data.
    *   The authors assume no responsibility for any security compromises or data loss resulting from the use of this configuration.