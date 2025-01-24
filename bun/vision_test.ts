import * as fs from 'fs';
import { Readable } from 'node:stream';
import {
  ReadableStream,
  TransformStream,
} from 'node:stream/web';

const apiKey = process.argv[2];
const imageFilePath = process.argv[3];

console.log('API Key:', apiKey);
console.log('Image File Path:', imageFilePath);

const visionApiUrl = `https://vision.googleapis.com/v1/images:annotate?key=${apiKey}`;
const imageStream = Readable.toWeb(fs.createReadStream(imageFilePath));

// WebReadable.toWeb(fs.createReadStream(imageFilePath))

function createJsonStreamWithTemplate(template: string, placeholder: string, inputStream: ReadableStream<Uint8Array>): ReadableStream<Uint8Array> {
  const encoder = new TextEncoder();
  const reader = inputStream.getReader();
  let isFirstChunk = true;

  // TransformStream を作成
  return new ReadableStream<Uint8Array>({
    async start(controller) {
      // テンプレートの最初の部分（プレースホルダー前まで）を送信
      const [start, end] = template.split(placeholder);
      controller.enqueue(encoder.encode(start));

      // プレースホルダー部分にストリームを埋め込む
      while (true) {
        const { done, value } = await reader.read();
        if (done) break;
        controller.enqueue(value); // ストリームから読み取ったデータをそのまま送信
        isFirstChunk = false;
      }

      // テンプレートの残り部分を送信
      controller.enqueue(encoder.encode(end));
      controller.close();
    },
  });
}

const requestBodyTemplate = JSON.stringify({
  "requests": [
    {
      "image": { "content": "aa7c245" },
      "features": [
        {
          "type": "TEXT_DETECTION",
          "maxResults": 10,
        },
      ],
    },
  ],
});

const base64Transform = new TransformStream<Uint8Array, Uint8Array>({
  async transform(chunk, controller) {
    const base64 = Buffer.from(chunk).toString('base64').replace(/=*$/, '');
    controller.enqueue(new TextEncoder().encode(base64));
  },
});

const base64ImageReadableStream = imageStream.pipeThrough(base64Transform);

const jsonStream = createJsonStreamWithTemplate(requestBodyTemplate, "aa7c245", base64ImageReadableStream);

async function readStreamToString(stream: ReadableStream<Uint8Array>): Promise<string> {
  const reader = stream.getReader();
  const decoder = new TextDecoder(); // UTF-8 デコード用
  let result = '';

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    result += decoder.decode(value, { stream: true }); // 部分デコード
  }

  return result;
}

// const json = await readStreamToString(jsonStream);
// console.log('Request Body:', json);
// process.exit(0);

const resp = await fetch(visionApiUrl, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: jsonStream,
  duplex: 'half',
} as RequestInit);

if (!resp.ok) {
  throw new Error(`Failed to fetch: ${resp.status} ${resp.statusText} ${await resp.text()}`);
}

const jsonResp = await resp.json();
console.log('Response:', jsonResp);
