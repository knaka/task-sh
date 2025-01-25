import { expect, test } from "bun:test";
import { createStreamWithTemplate } from './template_stream';

function createTextStream(text: string): ReadableStream<Uint8Array> {
  return new ReadableStream({
    start(controller) {
      controller.enqueue(new TextEncoder().encode(text));
      controller.close();
    },
  });
}

test('createStreamWithTemplate', async () => {
  const resultStream = createStreamWithTemplate(
    'start placeholder end',
    'placeholder',
    createTextStream('hello'),
  );
  expect(await ((new Response(resultStream)).text())).toBe('start hello end');
});
