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

# Check if script is run with sudo
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script with sudo"
    exit 1
fi

# Define repository information
REPO_NAME="nixMacOs"
REPO_PATH="./config/$REPO_NAME"

# Check if repository exists
if [ ! -d "$REPO_PATH" ]; then
    print_error "Repository not found at $REPO_PATH. Please run setup.sh first."
    exit 1
fi

# Update repository
print_status "Updating repository..."
cd "$REPO_PATH"

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    print_warning "You have uncommitted changes in your repository."
    print_warning "Please commit or stash your changes before updating."
    exit 1
fi

# Pull latest changes
print_status "Pulling latest changes..."
git pull

# Update flake inputs
print_status "Updating flake inputs..."
nix flake update

# Rebuild system
print_status "Rebuilding system with updated flake..."
nix run .#build-switch

print_status "Update complete! Your Nix system has been updated and rebuilt."