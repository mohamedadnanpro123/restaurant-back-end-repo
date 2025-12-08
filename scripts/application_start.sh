#!/bin/bash
cd /home/ec2-user/backend
# Delete existing PM2 process
pm2 delete restaurant-api-development || true
# Start the application
pm2 start server.js --name restaurant-api-development
# Save PM2 configuration
pm2 save