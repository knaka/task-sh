# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_bcc3e4a-false}" && return 0; sourced_bcc3e4a=true

# Caddy - The Ultimate Server with Automatic HTTPS https://caddyserver.com/
# Caddy - Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS https://github.com/caddyserver/caddy

. ./task.sh

# Releases · caddyserver/caddy https://github.com/caddyserver/caddy/releases
cadd_version_337709f="2.10.2"

set_cadd_version() {
  cadd_version_337709f="$1"
}

caddy() {
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="caddy" \
    --ver="$cadd_version_337709f" \
    --os-map="Darwin mac $goos_map" \
    --arch-map="$goarch_map" \
    --ext-map="$archive_ext_map" \
    --url-template='https://github.com/caddyserver/caddy/releases/download/v${ver}/caddy_${ver}_${os}_${arch}${ext}' \
    -- \
    "$@"
}

# Run caddy(1).
subcmd_caddy() {
  caddy "$@"
}
