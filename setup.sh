#!/bin/bash

# Exit on error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}==> ${NC}$1"
}

print_warning() {
    echo -e "${YELLOW}==> WARNING: ${NC}$1"
}

print_error() {
    echo -e "${RED}==> ERROR: ${NC}$1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if script is run with sudo
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script with sudo"
    exit 1
fi

# Create config directory if it doesn't exist
mkdir -p ./config

# Install Xcode Command Line Tools if not installed
if ! command_exists xcode-select; then
    print_status "Installing Xcode Command Line Tools..."
    xcode-select --install
    
    # Wait for xcode-select installation to complete
    print_warning "Please wait for Xcode Command Line Tools installation to complete and press any key to continue..."
    read -n 1 -s -r
else
    print_status "Xcode Command Line Tools already installed"
fi

# Install Nix if not installed
if ! command_exists nix; then
    print_status "Installing Nix..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    
    # Source nix
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
    print_status "Nix already installed"
fi

# Clone the repository if it doesn't exist
REPO_NAME="nixMacOs"
REPO_URL="https://github.com/jake-molnia/nixMacOs.git"
REPO_PATH="./config/$REPO_NAME"

if [ ! -d "$REPO_PATH" ]; then
    print_status "Cloning repository..."
    git clone "$REPO_URL" "$REPO_PATH"
else
    print_status "Repository already exists, pulling latest changes..."
    cd "$REPO_PATH"
    git pull
    cd -
fi

# Enable experimental features for flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Run the flake
print_status "Running Nix flake..."
cd "$REPO_PATH"
nix run .#build-switch

print_status "Setup complete! Your Nix system has been configured."
