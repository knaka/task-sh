#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_ab19944-}" = true && return 0; sourced_ab19944=true
set -o nounset -o errexit

if test "${API_KEY+set}" != set; then
  echo "API_KEY is not set" >&2
  exit 1
fi

cat <<EOF | curl -s -X POST "https://vision.googleapis.com/v1/images:annotate?key=${API_KEY}" -H "Content-Type: application/json" --data-binary @-
{
  "requests":[
    {
      "image":{
        "content": "$(base64 --input - --output -)"
      },
      "features":[
        {
          "type":"TEXT_DETECTION",
          "maxResults":10
        }
      ]
    }
  ]
}
EOF