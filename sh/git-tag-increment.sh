#!/bin/sh
set -o nounset -o errexit

latest_tag=$(git describe --tags --abbrev=0)
major_minor="${latest_tag%.*}"
patch="${latest_tag##*.}"
patch=$((patch + 1))
new_tag="$major_minor.$patch"
echo git tag "$new_tag"
echo git push origin "$new_tag"
