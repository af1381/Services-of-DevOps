
# Jellyfin Installation with Docker Compose 🎬🐳

This guide provides the steps to install Jellyfin on your system using Docker Compose. The installation will be set up in the `/opt/jellyfin` directory.

## Prerequisites ✅

Before you begin, make sure you have the following installed on your machine:

- Docker 🐋
- Docker Compose 🧑‍💻

## Steps 📝

### 1. Create the `/opt/jellyfin` Directory 🗂️

First, you need to create the directory where Jellyfin's files will be stored. Run the following command:

```bash
sudo mkdir -p /opt/jellyfin
```

### 2. Create the `docker-compose.yml` File ✍️

Now, you need to create the `docker-compose.yml` file in the `/opt/jellyfin` directory. To do this, run the following commands:

```bash
cd /opt/jellyfin
nano docker-compose.yml
```

Then, paste the following content into the `docker-compose.yml` file:

```yaml
version: "3.8"
services:
  jellyfin:
    image: jellyfin/jellyfin
    container_name: jellyfin
    restart: unless-stopped
    ports:
      - "8096:8096"
    volumes:
      - /opt/jellyfin/config:/config
      - /opt/jellyfin/data:/data
      - /opt/jellyfin/cache:/cache
    environment:
      - UID=1000
      - GID=1000
    networks:
      - jellyfin-network
networks:
  jellyfin-network:
    driver: bridge
```

This file defines the Jellyfin service and its configuration, including port mapping, volume mounts for configuration, data, and cache storage, as well as setting the user and group IDs.

### 3. Start Jellyfin with Docker Compose 🚀

Once the `docker-compose.yml` file is in place, you can start Jellyfin by running the following command:

```bash
sudo docker-compose up -d
```

This command will download the Jellyfin Docker image (if not already downloaded) and start the Jellyfin container in detached mode.

### 4. Access Jellyfin 🎥

After the container is up and running, you can access Jellyfin through your web browser. Open your browser and go to:

```
http://<IP-Address>:8096
```

Replace `<IP-Address>` with the IP address of your server. You should now see the Jellyfin setup page, where you can complete the configuration process.

## Notes ℹ️

- The Jellyfin data, configuration, and cache will be stored in `/opt/jellyfin` on your server.
- You can customize the `docker-compose.yml` file to add additional settings, such as configuring SSL 🔒 or changing the ports 🔄.

## Stopping Jellyfin ⏹️

To stop Jellyfin, run the following command:

```bash
sudo docker-compose down
```

This will stop the container and remove it. Your data will still be preserved in the `/opt/jellyfin` directory.

## Troubleshooting 🛠️

If you encounter any issues, check the logs for the Jellyfin container with the following command:

```bash
sudo docker logs jellyfin
```

---

Enjoy using Jellyfin! 🎉
