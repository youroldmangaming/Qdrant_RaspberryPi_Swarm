#!/bin/bash

# Set timeout for SSH connections
TIMEOUT=10

# Function to log messages with timestamp
log() {
    echo "[$(date)] $1"
}

# Function to run command with timeout
run_ssh_command() {
    local host=$1
    local cmd=$2
    timeout $TIMEOUT sshpass -p "changeme" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 rpi@$host "echo 'changeme' | sudo -S $cmd"
    return $?
}




# Swarm configuration
JOIN_TOKEN="SWMTKN-1-1ei2c6p5g1pmfzwyw90eenkkz9b6znksd7n2k0ymcdg8lfj3zm-897yktv7nmzh5edpsu1sjdxkh"
MANAGER_IP="192.168.188.141"
WORKERS=(
    "192.168.188.151"
    "192.168.188.152"
    "192.168.188.153"
    "192.168.188.154"
)


# Initialize new swarm on manager
log "Initializing new swarm on manager..."
swarm_init=$(run_ssh_command $MANAGER_IP "docker swarm init --advertise-addr $MANAGER_IP")
if [ $? -ne 0 ]; then
    log "Failed to initialize swarm on manager"
    exit 1
fi

# Get new join token
log "Getting new join token..."
JOIN_TOKEN=$(run_ssh_command $MANAGER_IP "docker swarm join-token worker -q")
if [ $? -ne 0 ]; then
    log "Failed to get join token"
    exit 1
fi

# Join each worker to the new swarm
for node in "${WORKERS[@]}"; do
    log "Adding node $node to swarm..."
    run_ssh_command $node "docker swarm join --token $JOIN_TOKEN $MANAGER_IP:2377" || {
        log "Failed to add $node to swarm"
        continue
    }
    log "Successfully added $node to swarm"
done

# Verify final swarm state
log "Final verification of swarm nodes..."
verify_output=$(run_ssh_command $MANAGER_IP "docker node ls")
echo "$verify_output"

log "Script completed"









