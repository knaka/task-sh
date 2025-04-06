import yaml from "js-yaml";
import pjson_strigify from "json-stringify-pretty-compact";

let input = "";
process.stdin.on("data", (chunk) => {
  input += chunk;
});

process.stdin.on("end", () => {
  try {
    const data = yaml.load(input);
    console.log(pjson_strigify(data, { maxLength: 80 }));
  } catch (e) {
    console.error(e);
    process.exit(1);
  }
});
