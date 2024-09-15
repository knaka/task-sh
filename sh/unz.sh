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
  *.ama ) appmod arc extract "$file" ;;
  *.a ) ar xv "$file" ;;
  *.tgz | *.tar.gz ) tar zxvf "$file" ;;
  *.cgz | *.cpio.gz ) gzip -d -c "$file" | cpio --extract --make-directories --verbose ;;
  *.cpio ) cpio --extract --make-directories --verbose < "$file" ;;
  *.tbz | tar.bz2 ) tar -x -v -f "$file" --bzip2 ;;
  *.zip | *.ZIP | *.jar | *.xpi | *.egg | *.war | *.crx | *.ipa | *.xlsx | *.sb3 | *.sprite3 ) unzip "$file" ;;
  *.tar.lzma ) tar Yxvf "$file" ;;
  *.tar.Z ) tar Ztvf "$file" ;;
  *.tar | *.gem ) tar xvf "$file" ;;
  *.rpm ) rpm2cpio "$file" | cpio --unconditional --extract --make-directories -v ;;
  *.lzh | *.Lzh | *.LZH ) lha x "%s" ;;
  *.msi | *.7z ) 7z x "$file" ;;
  *.rar ) unrar x "$file" ;;
  *.txz | *.tar.xz ) tar Jxvf "$file" ;;
  *.phar ) unzphar "$file" ;;
  * )
    echo Not supported: "$file"
    exit 1
    ;;
esac
