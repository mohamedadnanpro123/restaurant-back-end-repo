#!/bin/bash
cd /home/ec2-user/backend


# Retrieve environment variables from Parameter Store
export DB_HOST=$(aws ssm get-parameter --name "/dev/db/host" --with-decryption --query Parameter.Value --output text --region us-east-1)
export DB_USER=$(aws ssm get-parameter --name "/dev/db/username" --with-decryption --query Parameter.Value --output text --region us-east-1)
export DB_PASSWORD=$(aws ssm get-parameter --name "/dev/db/password" --with-decryption --query Parameter.Value --output text --region us-east-1)
export DB_NAME=$(aws ssm get-parameter --name "/dev/db/name" --query Parameter.Value --output text --region us-east-1)
export DB_PORT=$(aws ssm get-parameter --name "/dev/db/port" --query Parameter.Value --output text --region us-east-1)
export APP_PORT=$(aws ssm get-parameter --name "/dev/app/port" --query Parameter.Value --output text --region us-east-1)
export NODE_ENV=$(aws ssm get-parameter --name "/dev/node/env" --query Parameter.Value --output text --region us-east-1)
export JWT_SECRET=$(aws ssm get-parameter --name "/dev/jwt/secret" --with-decryption --query Parameter.Value --output text --region us-east-1)
export S3_BUCKET=$(aws ssm get-parameter --name "/dev/s3/bucket" --query Parameter.Value --output text --region us-east-1)
export CDN_DOMAIN=$(aws ssm get-parameter --name "/dev/cdn/domain" --query Parameter.Value --output text --region us-east-1)
export AWS_REGION=$(aws ssm get-parameter --name "/dev/aws/region" --query Parameter.Value --output text --region us-east-1)

# Create .env file
cat > /home/ec2-user/backend/.env << 'EOF'
DB_HOST=${DB_HOST}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
DB_NAME=${DB_NAME}
DB_PORT=${DB_PORT}
PORT=${APP_PORT}
NODE_ENV=${NODE_ENV}
JWT_SECRET=${JWT_SECRET}
S3_BUCKET_NAME=${S3_BUCKET}
CDN_DOMAIN=${CDN_DOMAIN}
AWS_REGION=${AWS_REGION}
EOF

# Ensure proper ownership
chown -R ec2-user:ec2-user /home/ec2-user/backend