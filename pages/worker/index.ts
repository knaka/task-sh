import {
  Hono,
} from "hono";

import { cors } from "hono/cors";

import { zValidator } from "@hono/zod-validator";
import { z } from "zod";

import { D1Database } from "@cloudflare/workers-types";

import { getUser } from "../sqlcgen/querier"

// import {
//   EventContext,
// } from "hono/cloudflare-pages"

type Bindings = {
  ASSETS: {
    fetch: typeof fetch;
  },
  DB: D1Database,
};

// app.use("*", (c, next) => {
//   c.res.headers.append("Access-Control-Allow-Origin", "*");
//   c.res.headers.append("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
//   return next();
// })

// CORS Middleware - Hono https://hono.dev/docs/middleware/builtin/cors
const api = new Hono<{ Bindings: Bindings }>()
  .get("/hello",
    zValidator(
      "param",
      z.object({}),
    ),
    async (c) => {
      // const stmt = c.env.DB.prepare("SELECT * FROM users WHERE id = ?");
      // const x = stmt.bind(2);
      // console.log("b82408d", await x.all());

      // const res = await getUser(c.env.DB, { nullableUsername: 'SMITH, John' })
      const res = await getUser(c.env.DB, { nullableId: 3 })
      console.log("034a7bc", res);

      let msg = "Hello Pages!! This is Hono!! 37ea5ee!"
      if (res) {
        msg = `${msg} User: ${res.id} ${res.username}`
      }
      return c.json({
        message: msg,
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

