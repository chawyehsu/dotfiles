#!/bin/bash

# Function to install PowerShell on Ubuntu
ubuntu_install_pwsh() {
    # https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu
    # Update the list of packages
    sudo apt-get update
    # Install pre-requisite packages.
    sudo apt-get install -y wget apt-transport-https software-properties-common
    # Download the Microsoft repository GPG keys
    wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
    # Register the Microsoft repository GPG keys
    sudo dpkg -i packages-microsoft-prod.deb
    # Delete the the Microsoft repository GPG keys file
    rm packages-microsoft-prod.deb
    # Update the list of packages after we added packages.microsoft.com
    sudo apt-get update
    # Install PowerShell
    sudo apt-get install -y powershell
}

# Function to install PowerShell on Debian
debian_install_pwsh() {
    # https://learn.microsoft.com/en-us/powershell/scripting/install/install-debian
    # Update the list of packages
    sudo apt-get update
    # Install pre-requisite packages.
    sudo apt-get install -y wget
    # Get the version of Debian
    # shellcheck disable=SC1091
    source /etc/os-release
    # Define supported Debian versions (add new ones here as needed)
    SUPPORTED_VERSIONS=("11" "12" "13")
    # Check if VERSION_ID is supported
    # shellcheck disable=SC2076
    if [[ ! " ${SUPPORTED_VERSIONS[*]} " =~ " $VERSION_ID " ]]; then
        echo "Unsupported Debian version: $VERSION_ID"
        exit 1
    fi
    # Download the Microsoft repository GPG keys
    wget -q "https://packages.microsoft.com/config/debian/$VERSION_ID/packages-microsoft-prod.deb"
    # Register the Microsoft repository GPG keys
    sudo dpkg -i packages-microsoft-prod.deb
    # Delete the Microsoft repository GPG keys file
    rm packages-microsoft-prod.deb
    # Update the list of packages after we added packages.microsoft.com
    sudo apt-get update
    # Install PowerShell
    sudo apt-get install -y powershell
}

# stop if not linux os type
if [[ "$(uname -s)" != "Linux" ]]; then
    echo "This script is intended for Linux systems only."
    exit 1
fi

# Check the distribution and call the appropriate function
if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    case "$ID" in
        ubuntu)
            ubuntu_install_pwsh
            ;;
        debian)
            debian_install_pwsh
            ;;
        *)
            echo "Unsupported Linux distribution: $ID"
            exit 1
            ;;
    esac
else
    echo "Cannot determine the Linux distribution."
    exit 1
fi
