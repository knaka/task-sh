# vim: set filetype=sh :
# shellcheck shell=sh
test "${sourced_eb0c4bb:+}" = true && return 0; sourced_eb0c4bb=true

. ./task.sh
. ./task-jq.lib.sh
. ./task-node.lib.sh

write_src_pages_index_astro_9037723() {
  local src_dir="$1"
  file_path="$src_dir"/pages/index.astro
  if test -f "$file_path"
  then
    echo "File $file_path already exists. Skipping the creation." >&2
    return 0
  fi
  echo "Creating the $file_path file." >&2
  mkdir -p "$(dirname "$file_path")"
  cat <<'EOF' >"$file_path"
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

write_public_robots_txt_9a1e5b2() {
  local public_dir="$1"
  local file_path="$public_dir"/robots.txt
  if test -f "$file_path"
  then
    echo "File $file_path already exists. Skipping the creation." >&2
    return 0
  fi
  echo "Creating the $file_path file." >&2
  mkdir -p "$(dirname "$file_path")"
  cat <<'EOF' >"$file_path"
# Example: Allow all bots to scan and index your site.
# Full syntax: https://developers.google.com/search/docs/advanced/robots/create-robots-txt
User-agent: *
Allow: /
EOF
}

write_src_astro_config_mjs_05cb4bc() {
  local src_dir="$1"
  local out_dir="./dist"
  local public_dir="./public"
  local file_path="./astro.config.mjs"
  if test -f "$file_path"
  then
    echo "File $file_path already exists. Skipping the creation." >&2
    return 0
  fi
  echo "Creating the $file_path file." >&2
  mkdir -p "$(dirname "$file_path")"
  cat <<EOF >"$file_path"
import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
  srcDir: '${src_dir}',
  outDir: '${out_dir}',
  publicDir: '${public_dir}',
});
EOF
}

write_tsconfig_json_829c14b() {
  local src_dir="./src"
  local file_path="./tsconfig.json"
  if test -f "$file_path"
  then
    echo "File $file_path already exists. Skipping the creation." >&2
    return 0
  fi
  echo "Creating the $file_path file." >&2
  cat <<EOF >"$file_path"
{
  "compilerOptions": {
    // To use JSX syntax in *.tsx files.
    "module": "nodenext",
    "moduleResolution": "nodenext",
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

# Install Astro | Docs https://docs.astro.build/en/install-and-setup/

task_astro__init() {
  local src_dir out_dir public_dir
  src_dir="$(prompt "Source directory" "./src")"
  out_dir="$(prompt "Output directory" "./dist")"
  public_dir="$(prompt "Public directory" "./public")"
  if \
    ! subcmd_jq -e '.dependencies["astro"]' ./package.json >/dev/null 2>&1 &&
    ! subcmd_jq -e '.devDependencies["astro"]' ./package.json >/dev/null 2>&1
  then
    echo "Installing Astro." >&2
    subcmd_npm install astro
  fi
  write_src_pages_index_astro_9037723 "$src_dir"
  write_public_robots_txt_9a1e5b2 "$public_dir"
  write_src_astro_config_mjs_05cb4bc "$src_dir" "$out_dir" "$public_dir"
  write_tsconfig_json_829c14b "$src_dir"
}
