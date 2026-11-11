
#!/bin/bash

# CAP-46 Nginx Candidate Validation

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CANDIDATE="${1:-}"

CANDIDATE_DIR="$PROJECT_ROOT/nginx/candidates"
VALIDATION_DIR="$PROJECT_ROOT/nginx/validation"

CANDIDATE_PATH="$CANDIDATE_DIR/$CANDIDATE"
TEMP_CONFIG="$CANDIDATE_DIR/candidate-under-test.conf"

echo "======================================"
echo " CAP-46 NGINX VALIDATION"
echo "======================================"

# Check candidate argument
if [ -z "$CANDIDATE" ]; then
    echo "ERROR: Candidate filename is required."
    echo "Usage: ./scripts/validate-nginx-candidate.sh candidate-v1.conf"
    exit 1
fi

# Check candidate file
if [ ! -f "$CANDIDATE_PATH" ]; then
    echo "ERROR: Candidate configuration not found."
    exit 1
fi

# Check Nginx container
if ! docker compose ps --status running --services | grep -qx nginx; then
    echo "ERROR: Nginx service is not running."
    exit 1
fi

# Copy candidate for isolated validation
cp "$CANDIDATE_PATH" "$TEMP_CONFIG"

cleanup() {
    rm -f "$TEMP_CONFIG"
}

trap cleanup EXIT

echo "Candidate copied successfully."

# Validate configuration
echo "Running Nginx syntax validation..."

docker compose exec -T nginx \
    nginx -t -c /etc/nginx/validation/nginx.conf

echo "======================================"
echo "VALIDATION SUCCESSFUL"
echo "Candidate is safe from syntax errors."
echo "======================================"
