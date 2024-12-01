#!/bin/bash

# Configuration
NODES=(
    "rpi41"
    "rpi51"
    "rpi52"
    "rpi53"
    "rpi54"
)
NODE_IPS=(
    "192.168.188.151"
    "192.168.188.152"
    "192.168.188.153"
    "192.168.188.154"
)
PASSWORD="changeme"
NFS_PATH="/mnt/bigbird"

# Create storage directories on NFS
for NODE in "${NODES[@]}"; do
    echo "[$(date)] Creating storage directory on ${NODE}..."
    mkdir -p "${NFS_PATH}/${NODE}/qdrant/storage"
    chmod -R 777 "${NFS_PATH}/${NODE}/qdrant"
    mkdir -p "${NFS_PATH}/${NODE}/qdrant/config"
    mkdir -p "${NFS_PATH}/${NODE}/qdrant/static"
    touch "${NFS_PATH}/${NODE}/qdrant/config/config"
    touch "${NFS_PATH}/${NODE}/qdrant/config/development"
   
#    echo "cp production.yaml ${NFS_PATH}/${NODE}/qdrant/config/config.yaml" 
#    cp production.yaml "${NFS_PATH}/${NODE}/qdrant/config/config.yaml" 

#    echo "cp raft.json ${NFS_PATH}/${NODE}/qdrant/storage/raft_state.json" 
#    cp raft.json "${NFS_PATH}/${NODE}/qdrant/storage/raft_state.json" 
done

echo "[$(date)] Storage setup completed"


echo "copy qdrant swarm setup to manager node to ${NFS_PATH}/rpi41/qdrant"
echo "cp ./qdrant-swarm.yml ${NFS_PATH}/rpi41/qdrant"
cp ./docker-compose.yml "${NFS_PATH}/rpi41/qdrant"




