import { Hono } from 'hono'
import { handle as pagesHandle } from 'hono/cloudflare-pages'
import { D1Database } from "@cloudflare/workers-types";
import * as sqlcgenQuerier from '@sqlcgen/querier'

type Bindings = {
  ASSETS: {
    fetch: typeof fetch;
  },
  DB: D1Database,
  AP_DEV_PORT?: string,
};

export const app = new Hono<{ Bindings: Bindings }>();

app
  .get('/var/timestamp',
    async (c) => {
      const resp = await sqlcgenQuerier.getUsersCount(c.env.DB);
      let count = -1;
      if (resp) {
        count = resp.foo;
      }
      return c.html(`<html><body><h1>Count: ${count}</h1></body></html>`);
    }
  )

export const onRequest = pagesHandle(app);
