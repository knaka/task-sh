import { Hono } from 'hono'
import { handle as pagesHandle } from 'hono/cloudflare-pages'
import { z } from 'zod'
import { zValidator } from '@hono/zod-validator';
// import { D1Database } from "@cloudflare/workers-types";
import { cors } from 'hono/cors'

type Bindings = {
  ASSETS: {
    fetch: typeof fetch;
  },
  // DB: D1Database,
  AP_DEV_PORT?: string,
};

export const app = new Hono<{ Bindings: Bindings }>();
app.use('/api/*', cors())
const route = app.post('/api/greet',
    zValidator(
      "json",
      z.object({ name: z.string() }),
      (result, c) => {
        if (! result.success) {
          return c.text('Invalid!', 400)
        }
      },
    ),
    async (c) => {
      const body = c.req.valid("json");
      const name = body.name;
      return c.json({ message: `Hello, ${name}!` });
    }
  )
;

export const onRequest = pagesHandle(app);
export type AppType = typeof route;
