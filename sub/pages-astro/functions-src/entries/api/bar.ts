import { Hono } from 'hono'
import { handle as pagesHandle } from 'hono/cloudflare-pages'
import { D1Database } from "@cloudflare/workers-types";

type Bindings = {
  ASSETS: {
    fetch: typeof fetch;
  },
  DB: D1Database,
  AP_DEV_PORT?: string,
};

const app = new Hono<{ Bindings: Bindings }>();

app.get('/api/bar', async (c) => {
  return c.html('<html><body><h1>Bar</h1></body></html>');
});

export const onRequest = pagesHandle(app);
