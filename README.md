*This project has been created as part of the 42 curriculum by eel-abed.*

# 🐳 Inception

## Description
The Inception project is a system administration project from the 42 curriculum. Its goal is to broaden knowledge of system administration by using Docker. We virtualize several Docker images, creating a small but robust infrastructure inside a personal virtual machine. The stack consists of NGINX, WordPress, and MariaDB, each running in its own dedicated, strictly isolated container.

## Project description
This project heavily utilizes **Docker** to containerize the services. The base operating system for all containers is `debian:bullseye`. The sources included in this repository consist of custom `Dockerfile`s for building the required images manually, configuration scripts in bash (`.sh`), and a `docker-compose.yml` file to orchestrate the deployment on a dedicated network. Only the NGINX container is exposed to the outside network as a reverse-proxy securely handling TLS traffic.

### Comparisons and Technical Choices

**Virtual Machines vs Docker**
- Virtual machines virtualize entire hardware stacks, including a full OS kernel for each VM. This makes them heavy and resource-intensive as they duplicate system processes.
- Docker containerizes at the OS level, sharing the host OS kernel among all containers. This makes containers incredibly lightweight, faster to start, and much less resource-heavy while maintaining process isolation.

**Secrets vs Environment Variables**
- Environment variables are often visible in process lists, inspect commands, and system logs, making them potentially vulnerable if they contain sensitive data.
- Docker Secrets (or secure file-based secret management) mounts sensitive data as an isolated in-memory file inside the container, keeping passwords safely hidden from bash histories, logs, and environment inspections.

**Docker Network vs Host Network**
- The `host` network mode connects the container directly to the host's networking stack, removing the network isolation completely.
- A custom `Docker Network` (like the custom bridge used in this project) creates an isolated subnet. Containers can communicate privately securely using their container names as DNS, without exposing their internal ports directly to the host machine.

**Docker Volumes vs Bind Mounts**
- Bind mounts rely heavily on the host machine's directory structure and OS, mapping a specific explicit host path into a container.
- Docker Volumes are directories managed entirely by Docker itself. They are easier to back up, migrate, and safer to use across different operating systems. In this project, to ensure persistence natively, named volumes are configured to map to physical host directories (`/home/eel-abed/data`).

## Instructions

### Compilation and Setup
Make sure you have Docker, Docker Compose, and `make` installed on your machine.
Ensure your `.env` file is properly configured with your credentials inside the `srcs/` folder.

### Execution
To build the images and launch the infrastructure in the background:
```bash
make all
```

To stop all services properly:
```bash
make down
```

To completely delete the containers, images, and networks:
```bash
make clean
```

### Testing without /etc/hosts access (42 Environment)
Since we cannot modify `/etc/hosts` at 42, we use VirtualBox port forwarding (e.g., Host `4443` -> VM Debian `443`). Run this on the physical host machine to map the domain and launch the site:

**On Linux Fedora (Current 42 Workstations):**
```bash
chromium-browser --user-data-dir=/tmp/chrome_dev_test --host-resolver-rules="MAP eel-abed.42.fr 127.0.0.1"
```

**On old iMac 42 or Ubuntu:**
```bash
google-chrome --user-data-dir=/tmp/chrome_dev_test --host-resolver-rules="MAP eel-abed.42.fr 127.0.0.1"
```

Access the site via `https://eel-abed.42.fr:4443/`.

## Resources
- [Docker Documentation](https://docs.docker.com/)
- [NGINX Official Documentation](https://nginx.org/en/docs/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [WordPress Codex](https://codex.wordpress.org/)
- **AI Usage Guidelines:** AI tools (GitHub Copilot / Gemini) were utilized to help translate and format the documentation, generate Markdown structural templates, draft architectural comparisons for the README.md, and assist in terminal commands to debug disk space limitations. No core logic, security configurations, or raw scripts were blindly generated; the AI acted strictly as a pair-programmer and documentarian.
