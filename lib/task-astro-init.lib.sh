# vim: set filetype=sh :
# shellcheck shell=sh
test "${sourced_eb0c4bb:+}" = true && return 0; sourced_eb0c4bb=true

. ./task-jq.lib.sh
. ./task-node.lib.sh

astro_pages_index_9037723() {
  cat <<'EOF'
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
}

astro_public_robots_txt_02a2bd1() {
  cat <<'EOF'
# Example: Allow all bots to scan and index your site.
# Full syntax: https://developers.google.com/search/docs/advanced/robots/create-robots-txt
User-agent: *
Allow: /
EOF
}

astro_config_mjs_fb776d2() {
  cat <<'EOF'
import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
  srcDir: './src',
  outDir: './dist',
  publicDir: './public',
});
EOF
}

tsconfig_json_c5efc67() {
  cat <<'EOF'
{
  "compilerOptions": {
    // To use JSX syntax in *.tsx files.
    "module": "nodenext",
    "moduleResolution": "nodenext",
    "jsx": "react-jsx",
    // "types": [
    //   "bun-types"
    // ],
    "baseUrl": "./src",
    "paths": {
      "@src/*": ["./*"],
    },
  },
}
EOF
}

# Install Astro | Docs https://docs.astro.build/en/install-and-setup/

task_astro__init() {
  if \
    ! subcmd_jq -e '.dependencies["astro"]' ./package.json >/dev/null 2>&1 &&
    ! subcmd_jq -e '.devDependencies["astro"]' ./package.json >/dev/null 2>&1
  then
    echo "Installing Astro." >&2
    subcmd_npm install astro
  fi
  if test -d ./src
  then
    echo "Directory ./src already exists. Skipping the creation." >&2
  else
    echo "Creating the ./src directory." >&2
    mkdir -p ./src/pages
    astro_pages_index_9037723 >./src/pages/index.astro
  fi
  if test -d ./public
  then
    echo "Directory ./public already exists. Skipping the creation." >&2
  else
    echo "Creating the ./public directory." >&2
    mkdir -p ./public
    astro_public_robots_txt_02a2bd1 >./public/robots.txt
  fi
  if test -f ./astro.config.mjs
  then
    echo "File ./astro.config.mjs already exists. Skipping the creation." >&2
  else
    echo "Creating the ./astro.config.mjs file." >&2
    astro_config_mjs_fb776d2 >./astro.config.mjs
  fi
  if test -f ./tsconfig.json
  then
    echo "File ./tsconfig.json already exists. Skipping the creation." >&2
  else
    echo "Creating the ./tsconfig.json file." >&2
    tsconfig_json_c5efc67 >./tsconfig.json
  fi
}

