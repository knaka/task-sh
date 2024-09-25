import { createServer } from 'http';

const host = process.argv[2] || '127.0.0.1';
const port = process.argv[3] || 80;

const server = createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('OK');
});

server.listen(port, host, () => {
  console.log(`Server running at http://${host}:${port}/`);
});
