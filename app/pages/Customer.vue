<template>
  <div class="max-w-screen-sm mx-auto py-10">
    <h1 class="text-2xl font-bold mb-6">Customer Information</h1>
    <UForm class="bg-white p-10 rounded-md space-y-4" 
      :state="model" :schema="schema" @submit="submitForm">
      <UFormGroup label="Name" name="name">
        <UInput v-model="model.name" placeholder="Enter your name" />
      </UFormGroup>
      <UFormGroup label="Email" name="email">
        <UInput v-model="model.email" placeholder="Enter your email" />
      </UFormGroup>
      <UFormGroup label="Phone" name="phone">
        <UInput v-model="model.phone" placeholder="Enter your phone number" />
      </UFormGroup>
      <UFormGroup label="Age" name="age">
        <UInput v-model="model.age" type="number" placeholder="Enter your age" />
      </UFormGroup>
      <UButton type="submit" color="primary">Submit</UButton>
    </UForm>
  </div>
</template>

<script lang="ts" setup>
  import { z } from 'zod'
  import type { FormSubmitEvent } from "#ui/types"
  const schema = z.object({
    name: z.string().min(2).max(100),
    email: z.string().email(),
    phone: z.string().min(10).max(15),
    age: z.number().min(0).max(120).optional()
  })
const model=reactive({
  name: undefined,
  email: undefined,
  phone: undefined,
  age: undefined
})
type Schema= z.output<typeof schema>
function submitForm(event:FormSubmitEvent<Schema>){
  console.log(event)
}
</script>

<style>

</style>