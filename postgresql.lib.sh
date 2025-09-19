# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_f3f1aa3-false}" && return 0; sourced_f3f1aa3=true

. ./task.sh

ver_5942f2c="16"

set_postgresql_version() {
  ver_5942f2c="$1"
}

for xb037ce6 in initdb pg_ctl
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

# Create a new PostgreSQL database cluster
subcmd_initdb() {
  initdb "$@"
}

pg_ctl() {
  run_pkg_cmd pg_ctl "$@"
}

# Initialize, start, stop, or control a PostgreSQL server
subcmd_pg_ctl() {
  pg_ctl "$@"
}

for xb037ce6 in psql pg_dump pg_dumpall
do
  require_pkg_cmd \
    --name="$xb037ce6" \
    --brew-id=postgresql@"$ver_5942f2c" \
    --winget-id=PostgreSQL.PostgreSQL."$ver_5942f2c" \
    --deb-id=postgresql-client-"$ver_5942f2c" \
    /usr/local/opt/postgresql@"$ver_5942f2c"/bin/"$xb037ce6" \
    "C:/Program Files/PostgreSQL/$ver_5942f2c/bin/$xb037ce6.exe" \
    /usr/lib/postgresql/"$ver_5942f2c"/bin/"$xb037ce6" \
    #nop
done

psql() {
  run_pkg_cmd psql "$@"
}

# PostgreSQL interactive terminal
subcmd_psql() {
  psql "$@"
}

pg_dump() {
  run_pkg_cmd pg_dump "$@"
}

# Extract a PostgreSQL database into a script file or other archive file
subcmd_pg_dump() {
  pg_dump "$@"
}

pg_dumpall() {
  run_pkg_cmd pg_dumpall "$@"
}

# Extract a PostgreSQL database cluster into a script file
subcmd_pg_dumpall() {
  pg_dumpall "$@"
}
