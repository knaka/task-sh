#!/bin/sh
set -o nounset -o errexit

# Move to the root of the repository.
cd "$(git rev-parse --show-toplevel)"

# Push the submodules.
# shellcheck disable=SC2162
git submodule | while read -r line
do
  (
    dir=$(echo "$line" | awk '{print $2}')
    cd "$dir"
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    git push origin "$current_branch" "$@" || :
  )
done

# Then, push the main repository.
current_branch=$(git rev-parse --abbrev-ref HEAD)
echo git push origin "$current_branch" "$@"
git push origin "$current_branch" "$@"
