#!/bin/bash

DEFAULT_USERNAME="serviceuser"
DEFAULT_AUTH_KEYS_DIR="auth-keys"

show_help() {
    cat << EOF
Usage: $0 [OPTIONS] [USERNAME] [AUTH_KEYS_DIR]

Generate an ED25519 SSH key pair and organize the files.

ARGUMENTS:
    USERNAME        Username for the public key file (default: $DEFAULT_USERNAME)
    AUTH_KEYS_DIR   Directory path for auth keys (default: ./$DEFAULT_AUTH_KEYS_DIR)

OPTIONS:
    -h, --help      Show this help message and exit

EXAMPLES:
    $0                              # Use defaults: serviceuser, ./auth-keys
    $0 myuser /path/to/keys         # Use 'myuser' and '/path/to/keys'
    $0 --help                       # Show this help

FILES CREATED:
    <AUTH_KEYS_DIR>/<USERNAME>-auth-key.pub    # Public key
    <AUTH_KEYS_DIR>/ssh_auth_ed25519_key       # Private key
EOF
}

# Check for help option
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Parse arguments
USERNAME="${1:-$DEFAULT_USERNAME}"
AUTH_KEYS_DIR="${2:-$DEFAULT_AUTH_KEYS_DIR}"

# Validate inputs
if [[ -z "$USERNAME" ]]; then
    echo "Error: Username cannot be empty" >&2
    exit 1
fi

# Generate SSH key
echo "Generating ED25519 SSH key pair..."
ssh-keygen -t ed25519 -f ssh_auth_ed25519_key

# Check if key generation was successful
if [[ $? -ne 0 ]]; then
    echo "Error: SSH key generation failed" >&2
    exit 1
fi

# Create auth-keys directory
echo "Creating directory: $AUTH_KEYS_DIR"
mkdir -p "$AUTH_KEYS_DIR"

# Move private key
echo "Moving private key to $AUTH_KEYS_DIR/"
mv ssh_auth_ed25519_key "$AUTH_KEYS_DIR/"

# Move and rename public key
echo "Moving public key to $AUTH_KEYS_DIR/${USERNAME}-auth-key.pub"
mv ssh_auth_ed25519_key.pub "$AUTH_KEYS_DIR/${USERNAME}-auth-key.pub"

echo "SSH key generation complete!"
echo "Private key: $AUTH_KEYS_DIR/ssh_auth_ed25519_key"
echo "Public key: $AUTH_KEYS_DIR/${USERNAME}-auth-key.pub"
