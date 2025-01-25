import { createStreamWithTemplate } from './template_stream';
import { base64Transform } from './base64_stream';

const apiKey = Bun.argv[2];
const imageFilePath = Bun.argv[3];

const imageStream = Bun.file(imageFilePath).stream();
const visionApiUrl = `https://vision.googleapis.com/v1/images:annotate?key=${apiKey}`;

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
