#!/bin/bash

# Deployment script for Nuxt application using PM2
# Deploys to aw.iserveus.com:/data/nuxt/

set -e

echo "🚀 Starting PM2 deployment to aw.iserveus.com..."

# Configuration
REMOTE_USER="root"
REMOTE_HOST="aw.iserveus.com"
REMOTE_PATH="/data/nuxt/"
LOCAL_PATH="."
APP_NAME="nuxt-app"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}📦 Syncing files to remote server...${NC}"

# Rsync command with exclusions
rsync -avz --progress \
  --exclude 'node_modules' \
  --exclude '.nuxt' \
  --exclude '.output' \
  --exclude '.git' \
  --exclude '.DS_Store' \
  --exclude '*.log' \
  --exclude 'dist' \
  --exclude '.vscode' \
  --exclude '.idea' \
  --delete \
  "${LOCAL_PATH}/" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"

echo -e "${GREEN}✅ Files synced successfully!${NC}"

echo -e "${YELLOW}🔧 Installing dependencies and building on remote server...${NC}"

# SSH into server and run commands
ssh "${REMOTE_USER}@${REMOTE_HOST}" << 'ENDSSH'
cd /data/nuxt

echo "📦 Installing dependencies..."
npm install

echo "🏗️  Building application..."
npm run build

echo "🔄 Managing PM2 process..."

# Copy .env file to the output directory if it exists
if [ -f .env ]; then
    echo "📄 Copying .env file to output directory..."
    cp .env .output/server/.env
fi

# Check if app is already running in PM2
if pm2 describe nuxt-app > /dev/null 2>&1; then
    echo "♻️  Deleting and restarting PM2 process..."
    pm2 delete nuxt-app
fi

echo "🚀 Starting PM2 process with ecosystem file..."
pm2 start ecosystem.config.cjs
pm2 save

# Setup PM2 to start on system boot
pm2 startup systemd -u root --hp /root || true

echo "📊 PM2 Status:"
pm2 list
pm2 info nuxt-app

ENDSSH

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "${GREEN}🌐 Your application is now running with PM2${NC}"
echo -e "${YELLOW}📝 Useful commands:${NC}"
echo -e "  View logs:    ssh ${REMOTE_USER}@${REMOTE_HOST} 'pm2 logs nuxt-app'"
echo -e "  Check status: ssh ${REMOTE_USER}@${REMOTE_HOST} 'pm2 status'"
echo -e "  Restart:      ssh ${REMOTE_USER}@${REMOTE_HOST} 'pm2 restart nuxt-app'"
echo -e "  Stop:         ssh ${REMOTE_USER}@${REMOTE_HOST} 'pm2 stop nuxt-app'"
