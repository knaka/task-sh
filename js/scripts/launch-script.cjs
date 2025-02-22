const working_dir = process.argv[2];
const args = process.argv.slice(3);

// console.log(`cwd: ${working_dir}`);
// console.log(`p: ${args}`);

const { spawn } = require("child_process");
spawn(
  process.execPath,
  args,
  {
    stdio: "inherit",
    cwd: working_dir
  }
)
.on("close",
  (code) => process.exit(code)
)
.on("error",
  (err) => {
    console.error(err);
    process.exit(1);
  }
)
;
