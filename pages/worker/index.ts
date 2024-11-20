import { cors } from "hono/cors";
import { Hono } from 'hono'
import { handle } from 'hono/cloudflare-pages'
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";
import { D1Database } from "@cloudflare/workers-types";
import { getUser } from "../sqlcgen/querier"

type Bindings = {
  ASSETS: {
    fetch: typeof fetch;
  },
  DB: D1Database,
};

// CORS Middleware - Hono https://hono.dev/docs/middleware/builtin/cors
const app = new Hono<{ Bindings: Bindings }>();
app.use("/api/*", cors());
const route = app
  .get("/api/hello",
    zValidator(
      "param",
      z.object({}),
    ),
    async (c) => {
      console.log("ec5d839");
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
  .get("/api/world",
    (c) => {
      return c.json({
        message: "World!!",
      })
    },
  )
;

export const onRequest = handle(app);
export type AppType = typeof route;
