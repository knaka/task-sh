import { Hono } from 'hono'
import { handle as pagesHandle } from 'hono/cloudflare-pages'
import { z } from 'zod'
import { zValidator } from '@hono/zod-validator';
import { D1Database } from "@cloudflare/workers-types";
import { cors } from 'hono/cors'
// import { getTheUser, GetTheUserArgs } from '@sqlcgen/query_sql'

type Bindings = {
  ASSETS: {
    fetch: typeof fetch;
  },
  DB: D1Database,
  AP_DEV_PORT?: string,
};

export const app = new Hono<{ Bindings: Bindings }>();
app.use('/api/*', cors())
const route = app
  .post('/api/greet',
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
  .post('/api/echo',
    zValidator(
      "json",
      z.object({ message: z.string() }),
      (result, c) => {
        if (! result.success) {
          return c.text('Invalid!', 400)
        }
      },
    ),
    async (c) => {
      const body = c.req.valid("json");
      const message = body.message;
      return c.json({message: message});
    }
  )
  .post('/api/echo_back_stream',
    async (c) => {
      const { body } = c.req.raw;
      if (! body) {
        return c.text('Request body is empty', 400);
      }
      const transformStream = new TransformStream({
        transform(chunk, controller) {
          const decoded = new TextDecoder().decode(chunk);
          const transformed = new TextEncoder().encode(decoded.toUpperCase());
          controller.enqueue(transformed);
        },
      });
      body.pipeTo(transformStream.writable);
      return new Response(transformStream.readable, {
        headers: { 'Content-Type': 'application/octet-stream' },
      });    
    }
  )
;

export const onRequest = pagesHandle(app);
export type AppType = typeof route;
