#!/bin/bash

# MongoDB Docker Runner Script
# This script runs MongoDB container equivalent to the docker-compose configuration

set -e  # Exit on any error

# Configuration
CONTAINER_NAME="mongodb"
IMAGE_NAME="mongo:4.2"
PORT="27017:27017"
VOLUME_NAME="mongodb_data"
NETWORK_NAME="mongodb_network"
MONGO_USERNAME="mongo"
MONGO_PASSWORD="password"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up MongoDB service...${NC}"

# Create network if it doesn't exist
if ! docker network ls --format 'table {{.Name}}' | grep -q "^${NETWORK_NAME}$"; then
    echo -e "${BLUE}Creating network: $NETWORK_NAME${NC}"
    docker network create "$NETWORK_NAME"
else
    echo -e "${YELLOW}Network $NETWORK_NAME already exists${NC}"
fi

# Create volume if it doesn't exist
if ! docker volume ls --format 'table {{.Name}}' | grep -q "^${VOLUME_NAME}$"; then
    echo -e "${BLUE}Creating volume: $VOLUME_NAME${NC}"
    docker volume create "$VOLUME_NAME"
else
    echo -e "${YELLOW}Volume $VOLUME_NAME already exists${NC}"
fi

# Check if container already exists and remove it
if docker ps -a --format 'table {{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}Container $CONTAINER_NAME already exists. Removing...${NC}"
    docker rm -f "$CONTAINER_NAME"
fi

# Run the MongoDB container
echo -e "${GREEN}Running MongoDB container...${NC}"
docker run -d \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    -p "$PORT" \
    -e MONGO_INITDB_ROOT_USERNAME="$MONGO_USERNAME" \
    -e MONGO_INITDB_ROOT_PASSWORD="$MONGO_PASSWORD" \
    -v "${VOLUME_NAME}:/data/db" \
    --network "$NETWORK_NAME" \
    "$IMAGE_NAME"

# Wait a moment for container to start
sleep 3

# Check if container started successfully
if docker ps --format 'table {{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${GREEN}✓ MongoDB service started successfully!${NC}"
    echo -e "${GREEN}✓ Container: $CONTAINER_NAME${NC}"
    echo -e "${GREEN}✓ Port: $PORT${NC}"
    echo -e "${GREEN}✓ Network: $NETWORK_NAME${NC}"
    echo -e "${GREEN}✓ Volume: $VOLUME_NAME${NC}"
    echo -e "${GREEN}✓ Username: $MONGO_USERNAME${NC}"
    echo -e "${GREEN}✓ Password: $MONGO_PASSWORD${NC}"
    echo ""
    echo -e "${BLUE}Connection string: mongodb://$MONGO_USERNAME:$MONGO_PASSWORD@localhost:27017${NC}"
    echo -e "${BLUE}To connect with mongo shell: docker exec -it $CONTAINER_NAME mongo -u $MONGO_USERNAME -p $MONGO_PASSWORD --authenticationDatabase admin${NC}"
else
    echo -e "${RED}✗ Failed to start MongoDB container${NC}"
    echo "Check logs with: docker logs $CONTAINER_NAME"
    exit 1
fi

# Optional: Show container logs
echo ""
echo -e "${YELLOW}Recent logs:${NC}"
docker logs --tail 10 "$CONTAINER_NAME"