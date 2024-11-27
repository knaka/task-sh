import { Hono, Context } from 'hono'
import { handle as pagesHandle } from 'hono/cloudflare-pages'
import { D1Database } from "@cloudflare/workers-types";
// import { constants as httpConst } from 'http2'
import { getUser } from "@/sqlcgen/querier";
// import { StatusCode } from 'hono/utils/http-status';
import { UserPageInfo } from "@/app/tmpl/user/page";

type Bindings = {
  ASSETS: {
    fetch: typeof fetch;
  },
  DB: D1Database,
  AP_DEV_PORT?: string,
};

const app = new Hono<{ Bindings: Bindings }>();

const getAssetBody = async (c: Context<{Bindings: Bindings}>, path: string) => {
  if (c.env.AP_DEV_PORT) {
    const assetUrl = new URL(`http://127.0.0.1:${c.env.AP_DEV_PORT}${path}`);
    const resp = await fetch(assetUrl);
    return await resp.text();
  }
  const assetUrl = URL.parse(c.req.url)
  if (! assetUrl) {
    throw new Error("Failed to parse URL")
  }
  assetUrl.pathname = path
  const resp = await c.env.ASSETS.fetch(assetUrl)
  return await resp.text()
}

app.get('/var/users/:id', async (c) => {
  const id = parseInt(c.req.param("id") || "-1");
  const respUser = await getUser(c.env.DB, { nullableId: id });
  if (! respUser) {
    return c.html("No User Found", 404);
  }
  const assetBody = await getAssetBody(c, "/tmpl/user");
  const serverData: UserPageInfo = {
    user: respUser,
    message: "0861a84",
  };
  const serverDataScript = `<script>window.__SERVER_DATA__ = ${JSON.stringify(serverData)}</script>`;
  return c.html(assetBody.replace('</head>', `${serverDataScript}</head>`));
});

export const onRequest = pagesHandle(app);
