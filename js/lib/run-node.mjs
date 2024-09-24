import { spawn } from "cross-spawn";

spawn(
  process.execPath,
  process.argv.slice(3),
  {
    stdio: "inherit",
    cwd: process.argv[2],
  }
).on("close", (code) => {
  console.error("Exited with code", code);
  process.exit(code);
}).on("error", (err) => {
  console.error("Failed to spawn", process.argv.slice(3));
  console.error(err);
  process.exit(1);
});
