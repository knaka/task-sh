# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_e8a8142-false}" && return 0; sourced_e8a8142=true

. ./cloudflare-api.lib.sh

: "${default_zone_name_c66a270:=example.com}"

set_cf_dns_zone_name() {
  default_zone_name_c66a270="$1"
}

cf_zones() {
  local resp="$TEMP_DIR"/f84002f.json
  cf_req GET "https://api.cloudflare.com/client/v4/zones" >"$resp"
  if ! jq --exit-status 'if .success then .result else empty end' <"$resp"
  then
    jq . <"$resp" >&2
    return 1
  fi
}

cf_zone() {
  local zone_name="$1"
  memoize cf_zones \
  | jq --exit-status \
    --arg zone_name "$zone_name" \
    '.[] | select(.name == $zone_name)'
}

# Get Cloudflare DNS zone information
task_cf__dns__zone() {
  cf_zone "$default_zone_name_c66a270"
}

cf_zone_id() {
  cf_zone "$1" | jq --exit-status --raw-output '.id'
}

# Get Cloudflare DNS zone ID
task_cf__dns__zone__id() {
  cf_zone_id "$default_zone_name_c66a270"
}

cf_dns_records() {
  local zone_name="$1"
  local zone_id="$(cf_zone_id "$zone_name")"
  local resp="$TEMP_DIR"/fc848cf.json
  cf_req GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records" >"$resp"
  if ! jq --exit-status 'if .success then .result else empty end' <"$resp"
  then
    jq . <"$resp" >&2
    return 1
  fi
}

# List all Cloudflare DNS records for the zone
task_cf__dns__records() {
  cf_dns_records "$default_zone_name_c66a270"
}

cf_dns_record() {
  local zone_name="$1"
  local record_name="$2"
  local record_type="$3"
  cf_dns_records "$zone_name" \
  | jq --exit-status \
    --arg record_name "$record_name" \
    --arg record_type "$record_type" \
    '.[] | select(.name == $record_name and .type == $record_type)'
}

cf_a_record_ensure() {
  local zone_name="$1"
  local record_name="$2"
  local zone_id
  zone_id="$(cf_zone_id "$zone_name")"
  local method="POST"
  local url="https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records"
  local body="$(
    # TTL: 1 for automatic
    jq --null-input --compact-output \
      --arg record_type "A" \
      --arg record_name "$record_name" \
      --arg public_ip "$(ip_address)" \
      '{
        type: $record_type,
        name: $record_name,
        content: $public_ip,
        ttl: 1,
        proxied: false
      }'
  )"
  local dns_record
  if dns_record="$(cf_dns_record "$zone_name" "$record_name" "A")"
  then
    # Update existing record
    local dns_record_id="$(echo "$dns_record" | jq --raw-output '.id')"
    url="https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$dns_record_id"
    method="PUT"
  fi
  cf_req "$method" "$url" "$body" | jq .
}
