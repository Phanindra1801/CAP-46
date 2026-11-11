
#!/bin/bash

# CAP-46 Environment Verification Script

echo "======================================"
echo " CAP-46 Environment Verification"
echo "======================================"

# Check Docker
if ! command -v docker &> /dev/null
then
    echo "ERROR: Docker is not installed."
    exit 1
fi

echo "Docker version:"
docker --version

# Check Docker Compose
if ! docker compose version &> /dev/null
then
    echo "ERROR: Docker Compose is unavailable."
    exit 1
fi

echo "Docker Compose version:"
docker compose version

# Check project configuration
if [ ! -f "docker-compose.yml" ] && [ ! -f "compose.yaml" ] && [ ! -f "compose.yml" ] && [ ! -f "docker-compose.yaml" ]
then
    echo "ERROR: Docker Compose configuration not found."
    exit 1
fi

echo "Docker Compose configuration found."

# Check Docker daemon
if ! docker info &> /dev/null
then
    echo "ERROR: Docker daemon is not running."
    exit 1
fi

echo "Docker daemon is running."

echo "======================================"
echo " Environment verification successful!"
echo "======================================"

exit 0
