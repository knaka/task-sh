import { expect, test } from "bun:test";
import { createTextStream } from './text_stream';
import { createBase64Transform } from './base64_transform';

test('base64 transform', async () => {
  const resultStream = createTextStream('hello').pipeThrough(createBase64Transform());
  expect(await ((new Response(resultStream)).text())).toBe('aGVsbG8');
});
