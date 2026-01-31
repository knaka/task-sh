# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_8219033-false}" && return 0; sourced_8219033=true

. ./task.sh

. ./caddy.lib.sh
. ./chezmoi.lib.sh
. ./node.lib.sh # volta
. ./python.lib.sh # uv
. ./sqlc.lib.sh
. ./sqldef.lib.sh # sqlite3def
. ./terraform.lib.sh
. ./yj.lib.sh
. ./yq.lib.sh

test_fetched_cmds() {
  skip_unless_full

  caddy --help
  chezmoi --help
  sqlc --help
  sqlite3def --help
  terraform --help
  uv --help
  volta --help
  yj -h
  yq --help
}
