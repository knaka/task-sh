import { expect, test, mock } from "bun:test";
import { app } from 'functions/var/[[all]]'

test('Mocking works', async () => {
  mock.module('@sqlcgen/querier', () => ({
    getUsersCount: async () => {
      return { foo: 42 }
    }
  }));
  const resp = await app.request(
    '/var/hello',
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
