let tasks = {};

const task = exports.task = (name, help, fn) => {
  tasks[name] = fn;
  tasks[name].help = help;
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
  const files = fs.readdirSync(".").filter(file => file.startsWith("task-") && file.endsWith(".cjs"));
  files.forEach(file => {
    const new_tasks = require(`./${file}`);
    tasks = {...tasks, ...new_tasks};
  });
  tasks[args[0]](...args.slice(1));
}

if (! module.parent) {
  main(...process.argv.slice(2));
}
