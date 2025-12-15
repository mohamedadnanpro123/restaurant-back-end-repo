#!/bin/bash
set -e

# Ensure backend directory is writable by ec2-user
sudo chown -R ec2-user:ec2-user /home/ec2-user/backend
chmod -R 755 /home/ec2-user/backend

cd /home/ec2-user/backend

# Remove old .env file if it exists (might be owned by root from UserData)
sudo rm -f /home/ec2-user/backend/.env

# Install dependencies
npm install

echo "🔍 Detecting environment..."

# Get instance ID
INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2)

# Get AWS region
AWS_REGION=$(ec2-metadata --availability-zone | cut -d " " -f 2 | sed 's/[a-z]$//')

# Get Environment tag from EC2 instance
ENVIRONMENT_TAG=$(aws ec2 describe-tags \
  --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=environment" \
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

# Retrieve environment variables from Parameter Store (using UNDERSCORES)
export DB_HOST=$(aws ssm get-parameter --name "${PARAM_PATH}/db_host" --with-decryption --query Parameter.Value --output text --region $AWS_REGION)
export DB_USER=$(aws ssm get-parameter --name "${PARAM_PATH}/db_user" --with-decryption --query Parameter.Value --output text --region $AWS_REGION)
export DB_PASSWORD=$(aws ssm get-parameter --name "${PARAM_PATH}/db_password" --with-decryption --query Parameter.Value --output text --region $AWS_REGION)
export DB_NAME=$(aws ssm get-parameter --name "${PARAM_PATH}/db_name" --with-decryption --query Parameter.Value --output text --region $AWS_REGION)
export DB_PORT=$(aws ssm get-parameter --name "${PARAM_PATH}/db_port" --with-decryption --query Parameter.Value --output text --region $AWS_REGION)
export APP_PORT=$(aws ssm get-parameter --name "${PARAM_PATH}/port" --with-decryption --query Parameter.Value --output text --region $AWS_REGION)
export NODE_ENV=$(aws ssm get-parameter --name "${PARAM_PATH}/node_env" --with-decryption --query Parameter.Value --output text --region $AWS_REGION)
export JWT_SECRET=$(aws ssm get-parameter --name "${PARAM_PATH}/jwt_secret" --with-decryption --query Parameter.Value --output text --region $AWS_REGION)
export S3_BUCKET=$(aws ssm get-parameter --name "${PARAM_PATH}/s3_bucket_name" --with-decryption --query Parameter.Value --output text --region $AWS_REGION)
export CDN_DOMAIN=$(aws ssm get-parameter --name "${PARAM_PATH}/cdn_domain" --with-decryption --query Parameter.Value --output text --region $AWS_REGION)
export GMAIL_EMAIL=$(aws ssm get-parameter --name "${PARAM_PATH}/gmail_email" --with-decryption --query Parameter.Value --output text --region $AWS_REGION)
export GMAIL_PASSWORD=$(aws ssm get-parameter --name "${PARAM_PATH}/gmail_password" --with-decryption --query Parameter.Value --output text --region $AWS_REGION)
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
GMAIL_EMAIL=$GMAIL_EMAIL
GMAIL_PASSWORD=$GMAIL_PASSWORD
EOF

# Ensure proper ownership and permissions
sudo chown -R ec2-user:ec2-user /home/ec2-user/backend
chmod 600 /home/ec2-user/backend/.env

# Start PM2 app

# Delete old process to prevent duplicates
pm2 delete restaurant-api-$ENVIRONMENT_TAG 2>/dev/null || true

# Start fresh
cd /home/ec2-user/backend
pm2 start server.js --name restaurant-api-$ENVIRONMENT_TAG
pm2 save

echo "✅ Environment configured for: $ENVIRONMENT_TAG"
echo "✅ .env file created successfully"
echo "✅ PM2 process started: restaurant-api-$ENVIRONMENT_TAG"