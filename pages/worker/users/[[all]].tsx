// import { html } from 'hono/html'

// const RootLayout = (props: SiteData) =>
//   html`<!doctype html>
//     <html>
//       <head>
//         <title>${props.title}</title>
//       </head>
//       <body>
//         ${props.children}
//       </body>
//     </html>`


import { Hono } from 'hono'
import { reactRenderer } from '@hono/react-renderer'
import { handle } from 'hono/cloudflare-pages'
import RootLayout from '../../app/layout'

const app = new Hono()

interface SiteData {
  title: string
  children?: any
}

const Content = (props: { siteData: SiteData; name: string }) => (
  <RootLayout {...props.siteData}>
    <>
      <h1>Hello 3fac81d {props.name}</h1>
    </>
  </RootLayout>
)

// app.get('/:name', (c) => {
//   const { name } = c.req.param()
//   const props = {
//     name: name,
//     siteData: {
//       title: 'JSX with html sample',
//     },
//   }
//   return c.html(<Content {...props} />)
// })

app.get('*', reactRenderer(({children}) => <RootLayout>{children}</RootLayout>))

export const onRequest = handle(app);
