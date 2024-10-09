import {
  Hono,
} from "hono";

import { cors } from "hono/cors";

import { zValidator } from "@hono/zod-validator";
import { z } from "zod";

// import {
//   EventContext,
// } from "hono/cloudflare-pages"

type Bindings = {
  ASSETS: {
    fetch: typeof fetch;
  },
};

// app.use("*", (c, next) => {
//   c.res.headers.append("Access-Control-Allow-Origin", "*");
//   c.res.headers.append("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
//   return next();
// })

// CORS Middleware - Hono https://hono.dev/docs/middleware/builtin/cors
const api = new Hono()
  .get("/hello",
    zValidator(
      "param",
      z.object({}),
    ),
    (c) => {
      return c.json({
        message: "Hello Pages!! This is Hono!! 321fab3!",
      })
    }
  )
  .get("/world",
    (c) => {
      return c.json({
        message: "World!!",
      })
    },
  )
;

const root = new Hono<{ Bindings: Bindings }>()
  .use("*", cors())
  .route("/api", api)
  .get("*", async (c) => {
    const res = await c.env.ASSETS.fetch(c.req.raw);
    return res;
  })
;

export default root;
// export type AppType = typeof routes;
export type AppType2 = typeof root;

