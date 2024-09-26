const { task } = require("./task.cjs");

task("baz", "baz with [args]", (...args) => {
  console.log("task baz:", args);
});
