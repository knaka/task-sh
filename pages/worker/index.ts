import {
  Hono,
} from "hono";

// import {
//   EventContext,
// } from "hono/cloudflare-pages"

type Bindings = {
  ASSETS: {
    fetch: typeof fetch;
  },
};

const app = new Hono<{ Bindings: Bindings }>();

app.use("*", (c, next) => {
  c.res.headers.append("Access-Control-Allow-Origin", "*");
  c.res.headers.append("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
  return next();
})

app.get("/api/hello", (c) => {
  return c.json({
    message: "Hello Pages!! This is Hono!! 7b57ee2!",
  });
});

app.get("*", async (c) => {
  const res = await c.env.ASSETS.fetch(c.req.raw);
  return res;
});

export default app;
