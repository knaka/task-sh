import { expect, test } from "bun:test";
import { app } from 'functions/api/[[all]]'

test('POST greet', async () => {
  const resp = await app.request('/api/greet', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ name: 'world' }),
  });
  expect(resp.status).toBe(200)
  expect(await resp.json()).toEqual({ message: 'Hello, world!' })
})

test('POST greet invalid request', async () => {
  const res = await app.request('/api/greet', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ foo: 'bar' }),
  });
  expect(res.status).toBe(400);
});
