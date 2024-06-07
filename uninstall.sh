#!/bin/bash

# Stop the Docker containers
docker stop vw vdb vui

# Remove the Docker containers
docker rm vw vdb vui

# Remove the Docker network
docker network rm vessyl-bridge

# Remove the Docker volume
docker volume rm mongodb_data

echo "Uninstallation completed."
