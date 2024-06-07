#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo "Docker is not installed. Installing Docker..."
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    echo "Docker installed successfully."
else
    echo "Docker is already installed."
fi

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

# Wait for the Vessyl UI container to be ready
echo "Waiting for Vessyl UI to be ready..."
while ! docker logs vui 2>&1 | grep -q "Ready"
do
  sleep 1
done

# Print a success message
echo "Vessyl installed successfully."
echo "Access the web panel at http://$(curl -4s https://ifconfig.io):3000"
