
#!/bin/bash

# CAP-46 Deployment Script

set -e

echo "======================================"
echo "       CAP-46 DEPLOYMENT"
echo "======================================"

# Step 1: Verify project directory
if [ ! -f "docker-compose.yml" ] && [ ! -f "compose.yaml" ] && [ ! -f "compose.yml" ] && [ ! -f "docker-compose.yaml" ]; then
    echo "ERROR: Docker Compose file not found."
    exit 1
fi

echo "[1/4] Project configuration found."

# Step 2: Validate Docker Compose
echo "[2/4] Validating Docker Compose configuration..."

docker compose config -q

echo "Docker Compose configuration is valid."

# Step 3: Build application images
echo "[3/4] Building application images..."

docker compose build

echo "Docker images built successfully."

# Step 4: Deploy application
echo "[4/4] Starting CAP-46 services..."

docker compose up -d

echo "======================================"
echo "       DEPLOYMENT COMPLETED"
echo "======================================"

docker compose ps
