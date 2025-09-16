#!/bin/sh

set -e
SCRIPT_DIR=$(dirname "$(realpath "$0")")

echo --------------------------------------------------
echo                      IMPORTANT
echo --------------------------------------------------
echo
echo Ensure that the req_distinguished_name content is correct
echo both in meta-security/meta-integrity/scripts/ima-gen-local-ca.sh
echo and meta-security/meta-integrity/scripts/ima-gen-CA-signed.sh
echo
# Generate the certificate authority for IMA, EVM, and module signing.
# This certificate authority will be used to sign the IMA & EVM and modsign certificate signing requests.
# Also, the public key will be added to the kernel system trusted keys.
echo Generating certificate authority
echo
$SCRIPT_DIR/../meta-security/meta-integrity/scripts/ima-gen-local-ca.sh

# Generate the certificate signing request used for module signing and sign it with the CA
echo Generating module signing certificate
echo
$SCRIPT_DIR/../meta-security/meta-integrity/scripts/ima-gen-CA-signed.sh
# Rename the output files to signify they are used for module signing
mv csr_ima.pem csr_modsign.pem
mv ima.genkey modsign.genkey
mv privkey_ima.pem privkey_modsign.pem
mv x509_ima.der x509_modsign.der
# Convert DER certificate into PEM certificate to be compatible with kernel build
openssl x509 -inform DER -in x509_modsign.der -outform PEM -out x509_modsign.crt

# Generate the certificate signing request used for IMA & EVM signing and sign it with the CA
echo "Generating IMA & EVM certificate"
echo
$SCRIPT_DIR/../meta-security/meta-integrity/scripts/ima-gen-CA-signed.sh

