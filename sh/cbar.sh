#!/bin/sh
set -o nounset -o errexit

# Clipboard Archiver

if test "${1+SET}" = SET
then
  # 引数が指定されたらそれらをファイル・ディレクトリとしてアーカイブしてテキストにしクリップボードへ
  tar czvf - "$@" | base64 | sh "$(dirname "$0")/"/sc.sh
else
  # 引数が指定されなかったら、クリップボードの内容のテキストをアーカイブとして展開
  sh "$(dirname "$0")"/gc.sh | base64 -d | tar zxvf -
fi
