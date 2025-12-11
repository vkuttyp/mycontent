const fs = require('fs');
const path = require('path');

// Simple .env parser
const envPath = path.resolve(__dirname, '.env');
const envVars = {};

if (fs.existsSync(envPath)) {
  const envContent = fs.readFileSync(envPath, 'utf-8');
  envContent.split('\n').forEach(line => {
    line = line.trim();
    if (line && !line.startsWith('#')) {
      const [key, ...values] = line.split('=');
      if (key) {
        envVars[key.trim()] = values.join('=').trim();
      }
    }
  });
}

module.exports = {
  apps: [{
    name: 'nuxt-app',
    script: '.output/server/index.mjs',
    cwd: '/data/nuxt',
    env: {
      ...envVars,
      NODE_ENV: 'production',
      PORT: 3000
    },
    instances: 1,
    exec_mode: 'fork',
    autorestart: true,
    watch: false,
    max_memory_restart: '1G'
  }]
}
