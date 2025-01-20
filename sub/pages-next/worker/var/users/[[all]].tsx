import { Hono } from 'hono'
import { handle } from 'hono/cloudflare-pages'
import { renderToString } from 'react-dom/server'
import RootLayout from '@/app/layout'
import { getUser } from "@/sqlcgen/querier"
import { D1Database } from "@cloudflare/workers-types";

// const app = new Hono()
export const app = new Hono<{ Bindings: Bindings }>();

interface SiteData {
  title: string
  children?: any
}

const Content = (props: { siteData: SiteData; name: string, userName: string }) => {
  return <RootLayout {...props.siteData}>
    <>
      <h1>Hello 3fac81d {props.name} and {props.userName}</h1>
    </>
  </RootLayout>
};

type Bindings = {
  ASSETS: {
    fetch: typeof fetch;
  },
  DB: D1Database,
};

app.get('/users', async (c) => {

  let userName = ""
  const res = await getUser(c.env.DB, { nullableId: 3 })
  if (res) {
    userName = `User: ${res.id} ${res.username}`
  }

  const props = {
    name: "dummy",
    siteData: {
      title: 'JSX with html sample',
    },
    userName,
  }
  return c.html(renderToString(<Content {...props} />))
})

app.get('/users/:id', async (c) => {
  const {id} = c.req.param()
  let userName = ""
  const res = await getUser(c.env.DB, { nullableId: parseInt(id) })
  if (res) {
    userName = `User: ${res.id} ${res.username}`
  }

  const props = {
    name: "dummy",
    siteData: {
      title: 'JSX with html sample',
    },
    userName,
  }
  return c.html(renderToString(<Content {...props} />))
});

export const onRequest = handle(app);
