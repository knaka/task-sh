# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_f3f1aa3-false}" && return 0; sourced_f3f1aa3=true

. ./task.sh

for xb037ce6 in psql initdb pg_ctl
do
  require_pkg_cmd \
    --brew-id=postgresql@15 \
    --winget-id=PostgreSQL.PostgreSQL.15 \
    /usr/local/opt/postgresql@15/bin/"$xb037ce6" \
    "C:/Program Files/PostgreSQL/15/bin/$xb037ce6.exe" \
    "$xb037ce6"
done

initdb() {
  run_pkg_cmd initdb "$@"
}

subcmd_initdb() {
  initdb "$@"
}

psql() {
  run_pkg_cmd psql "$@"
}

subcmd_psql() {
  psql "$@"
}

pg_ctl() {
  run_pkg_cmd pg_ctl "$@"
}

subcmd_pg_ctl() {
  pg_ctl "$@"
}
