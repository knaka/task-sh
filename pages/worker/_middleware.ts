export async function onRequest(c: any) {
  console.log("17ccbbb", c.request.url);
  return await c.next();
  // return new Response(`Error 575ba84`, { status: 500 });
}
