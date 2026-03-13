#!/usr/bin/env bash
# vim:sw=4:ts=4:et:

set -euo pipefail

cd "${STAGING_DIR}"

while read -r link; do
    bn=$(basename "$link")
    case "$bn" in
        python|python3)
            dst="/usr/bin/python3"
            echo "relinking $link to $dst"
            rm -f "$link"
            ln -s "$dst" "$link"
            ;;
        xxd)
            dst="/usr/bin/xxd"
            echo "relinking $link to $dst"
            rm -f "$link"
            ln -s "$dst" "$link"
            ;;
        *)
            echo "found broken $link, skipping"
            ;;
    esac
done < <(find host/bin/ -xtype l)
