# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_4bfdf93-false}" && return 0; sourced_4bfdf93=true

. ./node.lib.sh
. ./yq.lib.sh

# $CLOUDFLARE_ENV is originally an environment variable for the Vite plugin, but in this task runner, it is commonly used as a variable to specify the name of the deployment target environment for build, deploy, and other operations.
# Cloudflare Environments · Cloudflare Workers docs https://developers.cloudflare.com/workers/vite-plugin/reference/cloudflare-environments/
: "${CLOUDFLARE_ENV:=}"
export CLOUDFLARE_ENV

# Set Cloudflare environment name once and not overwrite it.
init_cf_env_once() {
  # Do not overwrite.
  first_call 2dd68cb || return 0
  # If other than "top" (empty string) is set, do not overwrite.
  test -n "$CLOUDFLARE_ENV" && return 0
  case "$1" in
  # When an empty string is specified for the environment name, the top-level values (default values) are used. — Configuration - Wrangler · Cloudflare Workers docs https://developers.cloudflare.com/workers/wrangler/configuration/
    (""|prod|production)
      CLOUDFLARE_ENV=""
      ;;
    (prev|preview)
      CLOUDFLARE_ENV="preview"
      ;;
    (test)
      CLOUDFLARE_ENV="test"
      ;;
    (*)
      echo "Unknown environment name \"$1\"." >&2
      exit 1
      ;;
  esac
  export CLOUDFLARE_ENV
}

: "${wrangler_toml_path:=$PROJECT_DIR/wrangler.toml}"

wrangler() {
  run_node_modules_bin wrangler/bin/wrangler.js "$@"
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

# Check locally if the user is authenticated with Cloudflare.
task_cf__authenticated() {
  local config_file="$HOME"/.wrangler/config/default.toml
  ! test -r "$config_file" && return 1
  local expiration_utc_time_iso="$(yq --exit-status eval .expiration_time "$config_file")"
  test -z "$expiration_utc_time_iso" && return 1
  local current_utc_time_iso="$(LANG=C date -u +%Y-%m-%dT%H:%M:%SZ)"
  expr "$expiration_utc_time_iso" \> "$current_utc_time_iso" >/dev/null
}
