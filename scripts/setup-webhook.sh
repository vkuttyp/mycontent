#!/bin/bash

# This script helps you set up a GitHub webhook for automatic deployments

echo "🔧 GitHub Webhook Setup Instructions"
echo "======================================"
echo ""
echo "1. Go to your GitHub repository: https://github.com/vkuttyp/mycontent"
echo "2. Click on 'Settings' > 'Webhooks' > 'Add webhook'"
echo ""
echo "3. Configure the webhook:"
echo "   - Payload URL: https://web.aw.iserveus.com/api/deploy"
echo "   - Content type: application/json"
echo "   - Secret: (generate a strong secret and add it to your .env)"
echo "   - Events: Choose 'Just the push event'"
echo "   - Active: ✓"
echo ""
echo "4. Add this to your .env file on the VPS:"
echo "   WEBHOOK_SECRET=your-generated-secret"
echo ""
echo "5. Redeploy your application with: ./deploy-pm2.sh"
echo ""
echo "Once configured, any push to the main branch will automatically deploy!"
