#!/bin/bash


INSTALL_DIR="/opt/jellyfin"

echo "Creating installation directory at $INSTALL_DIR..."
sudo mkdir -p $INSTALL_DIR

echo "Creating docker-compose.yml file..."
cat <<EOL | sudo tee $INSTALL_DIR/docker-compose.yml > /dev/null
version: "3.8"
services:
  jellyfin:
    image: jellyfin/jellyfin
    container_name: jellyfin
    restart: unless-stopped
    ports:
      - "8096:8096"
    volumes:
      - $INSTALL_DIR/config:/config
      - $INSTALL_DIR/data:/data
      - $INSTALL_DIR/cache:/cache
    environment:
      - UID=1000
      - GID=1000
    networks:
      - jellyfin-network
networks:
  jellyfin-network:
    driver: bridge
EOL

echo "Starting Jellyfin container with Docker Compose..."
sudo docker-compose -f $INSTALL_DIR/docker-compose.yml up -d

echo "Checking if the Jellyfin container is running..."
sudo docker ps

echo "Jellyfin installation and container setup is complete! You can access Jellyfin at http://<IP-Address>:8096"
