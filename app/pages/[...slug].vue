<script setup lang="ts">
const route = useRoute()

const { data: page } = await useAsyncData(()=> queryCollection('content').path(route.path).first())
if (!page.value) {
  throw createError({ statusCode: 404, statusMessage: 'Page not found', fatal: true })
}

useSeoMeta({
  title: page.value?.title || 'Page Not Found',
  description: page.value?.description || 'The requested page could not be found.',
})

</script>

<template>
  <ContentRenderer
    v-if="page" :value="page" />
    <div v-else>Page not found</div>
  
</template>
