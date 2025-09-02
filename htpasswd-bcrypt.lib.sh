# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
test "${sourced_4c4cee6-}" = true && return 0; sourced_4c4cee6=true

. ./task.sh

require_pkg_cmd \
  --deb-id=apache2-utils \
  htpasswd

htpasswd() {
  run_pkg_cmd htpasswd "$@"
}

# htpasswd(1)
subcmd_htpasswd() {
  htpasswd "$@"
}

# [password] Create hash from password with bcrypt
subcmd_htpasswd__bcrypt__hash() {
  # -b: Batch mode. No prompt for password.
  # -n: Display the results on standard output.
  # -B: Use bcrypt encryption.
  # -C 10: Set the cost for bcrypt encryption to 10.
  # "": Username
  # "$1": Password
  htpasswd -bnBC 10 "" "$1" | sed -n -e 's/.*://p'
}

# [--password <password> --hash <hash>] Verify password against bcrypt hash
subcmd_htpasswd__bcrypt__verify() {
  local user=fa9a540
  local htpasswd_path="$TEMP_DIR"/045af3c
  local password=
  local hash=
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
      (password) password=$OPTARG;;
      (hash) hash=$OPTARG;;
      (\?) exit 1;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  echo "$user:$hash" >"$htpasswd_path"
  # -v: Verify the password.
  htpasswd -vb "$htpasswd_path" "$user" "$password" >/dev/null 2>&1
}
