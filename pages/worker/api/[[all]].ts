import { handle } from 'hono/cloudflare-pages'
import { app, route } from './_all';

export const onRequest = handle(app);

