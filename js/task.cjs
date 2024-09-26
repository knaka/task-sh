let tasks = {};

if (process.env.ORIGINAL_WD) {
  process.chdir(process.env.ORIGINAL_WD);
}

const task = exports.task = (name, help, fn) => {
  tasks[name] = fn;
  tasks[name].help = help;
}

let subcmds = {};

const subcmd = exports.subcmd = (name, help, fn) => {
  subcmds[name] = fn;
  subcmds[name].help = help;
}

// --------------------------------------------------------------------------

task("foo", "Task foo [args]", (...args) => {
  console.log("task foo:", args);
})

task("bar", "Task bar [args]", (...args) => {
  console.log("task bar:", args);
})

task("tasks", "List all tasks", () => {
  const keys = Object.keys(tasks);
  const maxLen = keys.reduce((max, key) => Math.max(max, key.length), 0);
  Object.keys(tasks).forEach(name => {
    process.stdout.write(`${name.padEnd(maxLen)}  ${tasks[name].help}\n`);
  });
})

// --------------------------------------------------------------------------

function main(...args) {
  const fs = require("fs");
  const files = fs.readdirSync(".").filter(file =>
    file.startsWith("task-") &&
    (
      file.endsWith(".cjs") ||
      file.endsWith(".mjs") ||
      file.endsWith(".js")
    )
  );
  files.forEach(file => {
    const new_tasks = require(`./${file}`);
    tasks = {...tasks, ...new_tasks};
  });
  const subcmd = args[0];
  if (subcmds[subcmd]) {
    return subcmds[subcmd](...args.slice(1));
  }
  args.forEach(arg => {
    if (!tasks[arg]) {
      console.error(`Task ${arg} not found`);
      process.exit(1);
    }
    tasks[arg]();
  });
}

if (! module.parent) {
  main(...process.argv.slice(2));
}
