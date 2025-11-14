#!/bin/bash
# Wait for application to start
sleep 5

# Check if PM2 process is running
pm2 list | grep restaurant-api-dev | grep online

if [ $? -eq 0 ]; then
    echo "Application is running successfully"
    exit 0
else
    echo "Application failed to start"
    exit 1
fi