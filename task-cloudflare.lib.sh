# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_4bfdf93-false}" && return 0; sourced_4bfdf93=true

. ./task-node.lib.sh
. ./task-yq.lib.sh

: "${wrangler_toml_path:=$PROJECT_DIR/wrangler.toml}"

wrangler() {
  run_node_modules_bin wrangler bin/wrangler.js "$@"
}

# Run the Cloudflare Wrangler command.
subcmd_wrangler() {
  wrangler "$@"
}

# Show the name of the Cloudflare project.
subcmd_cf__name() {
  yq --exit-status eval ".name" "$wrangler_toml_path"
}

# Generate TypeScript types for the Cloudflare project.
subcmd_cf__typegen() {
  wrangler types
}

# Show the Cloudflare account information which is logged in.
task_cf__whoami() {
  wrangler whoami
}

# Check localy if the user is authenticated with Cloudflare.
task_cf__authenticated() {
  local config_file="$HOME"/.wrangler/config/default.toml
  ! test -r "$config_file" && return 1
  local expiration_utc_time_iso="$(yq --exit-status eval .expiration_time "$config_file")"
  test -z "$expiration_utc_time_iso" && return 1
  local current_utc_time_iso="$(LANG=C date -u +%Y-%m-%dT%H:%M:%SZ)"
  expr "$expiration_utc_time_iso" \> "$current_utc_time_iso" >/dev/null
}
