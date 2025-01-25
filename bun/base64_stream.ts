export const base64Transform = new TransformStream<Uint8Array, Uint8Array>({
  async transform(chunk, controller) {
    const base64 = Buffer.from(chunk).toString('base64').replace(/=*$/, '');
    controller.enqueue(new TextEncoder().encode(base64));
  },
});
