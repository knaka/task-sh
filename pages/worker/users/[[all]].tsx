import { Hono } from 'hono'
import { handle } from 'hono/cloudflare-pages'
import { renderToString } from 'react-dom/server'
import RootLayout from '../../app/layout'

const app = new Hono()

interface SiteData {
  title: string
  children?: any
}

const Content = (props: { siteData: SiteData; name: string }) => {
  return <RootLayout {...props.siteData}>
    <>
      <h1>Hello 3fac81d {props.name} {}</h1>
    </>
  </RootLayout>
};

app.get('/:name', (c) => {
  const { name } = c.req.param()
  const props = {
    name: name,
    siteData: {
      title: 'JSX with html sample',
    },
  }
  return c.html(renderToString(<Content {...props} />))
})

export const onRequest = handle(app);
