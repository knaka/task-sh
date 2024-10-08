// worker/index.ts
var worker_default = {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname.startsWith("/api/")) {
      const resp = new Response("Ok ce74cfc");
      resp.headers.append("Access-Control-Allow-Origin", "*");
      resp.headers.append("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
      return resp;
    }
    return env.ASSETS.fetch(request);
  }
};
export {
  worker_default as default
};
