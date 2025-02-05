import { utimesSync } from "fs";

test('Fetch local file', async () => {
  const fileName = 'test.png';
  const fileSize = 812;

  const response = await fetch(`file://${__dirname}/${fileName}`);

  const arrayBuffer = await response.arrayBuffer();
  expect(arrayBuffer.byteLength).toBe(fileSize);

  const readableStream = new Blob([arrayBuffer]).stream();
  const arrayBufferRev = await new Response(readableStream).arrayBuffer();
  expect(arrayBufferRev.byteLength).toBe(fileSize);
  const uint8Array = new Uint8Array(arrayBuffer);
  expect(uint8Array.length).toBe(fileSize);
  const uint8ArrayRev = new Uint8Array(arrayBufferRev);
  expect(uint8ArrayRev.length).toBe(fileSize);
  for (let i = 0; i < fileSize; i++) {
    expect(uint8Array[i]).toBe(uint8ArrayRev[i]);
  }
  expect(uint8Array).toEqual(uint8ArrayRev);
});
