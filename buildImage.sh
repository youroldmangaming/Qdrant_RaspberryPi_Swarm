#!/bin/bash

# SSH credentials for the nodes
USERNAME="rpi"
PASSWORD="changeme"
BUILD_NODE="192.168.188.153"  # rpi53

# Function for SSH with password
ssh_cmd() {
    local node=$1
    local cmd=$2
    echo "Executing on $node: $cmd"
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $USERNAME@$node "$cmd"
}

# Function for SCP with password
scp_cmd() {
    local src=$1
    local node=$2
    local dest=$3
    echo "Copying $src to $node:$dest"
    sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no $src $USERNAME@$node:$dest
}

echo "Setting up build environment on rpi53..."

# Create build directory on NVMe drive
ssh_cmd "$BUILD_NODE" "sudo mkdir -p /mnt/nvme/qdrant-build && sudo chown -R $USERNAME:$USERNAME /mnt/nvme/qdrant-build"

# Copy Dockerfile and other necessary files
scp_cmd "Dockerfile_qdrant_raspberry_pi" "$BUILD_NODE" "/mnt/nvme/qdrant-build/Dockerfile"

# Install required packages on build node
ssh_cmd "$BUILD_NODE" "sudo apt-get update && sudo apt-get install -y docker.io sshpass"

# Build the image on rpi53
echo "Building Qdrant ARM image on rpi53..."
ssh_cmd "$BUILD_NODE" "cd /mnt/nvme/qdrant-build && sudo docker build -t qdrant-arm:local -f Dockerfile ."

# Save the image to a tar file
echo "Saving image to tar file..."
ssh_cmd "$BUILD_NODE" "cd /mnt/nvme/qdrant-build && sudo docker save qdrant-arm:local > qdrant-arm.tar"

# Array of other nodes to distribute to
OTHER_NODES=(
    "192.168.188.141"  # rpi41
    "192.168.188.151"  # rpi51
    "192.168.188.152"  # rpi52
    "192.168.188.154"  # rpi54
)

# Copy and load the image on other nodes
for node in "${OTHER_NODES[@]}"; do
    echo "Copying and loading image on $node..."
    ssh_cmd "$node" "mkdir -p ~/qdrant-build"
    ssh_cmd "$BUILD_NODE" "cd /mnt/nvme/qdrant-build && sshpass -p '$PASSWORD' scp -o StrictHostKeyChecking=no qdrant-arm.tar $USERNAME@$node:~/qdrant-build/"
    ssh_cmd "$node" "cd ~/qdrant-build && sudo docker load < qdrant-arm.tar"
done

echo "Build and distribution complete!"


