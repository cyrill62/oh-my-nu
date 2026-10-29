import react from '@vitejs/plugin-react'
import vike from 'vike/plugin'
import { defineConfig } from 'vite'

// GitHub Pages serves the site under /<repository>/: the workflow sets BASE_URL.
export default defineConfig({
  base: process.env.BASE_URL ?? '/',
  plugins: [vike(), react()],
})
