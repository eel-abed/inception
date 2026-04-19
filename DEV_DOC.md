# Developer Documentation (DEV_DOC.md)

This technical document assists developers in building, setting up, and managing the project stack natively using Docker.

## 1. Set Up the Environment from Scratch
**Prerequisites:** You require a Linux machine (or a VM running Debian/Ubuntu natively/VirtualBox) with `docker`, `docker-compose`, and `make` installed.

**Initial Configuration:**
1. Clone the project repository.
2. Inside the `srcs` directory, ensure a `.env` file exists containing the crucial environment variables (Database Names, User Passwords, Site URL `DOMAIN_NAME`). Do not hardcode these.
3. For enhanced security (Docker Secrets), create the required secret files in a separate path if configured that way.
4. Mount Points Creation: Verify that `/home/eel-abed/data/mariadb` and `/home/eel-abed/data/wordpress` can be created (handled by the Makefile) to link the containers' volumes.

## 2. Build and Launch the Project
This project orchestrates Docker resources through a powerful, fully-featured `Makefile`:
*   **Compile:** From the root folder, run:
    ```bash
    make all
    ```
    This natively interprets your `srcs/docker-compose.yml` file, forcing `docker compose` to build images directly from the explicit `Dockerfile` parameters for each of the three services concurrently.
*   The `docker-compose.yml` implicitly links the architecture together on an isolated network bridge naturally termed `inception`.

## 3. Relevant Commands to Manage Containers and Volumes
Here are fundamental actions a developer uses during testing routines:
*   `make down`: Triggers `docker compose down` inside `srcs/`, removing the running containers carefully without losing the network references or underlying images.
*   `make clean`: Full removal of architecture nodes, scrubbing containers, dangling images, and wiping out the `inception` custom network explicitly.
*   `make fclean`: Wipes the entire stack cleanly, mimicking a pristine developer install by aggressively deleting the host volume directories recursively with `sudo rm -rf`.
*   `docker logs -f <container_name>`: Extremely useful debugging tool to actively check what NGINX, WordPress-CLI, or MariaDB is outputting globally.
*   `docker exec -it <container_name> bash` (or `sh`): Instantiates an interactive bash prompt right into the running file system to fix inner variables physically.

## 4. Where Project Data is Stored and How it Persists
To pass stringent tests involving power reboots or a complete `make down`, Docker Volumes guarantee memory and state persistence natively by bypassing ephemeral container memory constraints natively.
*   **MariaDB Persistence:** Data from MySQL databases is safely cached entirely on the localized host workstation disk at `/home/eel-abed/data/mariadb`, mapping accurately natively inside the container at `/var/lib/mysql`.
*   **WordPress Content Persistence:** Uploaded files, generated CSS structure, and customized themes stay persistent by binding local `/home/eel-abed/data/wordpress` with inner mapped routing `/var/www/wordpress`.
*   Thus, even upon explicit container deletions, because these mounts interact natively with the workstation’s rigid disk, zero data sets are lost naturally between reboots or restarts!
