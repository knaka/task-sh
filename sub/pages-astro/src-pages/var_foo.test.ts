import { expect, test, mock } from "bun:test";
import { createApp } from 'functions/var/timestamp'

import * as SqclQuerier from '@sqlcgen/querier'

test('Mock', async () => {
  mock.module('@sqlcgen/querier', () => {
    return {
      getUsersCount: async () => {
        return { foo: 42 }
      }
    }
  });
  const app = createApp(SqclQuerier);
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
  expect(await resp.text()).toEqual('<html><body><h1>Count: 42</h1></body></html>');
});
