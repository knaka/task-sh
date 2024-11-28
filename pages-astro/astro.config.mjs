// @ts-check
import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig((process.env.NODE_ENV === "development")? {
  vite: {
    server: {
      proxy: {
        "/api": {
          target: "http://127.0.0.1:18080",
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
});
