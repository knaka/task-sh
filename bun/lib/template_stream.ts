/**
 * Create a new stream by replacing a placeholder in a template with the content of another stream.
 * 
 * @param template string template with a placeholder
 * @param placeholder string placeholder to replace
 * @param inputStream ReadableStream<Uint8Array> stream to read from
 * @returns ReadableStream<Uint8Array> new stream
 */
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
