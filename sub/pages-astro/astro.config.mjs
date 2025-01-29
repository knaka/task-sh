// @ts-check
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';

// https://astro.build/config
export default defineConfig({
  ...{
    srcDir: "./src-astro",
    outDir: "./dist",
    integrations: [react()],
  },
  ...(process.env.NODE_ENV === "development")? {
    vite: {
      server: {
        proxy: {
          "/api": {
            target: `http://127.0.0.1:${process.env.ASTRO_API_PORT || 18080}`,
            changeOrigin: true,
            rewrite: (path) => path.replace(/^\/api/, "/api"),
          },
          "/var": {
            target: `http://127.0.0.1:${process.env.ASTRO_API_PORT || 18080}`,
            changeOrigin: true,
            rewrite: (path) => path.replace(/^\/var/, "/var"),
          },
        }
      }
    }
  }: {
    experimental:{
      contentCollectionCache: true,
    },
  },
});
