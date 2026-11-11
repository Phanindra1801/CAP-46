
#!/bin/bash

# CAP-46 Safe Nginx Configuration Promotion

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CANDIDATE="${1:-}"

CANDIDATE_PATH="$PROJECT_ROOT/nginx/candidates/$CANDIDATE"
ACTIVE_CONFIG="$PROJECT_ROOT/nginx/active/default.conf"
BACKUP_DIR="$PROJECT_ROOT/nginx/backups"

BASE_URL="http://localhost"

BACKUP_CREATED=false
PROMOTION_STARTED=false
PROMOTION_SUCCESSFUL=false
BACKUP_FILE=""

rollback() {
    EXIT_CODE=$?

    if [ "$PROMOTION_STARTED" = true ] &&
       [ "$PROMOTION_SUCCESSFUL" = false ] &&
       [ "$BACKUP_CREATED" = true ]; then

        echo ""
        echo "======================================"
        echo "DEPLOYMENT FAILED - STARTING ROLLBACK"
        echo "======================================"

        if cp "$BACKUP_FILE" "$ACTIVE_CONFIG" &&
           docker compose exec -T nginx nginx -t &&
           docker compose exec -T nginx nginx -s reload; then

            echo "ROLLBACK COMPLETED SUCCESSFULLY."
        else
            echo "CRITICAL: Automatic rollback encountered an error."
        fi
    fi

    exit "$EXIT_CODE"
}

trap rollback EXIT

echo "======================================"
echo " CAP-46 SAFE CONFIGURATION PROMOTION"
echo "======================================"

# Step 1: Check candidate
if [ -z "$CANDIDATE" ] || [ ! -f "$CANDIDATE_PATH" ]; then
    echo "ERROR: Valid candidate filename is required."
    exit 1
fi

# Step 2: Validate candidate
echo "[1/5] Validating candidate..."

"$PROJECT_ROOT/scripts/validate-nginx-candidate.sh" "$CANDIDATE"

# Step 3: Create backup
echo "[2/5] Creating active configuration backup..."

"$PROJECT_ROOT/scripts/backup-nginx-config.sh"

BACKUP_FILE="$(
    find "$BACKUP_DIR" -maxdepth 1 -type f -name 'default-*.conf' \
        -printf '%T@ %p\n' |
        sort -nr |
        head -n 1 |
        sed 's/^[^ ]* //'
)"

if [ -z "$BACKUP_FILE" ] || [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file not found."
    exit 1
fi

BACKUP_CREATED=true

# Step 4: Promote candidate
echo "[3/5] Promoting candidate..."

PROMOTION_STARTED=true

cp "$CANDIDATE_PATH" "$ACTIVE_CONFIG"

# Step 5: Test and reload
echo "[4/5] Testing active Nginx configuration..."

docker compose exec -T nginx nginx -t

echo "[5/5] Reloading Nginx..."

docker compose exec -T nginx nginx -s reload

# Step 6: Functional smoke tests
# Step 6: Functional smoke tests
echo "Running functional smoke tests..."

EXPECTED_MARKER="${CANDIDATE%.conf}"

# Test frontend availability
curl -fsS "$BASE_URL/" > /dev/null
echo "Frontend availability test passed."

# Verify active configuration marker
FRONTEND_HEADERS="$(curl -fsSI "$BASE_URL/")"

if ! grep -Eiq "^X-CAP46-Config:[[:space:]]*${EXPECTED_MARKER}[[:space:]]*$" <<< "$FRONTEND_HEADERS"; then
    echo "ERROR: Configuration marker verification failed."
    echo "Expected marker: $EXPECTED_MARKER"
    exit 1
fi

echo "Configuration marker verification passed."

# Test backend health
HEALTH_BODY="$(curl -fsS "$BASE_URL/api/health")"

if ! grep -Eq '"status"[[:space:]]*:[[:space:]]*"UP"' <<< "$HEALTH_BODY"; then
    echo "ERROR: Backend health test failed."
    exit 1
fi

echo "Backend health test passed."

# Test deployment events API
curl -fsS "$BASE_URL/api/deployment-events" > /dev/null

echo "Deployment events API test passed."

curl -fsS "$BASE_URL/api/health" |
    grep -q '"status":"UP"'

curl -fsS "$BASE_URL/api/deployment-events" > /dev/null

PROMOTION_SUCCESSFUL=true

echo "======================================"
echo " CONFIGURATION PROMOTION SUCCESSFUL"
echo "======================================"

echo "Active configuration:"
echo "$CANDIDATE"

