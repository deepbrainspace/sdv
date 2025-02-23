#!/bin/bash

# Check if git-crypt is installed
if ! command -v git-crypt &> /dev/null; then
    echo "Installing git-crypt..."
    apt-get update && apt-get install -y git-crypt
fi

# Check if GPG key exists
if [ ! -f "./keys/sdv-key.gpg" ]; then
    echo "No GPG key found in ./keys/sdv-key.gpg"
    echo "Would you like to: "
    echo "1. Generate a new GPG key"
    echo "2. Import an existing key"
    read -p "Choose option (1/2): " option

    mkdir -p keys

    case $option in
        1)
            # Generate new GPG key
            gpg --batch --gen-key <<EOF
%echo Generating a GPG key for SDV
Key-Type: RSA
Key-Length: 4096
Name-Real: SDV Key
Name-Email: sdv@local
Expire-Date: 0
%no-protection
%commit
%echo Done
EOF
            # Export the public key
            gpg --export --armor "SDV Key" > ./keys/sdv-key.gpg
            ;;
        2)
            # Import existing key
            read -p "Enter path to your GPG key: " key_path
            gpg --import "$key_path"
            cp "$key_path" ./keys/sdv-key.gpg
            ;;
    esac
fi

# Initialize git-crypt
if [ ! -d ".git-crypt" ]; then
    echo "Initializing git-crypt..."
    git-crypt init
    
    # Add the GPG key
    git-crypt add-gpg-user --trusted "$(gpg --list-keys --with-colons | grep '^pub' | cut -d: -f5)"
fi

echo "git-crypt setup complete!"
echo "Your sensitive files will now be automatically encrypted."
echo ""
echo "To unlock the repository on another machine:"
echo "1. Import the GPG key: gpg --import ./keys/sdv-key.gpg"
echo "2. Run: git-crypt unlock" 