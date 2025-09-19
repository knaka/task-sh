# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_f3f1aa3-false}" && return 0; sourced_f3f1aa3=true

. ./task.sh

ver_5942f2c="16"

set_postgresql_version() {
  ver_5942f2c="$1"
}

for xb037ce6 in psql initdb pg_ctl
do
  require_pkg_cmd \
    --name="$xb037ce6" \
    --brew-id=postgresql@"$ver_5942f2c" \
    --winget-id=PostgreSQL.PostgreSQL."$ver_5942f2c" \
    --deb-id=postgresql-"$ver_5942f2c" \
    /usr/local/opt/postgresql@"$ver_5942f2c"/bin/"$xb037ce6" \
    "C:/Program Files/PostgreSQL/$ver_5942f2c/bin/$xb037ce6.exe" \
    /usr/lib/postgresql/"$ver_5942f2c"/bin/"$xb037ce6" \
    #nop
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
