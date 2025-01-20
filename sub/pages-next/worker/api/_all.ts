// Use this filename because `[[all]].ts` cannot be imported as a module. Next.js fails, I do not why.

import { cors } from "hono/cors";
import { Hono } from 'hono'
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";
import { D1Database } from "@cloudflare/workers-types";
import { getUser } from "@/sqlcgen/querier"

type Bindings = {
  ASSETS: {
    fetch: typeof fetch;
  },
  DB: D1Database,
};

// CORS Middleware - Hono https://hono.dev/docs/middleware/builtin/cors
export const app = new Hono<{ Bindings: Bindings }>();
app.use("/api/*", cors());
export const route = app
  .get("/api/hello",
    zValidator(
      "param",
      z.object({}),
    ),
    async (c) => {
      // console.log("ec5d839");
      // const stmt = c.env.DB.prepare("SELECT * FROM users WHERE id = ?");
      // const x = stmt.bind(2);
      // console.log("b82408d", await x.all());

      // const res = await getUser(c.env.DB, { nullableUsername: 'SMITH, John' })
      const res = await getUser(c.env.DB, { nullableId: 3 })
      // console.log("034a7bc", res);

      let msg = "Hello Pages!! This is Hono!! 799996c!"
      if (res) {
        msg = `${msg} User: ${res.id} ${res.username}`
      }
      return c.json({
        message: msg,
      })
    }
  )
  .get("/api/world",
    (c) => {
      return c.json({
        message: "World!!",
      })
    },
  )
;

export type AppType = typeof route;
