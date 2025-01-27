import { expect, test, mock } from "bun:test";
import { app } from 'functions/var/timestamp'

test('Mock', async () => {
  mock.module('@sqlcgen/querier', () => ({
    getUsersCount: async () => {
      return { foo: 42 }
    }
  }));
  const resp = await app.request(
    '/var/timestamp',
    {
      method: 'GET',
    },
    {
      DB: null,
    },
  );
  expect(resp.status).toBe(200)
  expect(await resp.text()).toMatch(/Count: 42/)
});
