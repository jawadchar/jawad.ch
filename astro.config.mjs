import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';
import tailwindcss from '@tailwindcss/vite';
import { remarkObsidian } from './src/lib/remarkObsidian.mjs';

export default defineConfig({
  site: 'https://jawad.ch',
  integrations: [mdx()],
  vite: {
    plugins: [tailwindcss()],
  },
  markdown: {
    shikiConfig: {
      theme: 'one-dark-pro',
      wrap: true,
    },
    remarkPlugins: [remarkObsidian],
  },
});
