# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_08c2f4a-false}" && return 0; sourced_08c2f4a=true

. ./task.sh

# Refer to the following page for instructions on how to get the API token.
# Create API token · Cloudflare Fundamentals docs https://developers.cloudflare.com/fundamentals/api/get-started/create-token/
#
# Instructions on Cloudflare dashboard:
#   - Dashboard -> Menu -> "Profile" -> "API Tokens" -> Press "Create Token"
#   - Use the "Edit zone DNS" template
: "${api_token_64d7b18:=}"

set_cf_api_token() {
  api_token_64d7b18="$1"
}

cf_req() {
  if test "${api_token_64d7b18+set}" != set || test -z "$api_token_64d7b18"
  then
    echo "Cloudflare API token is not set." >&2
    return 1
  fi
  local method="$1"
  shift
  local url="$1"
  shift
  local body=""
  if test "${1+set}" = "set"
  then
    body="$1"
    shift
  fi
  set -- \
    --request "$method" \
    "$url" \
    --data "$body" \
    --fail \
    --header "Authorization: Bearer $api_token_64d7b18" \
    --header "Content-Type: application/json" \
    --silent \
    "$@"
  curl "$@" | jq --compact-output
}

# Verify Cloudflare API client token
task_cf__api__verify() {
  cf_req GET "https://api.cloudflare.com/client/v4/user/tokens/verify"
}
