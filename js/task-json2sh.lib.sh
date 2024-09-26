#!/bin/sh
set -o nounset -o errexit

subcmd_json2sh() { # Convert JSON to shell script.
  cd "$(dirname "$)")" || exit 1
  script="$(cat <<'EOF'
const { readFileSync } = require('fs');

const json2sh = (obj, prefix = "json__") => {
  let result = "";
  for (const key in obj) {
    const keyForShell = key.replace(/[-\.]/g, "_");
    if (typeof obj[key] === "object") {
      result += json2sh(obj[key], `${prefix}${keyForShell}__`);
    } else {
      result += `${prefix}${keyForShell}="${obj[key]}"\n`;
    }
  }
  return result;
};

process.stdout.write(json2sh(process.argv[2] ?
  JSON.parse(readFileSync(process.argv[2], 'utf8')) :
  JSON.parse(readFileSync(0, 'utf8'))
));
EOF
)"
  subcmd_volta run node -e "$script" "$@"
}
