import type { Config } from 'vike/types'
import vikeReact from 'vike-react/config'

export default {
  extends: [vikeReact],
  // Static HTML for GitHub Pages: every page is rendered at build time.
  prerender: true,
  // Config files run in Node, before Vite: read the base the way vite.config.ts does.
  favicon: `${process.env.BASE_URL ?? '/'}logo.svg`,
} satisfies Config
