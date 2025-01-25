import { expect, test } from "bun:test";
import { base64Transform } from './base64_stream';

test('base64Transform', async () => {
  const encoder = new TextEncoder();
  const decoder = new TextDecoder();
  const input = encoder.encode('hello');
  const output = await new Response(new ReadableStream<Uint8Array>({
    async start(controller) {
      controller.enqueue(input);
      controller.close();
    },
  }).pipeThrough(base64Transform)).arrayBuffer();
  expect(decoder.decode(new Uint8Array(output))).toBe('aGVsbG8');
});
