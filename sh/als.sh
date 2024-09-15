#!/bin/sh
set -o nounset -o errexit

if test "${1+SET}" != SET
then
  exit 1
fi

finalize() {
  if test "${tmpdir+SET}" = SET
  then
    rm -fr "$tmpdir"
  fi
}

trap finalize EXIT

file="$1"

case "$file" in
  ftp:* | http:* | https:* )
    # -q: quiet
    # -d: directory
    tmpdir=$(mktemp -qd /tmp/als.XXXXXX)
    curl "$file" --output "$tmpdir/$(basename "$file")" >&2
    file="$tmpdir/$(basename "$file")"
esac

case "$file" in
  *.ama ) appmod arc geo "$file" ;;
  *.a ) ar tv "$file" ;;
  *.tgz | *.tar.gz ) tar ztvf "$file" ;;
  *.cgz | *.cpio.gz ) gzip -d -c "$file" | cpio --list --verbose ;;
  *.cpio ) cpio --list --verbose < "$file" ;;
  *.tbz | tar.bz2 ) tar -t -v -f "$file" --bzip2 ;;
  *.zip | *.ZIP | *.jar | *.xpi | *.egg | *.war | *.crx | *.ipa | *.xlsx | *.sb3 | *.sprite3 ) unzip -l "$file" ;;
  *.tar.lzma ) tar Ytvf "$file" ;;
  *.tar.Z ) tar Ztvf "$file" ;;
  *.tar | *.gem ) tar tvf "$file" ;;
  *.rpm ) rpm2cpio "$file" | cpio --unconditional --list -v ;;
  *.lzh | *.Lzh | *.LZH ) lha l "%s" ;;
  *.msi | *.7z ) 7z l "$file" ;;
  *.rar ) unrar l "$file" ;;
  *.txz | *.tar.xz ) tar Jtvf "$file" ;;
  *.phar ) alsphar "$file" ;;
  * )
    echo Not supported: "$file"
    exit 1
    ;;
esac
