import { createWriteStream } from 'fs';
const writer = createWriteStream(process.argv[2]);

for (let i = 0; i < 3; i++) {
  // Sleep for 1 second and write “Hello” to the file
  await new Promise(resolve => setTimeout(resolve, 1000));
  writer.write(`Hello ${i}\n`);
}
writer.end();
