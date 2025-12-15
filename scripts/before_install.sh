#!/bin/bash

# Detect environment
INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2)
AWS_REGION=$(ec2-metadata --availability-zone | cut -d " " -f 2 | sed 's/[a-z]$//')
ENVIRONMENT_TAG=$(aws ec2 describe-tags \
  --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=environment" \
  --query 'Tags[0].Value' \
  --output text \
  --region $AWS_REGION)

echo "🔍 Detected environment: $ENVIRONMENT_TAG"

# Stop the current application
su - ec2-user -c "pm2 stop restaurant-api-$ENVIRONMENT_TAG || true"