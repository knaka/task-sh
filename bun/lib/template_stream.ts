export function createStreamWithTemplate(
  template: string,
  placeholder: string,
  inputStream: ReadableStream<Uint8Array>,
): ReadableStream<Uint8Array> {
  const encoder = new TextEncoder();
  const reader = inputStream.getReader();
  return new ReadableStream<Uint8Array>({
    async start(controller) {
      const [start, end] = template.split(placeholder);
      controller.enqueue(encoder.encode(start));
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        controller.enqueue(value);
      }
      controller.enqueue(encoder.encode(end));
      controller.close();
    },
  });
}
