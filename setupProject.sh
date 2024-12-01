#!/bin/bash

# Environment setup script for distributed LLM processing
set -e  # Exit on error

# NFS directory where we'll create the virtual environment
NFS_DIR="/mnt/bigbird"
VENV_DIR="$PWD/venv"

echo "Setting up Python environment in $VENV_DIR..."


# Create necessary directories
mkdir -p ./data 
mkdir -p ./logs 
mkdir -p ./src  
mkdir -p ./config 
mkdir -p ./tests 

# Create virtual environment using Python 3.9
python3 -m venv "$VENV_DIR"

if [ ! -d "$VENV_DIR" ]; then
    echo "Failed to create virtual environment in $VENV_DIR"
    exit 1
fi

echo "Virtual environment created successfully."

# Activate the virtual environment and install dependencies
source "$VENV_DIR/bin/activate"

pip install --upgrade pip

# Install specified versions from requirements.txt
pip install -r requirements.txt

if [ $? -ne 0 ]; then
    echo "Failed to install dependencies."
    deactivate
    exit 1
fi

echo "Python environment setup complete!"
echo "Virtual environment location: $VENV_DIR"
echo "To activate: source $VENV_DIR/bin/activate"

# Deactivate the virtual environment after installation if necessary
deactivate






