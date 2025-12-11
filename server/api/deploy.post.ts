export default defineEventHandler(async (event) => {
  // Get the webhook secret from environment variables
  const webhookSecret = process.env.WEBHOOK_SECRET
  
  if (!webhookSecret) {
    console.error('WEBHOOK_SECRET not configured')
    throw createError({
      statusCode: 500,
      statusMessage: 'Webhook not configured'
    })
  }

  // Get the signature from GitHub
  const signature = getHeader(event, 'x-hub-signature-256')
  
  if (!signature) {
    throw createError({
      statusCode: 401,
      statusMessage: 'No signature provided'
    })
  }

  // Read the raw body
  const body = await readRawBody(event)
  
  if (!body) {
    throw createError({
      statusCode: 400,
      statusMessage: 'No body provided'
    })
  }

  // Verify the signature using crypto
  const crypto = await import('crypto')
  const hmac = crypto.createHmac('sha256', webhookSecret)
  const digest = 'sha256=' + hmac.update(body).digest('hex')
  
  // Compare signatures
  if (signature !== digest) {
    console.error('Invalid signature')
    throw createError({
      statusCode: 401,
      statusMessage: 'Invalid signature'
    })
  }

  // Execute the deployment script
  try {
    const { exec } = await import('child_process')
    const { promisify } = await import('util')
    const execAsync = promisify(exec)

    console.log('Starting deployment...')
    
    // Pull latest changes and restart
    const { stdout, stderr } = await execAsync('cd /data/nuxt && git pull origin main && npm install && npm run build && pm2 restart nuxt-app')
    
    console.log('Deployment stdout:', stdout)
    if (stderr) console.error('Deployment stderr:', stderr)
    
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
