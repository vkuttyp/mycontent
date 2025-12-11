export default defineEventHandler(async (event) => {
  // Get the webhook secret from environment variables
  const webhookSecret = process.env.WEBHOOK_SECRET || 'your-secret-key'
  
  // Get the secret from the request header
  const signature = getHeader(event, 'x-hub-signature-256')
  
  // Verify the request is from GitHub (optional but recommended)
  // For simplicity, we'll use a simple secret comparison
  const providedSecret = getHeader(event, 'x-webhook-secret')
  
  if (providedSecret !== webhookSecret) {
    throw createError({
      statusCode: 401,
      statusMessage: 'Unauthorized'
    })
  }

  // Execute the deployment script
  try {
    const { exec } = await import('child_process')
    const { promisify } = await import('util')
    const execAsync = promisify(exec)

    // Pull latest changes and restart
    await execAsync('cd /data/nuxt && git pull origin main && npm install && npm run build && pm2 restart nuxt-app')
    
    return {
      success: true,
      message: 'Deployment triggered successfully'
    }
  } catch (error: any) {
    console.error('Deployment error:', error)
    throw createError({
      statusCode: 500,
      statusMessage: 'Deployment failed',
      data: error.message
    })
  }
})
