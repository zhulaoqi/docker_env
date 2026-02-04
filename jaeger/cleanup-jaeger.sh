#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Cleaning Jaeger containers and volumes..."
docker-compose down -v

echo "Done! To remove the image, run:"
echo "  docker image rm jaegertracing/all-in-one:1.53"
