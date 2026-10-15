#!/bin/sh

set -e

DEFAULT_KEY_DIR="fit-keys"
DEFAULT_KEY_NAME="sulka-fit"
KEY_BITS=4096

show_help() {
    cat << EOF
Usage: $0 [KEY_DIR] [KEY_NAME]

Generate the RSA key pair that signs the FIT image for verified boot.

ARGUMENTS:
    KEY_DIR     Directory for the keys (default: ./$DEFAULT_KEY_DIR)
    KEY_NAME    Name of the key (default: $DEFAULT_KEY_NAME)

FILES CREATED:
    <KEY_DIR>/<KEY_NAME>.key    # Private key, keep it secret
    <KEY_DIR>/<KEY_NAME>.crt    # Certificate with the public key

Use the keys in the build with:
    UBOOT_SIGN_KEYDIR = "<absolute path of KEY_DIR>"
    UBOOT_SIGN_KEYNAME = "<KEY_NAME>"
EOF
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

KEY_DIR="${1:-$DEFAULT_KEY_DIR}"
KEY_NAME="${2:-$DEFAULT_KEY_NAME}"

echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo "                      IMPORTANT"
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo
echo The private key generated here is stored unencrypted.
echo Anyone with access to it can sign images that U-Boot
echo boots. It is fine for testing, but production keys
echo should be generated and kept in a protected location,
echo such as a hardware security module.
echo
echo Rebuilding with a new key also changes the public key
echo in U-Boot, so devices running an older U-Boot will not
echo boot images signed with it.
echo
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo

if [ -e "$KEY_DIR/$KEY_NAME.key" ] || [ -e "$KEY_DIR/$KEY_NAME.crt" ]; then
    echo "Error: $KEY_DIR/$KEY_NAME.key or $KEY_DIR/$KEY_NAME.crt already exists" >&2
    exit 1
fi

echo "Type Y to continue: "
read confirm

confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')

if [ "$confirm" != "y" ]; then
    echo "Aborted."
    exit 1
fi

mkdir -p "$KEY_DIR"
(umask 077 && openssl genrsa -F4 -out "$KEY_DIR/$KEY_NAME.key" $KEY_BITS)
openssl req -batch -new -x509 -key "$KEY_DIR/$KEY_NAME.key" -subj "/CN=$KEY_NAME" -out "$KEY_DIR/$KEY_NAME.crt"

echo
echo "FIT signing keys generated:"
echo "Private key: $KEY_DIR/$KEY_NAME.key"
echo "Certificate: $KEY_DIR/$KEY_NAME.crt"
