const { task } = require("./task.cjs");

task("baz", "Task baz [args]", (...args) => {
  console.log("task baz:", args);
});
