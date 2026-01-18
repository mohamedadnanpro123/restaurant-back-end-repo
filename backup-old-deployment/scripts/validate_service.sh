#!/bin/bash

# Detect environment
INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2)
AWS_REGION=$(ec2-metadata --availability-zone | cut -d " " -f 2 | sed 's/[a-z]$//')
ENVIRONMENT_TAG=$(aws ec2 describe-tags \
  --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=environment" \
  --query 'Tags[0].Value' \
  --output text \
  --region $AWS_REGION)

echo "🔍 Validating service for environment: $ENVIRONMENT_TAG"

# Check if PM2 process is running
if pm2 list | grep -q "restaurant-api-$ENVIRONMENT_TAG"; then
    echo "✅ PM2 process is running"
else
    echo "❌ PM2 process not found"
    exit 1
fi

# Wait for app to be ready
sleep 5

# Get port from environment
if [ "$ENVIRONMENT_TAG" == "dev" ]; then
    PORT=3000
elif [ "$ENVIRONMENT_TAG" == "prod" ]; then
    PORT=5000
else
    PORT=3000
fi

# Test health endpoint
if curl -f http://localhost:$PORT/api/health; then
    echo "✅ Health check passed"
    exit 0
else
    echo "❌ Health check failed"
    exit 1
fi