#!/bin/bash

# Detect environment
INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2)
AWS_REGION=$(ec2-metadata --availability-zone | cut -d " " -f 2 | sed 's/[a-z]$//')
ENVIRONMENT_TAG=$(aws ec2 describe-tags \
  --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=environment" \
  --query 'Tags[0].Value' \
  --output text \
  --region $AWS_REGION)

echo "🚀 Starting application for environment: $ENVIRONMENT_TAG"

cd /home/ec2-user/backend

# Delete existing PM2 process (prevent duplicates)
pm2 delete restaurant-api-$ENVIRONMENT_TAG 2>/dev/null || true

# Start the application
pm2 start server.js --name restaurant-api-$ENVIRONMENT_TAG

# Save PM2 configuration
pm2 save

echo "✅ Application started: restaurant-api-$ENVIRONMENT_TAG"