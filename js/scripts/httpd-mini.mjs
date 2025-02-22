import { createServer } from 'http';
import { promises as fs } from 'fs';
import { extname, join } from 'path';
import { createReadStream } from 'fs';
import { lookup } from 'mime-types'; // npm install mime-types

const host = process.argv[2] || '127.0.0.1';
const port = process.argv[3] || 80;
const working_dir = process.argv[4] || process.cwd();

const server = createServer(async (req, resp) => {
  const filePath = join(working_dir, req.url === '/' ? 'index.html' : req.url);

  try {
    const stat = await fs.stat(filePath);
    if (stat.isFile()) {
      const ext = extname(filePath);
      const mimeType = lookup(ext) || 'application/octet-stream';
      resp.writeHead(200, { 'Content-Type': mimeType });
      createReadStream(filePath).pipe(resp);
    } else {
      resp.writeHead(404, { 'Content-Type': 'text/plain' });
      resp.end('404 Not Found');
    }
  } catch (err) {
    resp.writeHead(404, { 'Content-Type': 'text/plain' });
    resp.end('404 Not Found');
  }
});

server.listen(port, host, () => {
  console.log(`HTTP Server running at http://${host}:${port}/ , providing the content of the current directory (${working_dir})`);
});
