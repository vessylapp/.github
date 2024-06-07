#!/bin/bash

# Print a welcome message
echo "Starting Vessyl Installer..."

# Create a Docker network
echo "Creating Docker network..."
docker network create vessyl-bridge

# Create a Docker volume for MongoDB data
echo "Creating Docker volume for MongoDB data..."
docker volume create mongodb_data

# Run the MongoDB container
echo "Running MongoDB container..."
docker run --network vessyl-bridge --name vdb -v mongodb_data:/data/db --restart always -d mongo:latest

# Pull the latest Vessyl Worker image and run the container
echo "Pulling latest Vessyl Worker image and running the container..."
docker pull ghcr.io/vessylapp/vessyl-worker:latest
docker run --network vessyl-bridge --name vw -d -e MONGO_URI=mongodb://vdb:27017/ -v /var/run/docker.sock:/var/run/docker.sock --restart always ghcr.io/vessylapp/vessyl-worker:latest

# Pull the latest Vessyl UI image and run the container
echo "Pulling latest Vessyl UI image and running the container..."
docker pull ghcr.io/vessylapp/vessyl-ui:latest
docker run --network vessyl-bridge --name vui -d -p 3000:3000 --restart always ghcr.io/vessylapp/vessyl-ui:latest

# Print a success message
echo "Vessyl installed successfully."
echo "Access the web panel at http://localhost:3000 (or your servers IP)"