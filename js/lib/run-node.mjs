import { spawn } from "child_process";

spawn(process.execPath, process.argv.slice(3), {
  stdio: "inherit",
  cwd: process.argv[2],
}).on("close", (code) => {
  process.exit(code);
});
