// @ts-check
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';

// https://astro.build/config
export default defineConfig({
  ...{
    integrations: [react()],
  },
  ...(process.env.NODE_ENV === "development")? {
    vite: {
      server: {
        proxy: {
          "/api": {
            target: `http://127.0.0.1:${process.env.API_DEV_PORT || 18080}`,
            changeOrigin: true,
            rewrite: (path) => path.replace(/^\/api/, "/api"),
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
