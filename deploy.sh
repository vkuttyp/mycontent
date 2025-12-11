#!/bin/bash

# Deployment script for Nuxt application
# Deploys to aw.iserveus.com:/data/nuxt/

set -e

echo "🚀 Starting deployment to aw.iserveus.com..."

# Configuration
REMOTE_USER="root"
REMOTE_HOST="aw.iserveus.com"
REMOTE_PATH="/data/nuxt/"
LOCAL_PATH="."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}📦 Checking remote rsync availability...${NC}"

# Check if rsync exists on remote server
if ! ssh "${REMOTE_USER}@${REMOTE_HOST}" "command -v rsync &> /dev/null"; then
    echo -e "${YELLOW}⚠️  rsync not found on remote server. Installing...${NC}"
    ssh "${REMOTE_USER}@${REMOTE_HOST}" "apt-get update && apt-get install -y rsync || yum install -y rsync"
fi

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
echo "🔄 Restarting application..."
# If using Docker
if command -v docker &> /dev/null; then
    echo "🐳 Stopping existing container..."
    docker stop mycontent 2>/dev/null || true
    docker rm mycontent 2>/dev/null || true
    echo "🔨 Building Docker image..."
    docker build -t mycontent-app .
    if [ $? -eq 0 ]; then
        echo "🚀 Starting new container..."
        docker run -d -p 3000:3000 --name mycontent --restart unless-stopped mycontent-app
        echo "✅ Container started successfully"
    else
        echo "❌ Docker build failed"
        exit 1
    fi
# If using PM2
elif command -v pm2 &> /dev/null; then
    pm2 restart nuxt-app || pm2 start npm --name "nuxt-app" -- run preview
else
    echo "⚠️  No PM2 or Docker found. Application built but not restarted."
fi
ENDSSH

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "${GREEN}🌐 Your application should now be running on the server${NC}"
