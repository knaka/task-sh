import spawn from "cross-spawn";

// console.error("PATH", process.env.PATH);
await new Promise(resolve =>
  spawn("npx", [
    "--help",
    // ...quiet_options,
    // "--jakefile", join("jakelib", "scr", "bootstrap.cjs"),
    // ...tasks
  ], {stdio: "inherit"}).on("exit", resolve)
);
;