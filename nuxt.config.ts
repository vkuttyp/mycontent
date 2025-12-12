// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  modules: ['@nuxt/content', 'nuxt-studio'],
  app: {
    head: {
     htmlAttrs:{
      style: 'filter: invert(1);'
     }
    }
  },
  
  studio: {
    // Git repository configuration (owner and repo are required)
    repository: {
      provider: 'github', // 'github' or 'gitlab'
      owner: 'vkuttyp', // your GitHub/GitLab username or organization
      repo: 'mycontent', // your repository name
      branch: 'main', // the branch to commit to (default: 'main')
    }
  },
  devtools: { enabled: true },
  future: {
    compatibilityVersion: 4,
  },
  compatibilityDate: '2024-04-03',
})