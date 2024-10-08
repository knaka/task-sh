export default {
  async fetch(request: any, env: any) {
    // fs.writeFileSync('/tmp/worker-fetch.txt', 'fetching ' + request.url + '\n', { flag: 'a' });
    const url = new URL(request.url);
    if (url.pathname.startsWith('/api/')) {
      // TODO: Add your custom /api/* logic here.
      const resp = new Response('Ok ce74cfc');
      resp.headers.append("Access-Control-Allow-Origin", "*");
      resp.headers.append("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
      return resp;
    }
    // Otherwise, serve the static assets.
    // Without this, the Worker will error and no assets will be served.
    return env.ASSETS.fetch(request);
  },
}
