// node_modules は、このファイルの位置を起点に探される。Node.js では、スクリプトファイルの位置が起点でライブラリパスが決まる
import lodash from "lodash";

const { memoize } = lodash;
const foo = memoize(() => {
  return "foo";
});

console.error(`Hello, Node.js! ${foo()}`);
console.error("argv", process.argv);
console.error("cwd", process.cwd());
console.error("NODE_PATH", process.env.NODE_PATH);

process.exit(0);
