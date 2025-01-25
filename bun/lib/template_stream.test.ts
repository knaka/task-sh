import { expect, test } from "bun:test";
import { createTextStream } from './text_stream';
import { createStreamWithTemplate } from './template_stream';

test('createStreamWithTemplate', async () => {
  const resultStream = createStreamWithTemplate(
    'start placeholder end',
    'placeholder',
    createTextStream('hello'),
  );
  expect(await ((new Response(resultStream)).text())).toBe('start hello end');
});
