#!/bin/bash

# Payment Service Docker Runner Script
# This script runs the payment service container with the specified configuration

set -e  # Exit on any error

# Configuration
CONTAINER_NAME="payment-service"
IMAGE_NAME="ranckosolutionsinc/payments-service:v1.0"
PORT="3663:3663"
ENV_FILE="./.env"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Payment Service...${NC}"

# Check if .env file exists
if [[ ! -f "$ENV_FILE" ]]; then
    echo -e "${RED}Error: Environment file $ENV_FILE not found!${NC}"
    echo "Please create the .env file with required environment variables."
    exit 1
fi

# Check if container already exists and remove it
if docker ps -a --format 'table {{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}Container $CONTAINER_NAME already exists. Removing...${NC}"
    docker rm -f "$CONTAINER_NAME"
fi

# Run the container
echo -e "${GREEN}Running payment service container...${NC}"
docker run -dp "$PORT" \
    --name "$CONTAINER_NAME" \
    --env-file "$ENV_FILE" \
    "$IMAGE_NAME"

# Check if container started successfully
if docker ps --format 'table {{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${GREEN}✓ Payment service started successfully!${NC}"
    echo -e "${GREEN}✓ Container: $CONTAINER_NAME${NC}"
    echo -e "${GREEN}✓ Port: $PORT${NC}"
    echo -e "${GREEN}✓ Access URL: http://localhost:3663${NC}"
else
    echo -e "${RED}✗ Failed to start payment service container${NC}"
    echo "Check logs with: docker logs $CONTAINER_NAME"
    exit 1
fi