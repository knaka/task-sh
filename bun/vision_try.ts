export {};

const apiKey = Bun.argv[2];
const imageFilePath = Bun.argv[3];

const imageStream = Bun.file(imageFilePath).stream();
const visionApiUrl = `https://vision.googleapis.com/v1/images:annotate?key=${apiKey}`;

function createStreamWithTemplate(
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

const base64ImageStream = imageStream.pipeThrough(base64Transform);

const requestBodyStream = createStreamWithTemplate(requestBodyTemplate, "aa7c245", base64ImageStream);

// console.log(await (new Response(bodyStream).text()));

const resp = await fetch(visionApiUrl, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: requestBodyStream,
});

if (! resp.ok) {
  throw new Error(`Failed to fetch: ${resp.status} ${resp.statusText} ${await resp.text()}`);
}

const jsonResp = await resp.json();
console.log('Response:', jsonResp);
