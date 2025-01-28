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
  .get('/var/hello',
    async (c) => {
      const resp = await sqlcgenQuerier.getUsersCount(c.env.DB);
      let count = -1;
      if (resp) {
        count = resp.foo;
      }
      return c.html(`<html><body><h1>Count: ${count}</h1></body></html>`);
    }
  )
  .get('/var/foo/bar',
    async (c) => {
      return c.html(`<html><body><h1>FooBar</h1></body></html>`);
    }
  )
;

app
  .get('/var/users',
    async (c) => {
      return c.html(`<html><body><h1>Users</h1></body></html>`);
    }
  )
  .get('/var/users/:id',
    async (c) => {
      return c.html(`<html><body><h1>User 4fd0742 ${c.req.param("id")}</h1></body></html>`);
    }
  )

export const onRequest = pagesHandle(app);
