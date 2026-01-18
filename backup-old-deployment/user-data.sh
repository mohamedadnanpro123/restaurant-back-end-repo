#!/bin/bash
set -e
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=== Production Environment Setup Started ==="

# Update system
dnf update -y

# Install required packages
dnf install -y amazon-ssm-agent aws-cli git mariadb105 ruby wget

# Ensure SSM Agent is running
systemctl start amazon-ssm-agent
systemctl enable amazon-ssm-agent

# Install CodeDeploy Agent
cd /tmp
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
chmod +x ./install
./install auto
systemctl start codedeploy-agent
systemctl enable codedeploy-agent

# Install Node.js 20 LTS
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs

# Install PM2 globally
npm install -g pm2

# Retrieve GitHub token and production variables
TOKEN=$(aws ssm get-parameter --name "/dev/github/pat" --with-decryption --query Parameter.Value --output text --region us-east-1)
DB_HOST=$(aws ssm get-parameter --name "/prod/db_host" --with-decryption --query Parameter.Value --output text --region us-east-1)
DB_USER=$(aws ssm get-parameter --name "/prod/db_user" --with-decryption --query Parameter.Value --output text --region us-east-1)
DB_PASSWORD=$(aws ssm get-parameter --name "/prod/db_password" --with-decryption --query Parameter.Value --output text --region us-east-1)
DB_NAME=$(aws ssm get-parameter --name "/prod/db_name" --with-decryption --query Parameter.Value --output text --region us-east-1)
DB_PORT=$(aws ssm get-parameter --name "/prod/db_port" --with-decryption --query Parameter.Value --output text --region us-east-1)
APP_PORT=$(aws ssm get-parameter --name "/prod/port" --with-decryption --query Parameter.Value --output text --region us-east-1)
NODE_ENV=$(aws ssm get-parameter --name "/prod/node_env" --with-decryption --query Parameter.Value --output text --region us-east-1)
JWT_SECRET=$(aws ssm get-parameter --name "/prod/jwt_secret" --with-decryption --query Parameter.Value --output text --region us-east-1)
S3_BUCKET=$(aws ssm get-parameter --name "/prod/s3_bucket_name" --with-decryption --query Parameter.Value --output text --region us-east-1)
CDN_DOMAIN=$(aws ssm get-parameter --name "/prod/cdn_domain" --with-decryption --query Parameter.Value --output text --region us-east-1)
GMAIL_EMAIL=$(aws ssm get-parameter --name "/prod/gmail_email" --with-decryption --query Parameter.Value --output text --region us-east-1)
GMAIL_PASSWORD=$(aws ssm get-parameter --name "/prod/gmail_password" --with-decryption --query Parameter.Value --output text --region us-east-1)

# Wait for instance tags to be available (with retry logic)
echo "🔍 Waiting for environment tag..."
INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2)
AWS_REGION=$(ec2-metadata --availability-zone | cut -d " " -f 2 | sed 's/[a-z]$//')

ENVIRONMENT_TAG=""
for i in {1..30}; do
    ENVIRONMENT_TAG=$(aws ec2 describe-tags \
      --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=environment" \
      --query 'Tags[0].Value' \
      --output text \
      --region $AWS_REGION 2>/dev/null)
    
    if [ -n "$ENVIRONMENT_TAG" ] && [ "$ENVIRONMENT_TAG" != "None" ]; then
        echo "✅ Environment tag detected: $ENVIRONMENT_TAG"
        break
    fi
    
    echo "⏳ Waiting for environment tag... (attempt $i/30)"
    sleep 2
done

if [ -z "$ENVIRONMENT_TAG" ] || [ "$ENVIRONMENT_TAG" == "None" ]; then
    echo "❌ ERROR: Could not detect environment tag after 60 seconds"
    exit 1
fi

# Run all app setup as ec2-user
sudo -u ec2-user bash << EOFUSER
set -e
echo "=== Running as ec2-user ==="

# Remove old backend if exists
rm -rf /home/ec2-user/backend
mkdir -p /home/ec2-user/backend

# Clone repo
git clone --branch main https://$TOKEN@github.com/mohamedadnanpro123/restaurant-back-end-repo.git /home/ec2-user/backend
cd /home/ec2-user/backend
npm install

# Create .env file
cat > /home/ec2-user/backend/.env << ENVEOF
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
AWS_REGION=us-east-1
GMAIL_EMAIL=$GMAIL_EMAIL
GMAIL_PASSWORD=$GMAIL_PASSWORD
ENVEOF

chmod 600 /home/ec2-user/backend/.env

# Start the app with PM2
pm2 start /home/ec2-user/backend/server.js --name restaurant-api-$ENVIRONMENT_TAG
pm2 save
pm2 list

echo "✅ Application started successfully as ec2-user"
EOFUSER

# Configure PM2 auto-start (requires sudo, so outside su block)
echo "=== Configuring PM2 auto-start ==="
PM2_STARTUP_CMD=$(sudo -u ec2-user pm2 startup systemd -u ec2-user --hp /home/ec2-user | grep "sudo env")
if [ -n "$PM2_STARTUP_CMD" ]; then
    eval $PM2_STARTUP_CMD
    sudo -u ec2-user pm2 save
    echo "✅ PM2 startup configured successfully"
else
    echo "❌ Failed to extract PM2 startup command"
fi

echo "✅ Production environment setup completed successfully"