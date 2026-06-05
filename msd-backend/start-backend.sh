#!/bin/bash

# MSD Backend Startup Script
# This script sets the correct environment variables and starts the backend

# Clear any existing DB_PORT variable
unset DB_PORT

# Set database port
export DB_PORT=5433

echo "================================================"
echo "Starting MSD Backend"
echo "================================================"
echo "Database Port: $DB_PORT"
echo "Server Port: 8080"
echo "================================================"
echo ""

# Start the application
cd "$(dirname "$0")"
./gradlew bootRun
