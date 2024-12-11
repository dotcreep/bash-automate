#!/bin/bash

# Update the package list
echo "Updating package list..."
sudo apt update

# Upgrade installed packages
echo "Upgrading installed packages..."
sudo apt upgrade -y

# Clean up unused packages
echo "Removing unused packages..."
sudo apt autoremove -y

echo "Package update completed."