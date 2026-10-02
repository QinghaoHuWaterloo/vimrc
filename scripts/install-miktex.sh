#!/usr/bin/env bash
# Official Fedora 44 packages; user-private TeX tree, no global PATH changes.
set -euo pipefail
[[ $(. /etc/os-release; printf '%s' "$VERSION_ID") == 44 ]] || { echo 'Requires Fedora 44'; exit 1; }
if ! rpm -q miktex >/dev/null 2>&1; then
  sudo rpm --import https://miktex.org/download/key
  sudo curl -fL -o /etc/yum.repos.d/miktex.repo https://miktex.org/download/fedora/44/miktex.repo
  sudo dnf install -y miktex
fi
miktex_links="${MIKTEX_BIN:-$HOME/.local/lib/miktex/bin}"
/usr/bin/miktexsetup --shared=no --modify-path=no --user-link-target-directory="$miktex_links" finish
# Repair links created in ~/bin by the earlier version of this script.
# Archive matching generated links and identical generated utility executables.
if [[ "$miktex_links" != "$HOME/bin" ]]; then
  for generated in "$miktex_links"/*; do
    previous="$HOME/bin/${generated##*/}"
    matching=false
    if [[ -L "$generated" && -L "$previous" ]] && [[ $(readlink "$generated") == $(readlink "$previous") ]]; then
      matching=true
    elif [[ -f "$generated" && ! -L "$generated" && -f "$previous" && ! -L "$previous" ]] && cmp -s -- "$generated" "$previous"; then
      matching=true
    fi
    if "$matching"; then
      backup="$HOME/.local/lib/miktex/previous-bin-links"
      mkdir -p "$backup"
      mv --backup=numbered -- "$previous" "$backup/"
    fi
  done
fi
/usr/bin/initexmf --set-config-value='[MPM]AutoInstall=1'
if [[ -n ${MIKTEX_REPOSITORY:-} ]]; then
  /usr/bin/mpm --set-repository="$MIKTEX_REPOSITORY"
fi
/usr/bin/miktex packages update-package-database
"$miktex_links/lualatex" --version
# Keep TeX Live: Markdown's external md2pdf workflow still uses it.
