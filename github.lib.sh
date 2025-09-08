# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_36e3178-false}" && return 0; sourced_36e3178=true

. ./task.sh

github_blob_get() {
  local owner=
  local repos=
  local file_sha=main
  OPTIND=1; while getopts -: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (owner) owner="$OPTARG";;
      (repos) repos="$OPTARG";;
      (file-sha) file_sha="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  # REST API endpoints for Git blobs - GitHub Docs https://docs.github.com/en/rest/git/blobs?apiVersion=2022-11-28
  local url="$(printf "https://api.github.com/repos/%s/%s/git/blobs/%s" "$owner" "$repos" "$file_sha")"
  github_api_request "$url"
}

github_contents_get() {
  local owner=
  local repos=
  local path=
  local ref=
  OPTIND=1; while getopts -: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (owner) owner="$OPTARG";;
      (repos) repos="$OPTARG";;
      (path) path="$OPTARG";;
      (ref) ref="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  # REST API endpoints for repository contents - GitHub Docs https://docs.github.com/en/rest/repos/contents?apiVersion=2022-11-28
  local url="$(printf "https://api.github.com/repos/%s/%s/contents/%s?ref=%s" "$owner" "$repos" "$path" "$ref")"
  github_api_request "$url"
}

# Usage:
#   github_fetch ... /path/to/foo.js # -> ./foo.js
#   github_fetch ... --output=./bar.js /path/to/foo.js -> ./bar.js
#   github_fetch ... --outdir=./baz /path/to/foo.js -> ./baz/foo.js
#   github_fetch ... --outdir=./baz "/path/to/dir/ -> ./baz/*
#   github_fetch ... "/path/to/dir/*.js" -> ./*.js
github_fetch() {
  local owner=
  local repos=
  local tree_sha=main
  local output=
  local outdir=
  OPTIND=1; while getopts _-: OPT
  do
    if test "$OPT" = "-"
    then
      OPT="${OPTARG%%=*}"
      # shellcheck disable=SC2030
      OPTARG="${OPTARG#"$OPT"}"
      OPTARG="${OPTARG#=}"
    fi
    case "$OPT" in
      (owner) owner="$OPTARG";;
      (repos) repos="$OPTARG";;
      (branch|tag|tree_sha|tree) tree_sha="$OPTARG";;
      (output) output="$OPTARG";;
      (outdir) outdir="$OPTARG";;
      (\?) exit 1;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  if test -n "$output" -a -n "$outdir"
  then
    echo "You cannot specify both --output=... and --outdir=..." >&2
    return 1
  fi
  local path=
  if test "$#" -gt 0
  then
    path="$1"
  fi
  local base="${path##*/}"
  local pattern=
  case "$base" in
    (*\**|*\?*)
      pattern="$base"
      path="${path%/*}"
      ;;
  esac
  local url="$(printf "https://api.github.com/repos/%s/%s/contents%s?ref=%s" "$owner" "$repos" "$path" "$tree_sha")"
  local json="$TEMP_DIR"/85db295.json
  local out="$TEMP_DIR/55c58eb.dat"
  if ! curl --fail "$url" >"$json"
  then
    cat "$json"
    return 1
  fi
  if jq --exit-status '. | type == "object"' <"$json" >/dev/null
  then
    jq --exit-status --raw-output --join-output '.content | gsub("\n"; "") | @base64d' <"$json" >"$out"
    if ! test "$(jq --exit-status --raw-output '.sha' <"$json")" = "$(git hash-object "$out")"
    then
      echo "Hash of the data downloaded does not match for \"$path\"". >&2
      return 1
    fi
    if test -n "$output"
    then
      cat "$out" >"$output"
    else
      cat "$out" >"$outdir"/"$base"
    fi
  elif jq --exit-status '. | type == "array"' <"$json" >/dev/null
  then
    local file
    for file in $(jq --exit-status --raw-output '.[] | .name' <"$json")
    do
      case "$file" in
        ("$pattern") ;;
        (*) continue;;
      esac
      github_fetch --owner="$owner" --repos="$repos" --tree_sha="$tree_sha" --outdir="$outdir" "$path/$file"
    done
  else
    echo "Unexpected." >&2
    return 1
  fi
}

subcmd_github__fetch() {
  github_fetch "$@"
}
