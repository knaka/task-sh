# vim: set filetype=sh :
# shellcheck shell=sh
test "${sourced_eb0c4bb:+}" = true && return 0; sourced_eb0c4bb=true

. ./task.sh
. ./task-jq.lib.sh
. ./task-node.lib.sh

# Install Astro | Docs https://docs.astro.build/en/install-and-setup/

task_astro__init() { # Initialize Astro.
  local src_dir out_dir public_dir

  src_dir="$(prompt "Source directory" "./src")"
  out_dir="$(prompt "Output directory" "./dist")"
  public_dir="$(prompt "Public directory" "./public")"

  if subcmd_jq -e '.dependencies.astro // .devDependencies.astro' ./package.json >/dev/null 2>&1
  then
    echo "Astro is already installed." >&2
  else
    echo "Installing Astro." >&2
    subcmd_npm install astro
  fi

  ensure_file "${src_dir}"/pages/index.astro <<'EOF'
---
// Welcome to Astro! Everything between these triple-dash code fences
// is your "component frontmatter". It never runs in the browser.
console.log('This runs in your terminal, not the browser!');
---
<!-- Below is your "component template." It's just HTML, but with
    some magic sprinkled in to help you build great templates. -->
<html>
  <body>
    <h1>Hello, World!</h1>
  </body>
</html>
<style>
  h1 {
    color: orange;
  }
</style>
EOF

  ensure_file "${public_dir}"/robots.txt <<'EOF'
# Example: Allow all bots to scan and index your site.
# Full syntax: https://developers.google.com/search/docs/advanced/robots/create-robots-txt
User-agent: *
Allow: /
EOF

  ensure_file ./astro.config.mjs <<EOF
import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
  srcDir: '${src_dir}',
  outDir: '${out_dir}',
  publicDir: '${public_dir}',
});
EOF

  ensure_file ./tsconfig.json <<EOF
{
  "compilerOptions": {
    "module": "nodenext",
    "moduleResolution": "nodenext",
    // To use JSX syntax in *.tsx files.
    "jsx": "react-jsx",
    // "types": [
    //   "bun-types"
    // ],
    "baseUrl": "${src_dir}",
    "paths": {
      "@src/*": ["./*"],
    },
  },
}
EOF
}
