# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_d5f3082-false}" && return 0; sourced_d5f3082=true

# Traefik Proxy Documentation - Traefik https://doc.traefik.io/traefik/
# traefik/traefik: The Cloud Native Application Proxy https://github.com/traefik/traefik

. ./task.sh

# Releases · traefik/traefik https://github.com/traefik/traefik/releases
traefik_version_9112bb6="v3.5.2"

set_traefik_version() {
  traefik_version_9112bb6="$1"
}

traefik() {
  # shellcheck disable=SC2016
  run_fetched_cmd \
    --name="traefik" \
    --ver="$traefik_version_9112bb6" \
    --os-map="$goos_map" \
    --arch-map="$goarch_map" \
    --ext-map="$archive_ext_map" \
    --url-template='https://github.com/traefik/traefik/releases/download/${ver}/traefik_${ver}_${os}_${arch}${ext}' \
    -- \
    "$@"
}

# Run traefik(1).
subcmd_traefik() {
  traefik "$@"
}
