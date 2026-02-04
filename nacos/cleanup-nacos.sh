#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Cleaning Nacos containers and volumes..."
docker-compose down -v

echo "Removing local data/logs..."
rm -rf ./data ./logs
