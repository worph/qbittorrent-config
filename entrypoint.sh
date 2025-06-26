#!/bin/sh

set -e

# Required environment variables
QB_USERNAME="${QB_USERNAME:-admin}"
QB_PASSWORD="${QB_PASSWORD:-adminadmin}"
OUTPUT_DIR="${OUTPUT_DIR:-/output}"

# Check if output directory is mounted
if [ ! -d "$OUTPUT_DIR" ]; then
    echo "ERROR: Output directory $OUTPUT_DIR not found!"
    echo "Usage: docker run -v /host/path:/output -e QB_PASSWORD=yourpass container"
    exit 1
fi

echo "Generating qBittorrent config..."
echo "Username: $QB_USERNAME"
echo "Password: [HIDDEN]"

# Generate PBKDF2 hash
HASH_OUTPUT=$(python3 -c "
import hashlib
import os
import base64

password = '''$QB_PASSWORD'''
salt = os.urandom(16)
iterations = 100000

dk = hashlib.pbkdf2_hmac('sha512', password.encode(), salt, iterations)
encoded_salt = base64.b64encode(salt).decode()
encoded_hash = base64.b64encode(dk).decode()

print(f'{encoded_salt}:{encoded_hash}')
")

# Create minimal config
cat > "$OUTPUT_DIR/qBittorrent.conf" << EOF
[Preferences]
WebUI\CSRFProtection=false
WebUI\\Password_PBKDF2=@ByteArray($HASH_OUTPUT)
WebUI\\Username=$QB_USERNAME
EOF

echo "Config generated at: $OUTPUT_DIR/qBittorrent.conf"
cat "$OUTPUT_DIR/qBittorrent.conf"