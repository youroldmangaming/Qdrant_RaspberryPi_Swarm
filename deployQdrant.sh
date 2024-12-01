#!/bin/bash

# Function to log messages with timestamp
log() {
    echo "[$(date)] $1"
}

# Function to run command with timeout
run_ssh_command() {
    local host=$1
    local cmd=$2
    timeout $TIMEOUT sshpass -p "$SSH_PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 rpi@$host "echo '$SSH_PASSWORD' | sudo -S $cmd"
    return $?
}

# Configuration
MANAGER_NODE="rpi41"
MANAGER_IP="192.168.188.141"
WORKER_NODES=(
    "rpi51:192.168.188.151"
    "rpi52:192.168.188.152"
    "rpi53:192.168.188.153"
    "rpi54:192.168.188.154"
)
IMAGE_NAME="qdrant-arm:local"
SSH_PASSWORD="changene""
NFS_PATH="/mnt/bigbird"
TIMEOUT=30  # Define a timeout value

# Deploy the stack
log "Deploying Qdrant stack..."
sshpass -p "$SSH_PASSWORD" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
    rpi@$MANAGER_IP "echo '$SSH_PASSWORD' | sudo -S docker stack deploy -c ${NFS_PATH}/rpi41/qdrant/docker-compose.yml qdrant"
