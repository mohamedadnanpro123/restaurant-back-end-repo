#!/bin/bash
# Stop the current application
su - ec2-user -c "pm2 stop restaurant-api-dev || true"

# Backup current deployment (optional)
if [ -d "/home/ec2-user/backend" ]; then
    mv /home/ec2-user/backend /home/ec2-user/backend-backup-$(date +%Y%m%d-%H%M%S) || true
fi