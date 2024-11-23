import { Hono } from 'hono'
import { handle } from 'hono/cloudflare-pages'
import { D1Database } from "@cloudflare/workers-types";

type Bindings = {
  ASSETS: {
    fetch: typeof fetch;
  },
  DB: D1Database,
  NEXT_DEV_PORT: string | undefined,
};

const app = new Hono<{ Bindings: Bindings }>();

import type { Users } from "@/sqlcgen/models";
import { getUser } from "@/sqlcgen/querier";

app.get('/users/:id', async (c) => {
  const assetUrl = URL.parse(c.req.url)
  if (! assetUrl) {
    return c.html("No URL")
  }
  assetUrl.pathname = "/tmpl/user"
  console.log("bafab2a", assetUrl)
  const id = parseInt(c.req.param("id") || "0");
  console.log("227991e", id)
  const res = await getUser(c.env.DB, { nullableId: id })
  let serverData: Users;
  if (res) {
    serverData = res;
  } else {
    serverData = {
      id: 0,
      username: "No SSR Name",
      updatedAt: "",
      createdAt: "",
    }
  }
  const dataScript = `<script>window.__SERVER_DATA__ = ${JSON.stringify(serverData)}</script>`;
  const resp = await c.env.ASSETS.fetch(new Request(assetUrl));
  const body = await resp.text()
  // console.log("8c9a398", body);
  return c.html(body.replace('</head>', `${dataScript}</head>`));
});

export const onRequest = handle(app);
