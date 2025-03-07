import { createServer } from 'node:http';
import { stat as statAsync } from 'node:fs/promises';
import { extname, join } from 'node:path';
import { createReadStream } from 'node:fs';
import { lookup as mimeLookup } from 'mime-types';

const working_dir = process.argv[2] || process.cwd();
const host = process.argv[3] || '127.0.0.1';
const port = parseInt(process.argv[4], 10) || 80;

async function tryStatAsync(path) {
  try {
    return await statAsync(path);
  } catch {
    return null;
  }
}

const server = createServer(async (reqIn, respOut) => {
  const url = reqIn.url ?? '/';
  let filePath = join(working_dir, (url === '/')? 'index.html': url);
  if ((await tryStatAsync(filePath))?.isFile()) {
    // do nothing
  } else if ((await tryStatAsync(filePath + '.html'))?.isFile()) {
    filePath += '.html';
  } else if ((await tryStatAsync(filePath + '/index.html'))?.isFile()) {
    filePath += '/index.html';
  } else {
    respOut.writeHead(404, { 'Content-Type': 'text/plain' });
    respOut.end('404 Not Found');
    console.log(`404 Not Found: ${filePath}`);
    return;
  }
  const ext = extname(filePath);
  const mimeType = mimeLookup(ext) || 'application/octet-stream';
  respOut.writeHead(200, { 'Content-Type': mimeType });
  createReadStream(filePath).pipe(respOut);
});

server.listen(port, host, () => {
  console.log(`HTTP Server running at http://${host}:${port}/ , providing the content of the current directory (${working_dir})`);
});
