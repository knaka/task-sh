# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_8219033-false}" && return 0; sourced_8219033=true

. ./task.sh

. ./caddy.lib.sh

test_fetched_caddy() {
  skip_unless_full
  caddy --help
}  

. ./chezmoi.lib.sh

test_fetched_chezmoi() {
  skip_unless_full
  chezmoi --help
}  

. ./sqlc.lib.sh

test_fetched_sqlc() {
  skip_unless_full
  sqlc --help
}  

. ./sqldef.lib.sh

test_fetched_sqlite3def() {
  skip_unless_full
  sqlite3def --help
}  

. ./terraform.lib.sh

test_fetched_terraform() {
  skip_unless_full
  terraform --help
}  

. ./python.lib.sh

test_fetched_uv() {
  skip_unless_full
  uv --help
}  

. ./node.lib.sh

test_fetched_volta() {
  skip_unless_full
  volta --help
}  

. ./yj.lib.sh

test_fetched_yj() {
  skip_unless_full
  yj -h
}  

. ./yq.lib.sh

test_fetched_yq() {
  skip_unless_full
  yq --help
}  
