import { Hono } from 'hono'
import { handle } from 'hono/cloudflare-pages'
import { renderToString } from 'react-dom/server'
import RootLayout from '../../app/layout'
import { useState, useEffect } from 'react'
import { getUser } from "../../sqlcgen/querier"
import { D1Database } from "@cloudflare/workers-types";

// const app = new Hono()
export const app = new Hono<{ Bindings: Bindings }>();

interface SiteData {
  title: string
  children?: any
}

const Content = (props: { siteData: SiteData; name: string, userName: string }) => {
  // const [userName, setUserName] = useState("")
  // useEffect(() => {
  //   (async () => {
  //     const res = await getUser(props.db, { nullableId: 3 })
  //     if (res) {
  //       console.log("User found")
  //       const msg = `User: ${res.id} ${res.username}`
  //       setUserName(msg)
  //     } else {
  //       console.log("User not found")
  //     }
  //   })();
  // }, []);
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

app.get('/:name', async (c) => {
  const { name } = c.req.param()

  let userName = ""
  const res = await getUser(c.env.DB, { nullableId: 3 })
  if (res) {
    userName = `User: ${res.id} ${res.username}`
  }

  const props = {
    name: name,
    siteData: {
      title: 'JSX with html sample',
    },
    userName,
  }
  return c.html(renderToString(<Content {...props} />))
})

export const onRequest = handle(app);
