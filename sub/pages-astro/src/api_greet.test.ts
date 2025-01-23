import { app } from './functions/api/greet'

test('POST greet is ok', async () => {
  const res = await app.request('/api/greet', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ name: 'world' }),
  });
  expect(res.status).toBe(200)
  expect(await res.json()).toEqual({ message: 'Hello, world!' })
})

test('Invalid JSON', async () => {
  const res = await app.request('/api/greet', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ foo: 'bar' }),
  });
  expect(res.status).toBe(400);
});
