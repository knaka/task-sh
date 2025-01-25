// bun vision_try.ts AIz... test.jpg

import { createStreamWithTemplate } from '@lib/template_stream';
import { createBase64Transform } from '@lib/base64_stream';

const apiKey = Bun.argv[2];
const imageFilePath = Bun.argv[3];

const imageStream = Bun.file(imageFilePath).stream();
const visionApiUrl = `https://vision.googleapis.com/v1/images:annotate?key=${apiKey}`;

const resp = await fetch(visionApiUrl, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: createStreamWithTemplate(JSON.stringify({
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
  }), "aa7c245", imageStream.pipeThrough(createBase64Transform())),
});

// console.log(await (new Response(bodyStream).text()));

if (! resp.ok) {
  throw new Error(`Failed to fetch: ${resp.status} ${resp.statusText} ${await resp.text()}`);
}

const respBody = await resp.json();
console.log('Response:', respBody);
