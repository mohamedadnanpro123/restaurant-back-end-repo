#!/bin/bash
set -e
# Ensure backend directory is writable by ec2-user
sudo chown -R ec2-user:ec2-user /home/ec2-user/backend
chmod -R 755 /home/ec2-user/backend



cd /home/ec2-user/backend

# Remove old .env file if it exists (might be owned by root from UserData)
sudo rm -f /home/ec2-user/backend/.env

# Install dependencies
su - ec2-user -c "cd /home/ec2-user/backend && npm install"


echo "🔍 Detecting environment..."

# Get instance ID
INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2)

# Get AWS region
AWS_REGION=$(ec2-metadata --availability-zone | cut -d " " -f 2 | sed 's/[a-z]$//')

# Get Environment tag from EC2 instance
ENVIRONMENT_TAG=$(aws ec2 describe-tags \
  --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=Environment" \
  --query 'Tags[0].Value' \
  --output text \
  --region $AWS_REGION)

echo "✅ Environment tag detected: $ENVIRONMENT_TAG"
echo "✅ Region: $AWS_REGION"

# Set parameter path based on environment tag
if [ "$ENVIRONMENT_TAG" == "dev" ]; then
    PARAM_PATH="/dev"
    echo "📦 Using DEV parameters"
elif [ "$ENVIRONMENT_TAG" == "prod" ]; then
    PARAM_PATH="/prod"
    echo "📦 Using PROD parameters"
else
    echo "❌ ERROR: Unknown environment tag: $ENVIRONMENT_TAG"
    exit 1
fi

# Retrieve environment variables from Parameter Store
export DB_HOST=$(aws ssm get-parameter --name "$PARAM_PATH/db/host" --with-decryption --query Parameter.Value --output text --region $AWS_REGION)
export DB_USER=$(aws ssm get-parameter --name "$PARAM_PATH/db/username" --with-decryption --query Parameter.Value --output text --region $AWS_REGION)
export DB_PASSWORD=$(aws ssm get-parameter --name "$PARAM_PATH/db/password" --with-decryption --query Parameter.Value --output text --region $AWS_REGION)
export DB_NAME=$(aws ssm get-parameter --name "$PARAM_PATH/db/name" --query Parameter.Value --output text --region $AWS_REGION)
export DB_PORT=$(aws ssm get-parameter --name "$PARAM_PATH/db/port" --query Parameter.Value --output text --region $AWS_REGION)
export APP_PORT=$(aws ssm get-parameter --name "$PARAM_PATH/app/port" --query Parameter.Value --output text --region $AWS_REGION)
export NODE_ENV=$(aws ssm get-parameter --name "$PARAM_PATH/node/env" --query Parameter.Value --output text --region $AWS_REGION)
export JWT_SECRET=$(aws ssm get-parameter --name "$PARAM_PATH/jwt/secret" --with-decryption --query Parameter.Value --output text --region $AWS_REGION)
export S3_BUCKET=$(aws ssm get-parameter --name "$PARAM_PATH/s3/bucket" --query Parameter.Value --output text --region $AWS_REGION)
export CDN_DOMAIN=$(aws ssm get-parameter --name "$PARAM_PATH/cdn/domain" --query Parameter.Value --output text --region $AWS_REGION)
export GMAIL_EMAIL=$(aws ssm get-parameter --name "$PARAM_PATH/gmail/email" --query Parameter.Value --output text --region $AWS_REGION)  # ← ADD
export GMAIL_PASSWORD=$(aws ssm get-parameter --name "$PARAM_PATH/gmail/password" --with-decryption --query Parameter.Value --output text --region $AWS_REGION)  # ← ADD



# Create .env file
cat > /home/ec2-user/backend/.env << EOF
DB_HOST=$DB_HOST
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_NAME=$DB_NAME
DB_PORT=$DB_PORT
PORT=$APP_PORT
NODE_ENV=$NODE_ENV
JWT_SECRET=$JWT_SECRET
S3_BUCKET_NAME=$S3_BUCKET
CDN_DOMAIN=$CDN_DOMAIN
AWS_REGION=$AWS_REGION
GMAIL_EMAIL=$GMAIL_EMAIL          # ← ADD THIS
GMAIL_PASSWORD=$GMAIL_PASSWORD    # ← ADD THIS
EOF
su - ec2-user -c "cd /home/ec2-user/backend && pm2 start server.js --name restaurant-api-dev"
su - ec2-user -c "pm2 save"

# Ensure proper ownership and permissions
chown -R ec2-user:ec2-user /home/ec2-user/backend
chmod 600 /home/ec2-user/backend/.env

echo "✅ Environment configured for: $ENVIRONMENT_TAG"
echo "✅ .env file created successfully"