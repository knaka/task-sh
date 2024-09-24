import spawn from "cross-spawn";

process.exit(await new Promise(resolve => spawn("false", [], {stdio: "inherit", cwd: "."}).on("close", resolve)));
// process.exit(await new Promise((resolve, reject) => spawn("false", [], {stdio: "inherit"}).on("close", resolve).on("error", () =>reject)));
