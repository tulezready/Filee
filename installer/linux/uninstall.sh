#!/bin/sh
set -eu

data_dir=${XDG_DATA_HOME:-"$HOME/.local/share"}
install_dir="$data_dir/tulez/application"
desktop_file="$data_dir/applications/io.github.tulezready.tulez.desktop"
gnome_extension_id="tulez-donut@tulezready.github.io"
gnome_extension_dir="$data_dir/gnome-shell/extensions/$gnome_extension_id"
python3 - "$data_dir" "$install_dir" <<'PY'
import pathlib
import sys

root, target = map(pathlib.Path, sys.argv[1:])
expected = root.resolve() / 'tulez' / 'application'
if target.is_symlink() or target.resolve() != expected:
    raise SystemExit('Refusing to remove an installation outside its expected directory.')
if (target / '.tulez-package').read_text(encoding='utf-8').strip() != 'io.github.tulezready.tulez':
    raise SystemExit('The directory is not an installation created by Tulez.')
PY
"$install_dir/Tulez" --uninstall-cleanup
if [ -f "$gnome_extension_dir/.tulez-package" ] && [ "$(cat "$gnome_extension_dir/.tulez-package")" = 'io.github.tulezready.tulez' ]; then
    if command -v gnome-extensions >/dev/null 2>&1; then
        gnome-extensions disable "$gnome_extension_id" >/dev/null 2>&1 || true
    fi
    rm -rf -- "$gnome_extension_dir"
fi
if [ -L "$HOME/.local/bin/tulez" ] && [ "$(readlink "$HOME/.local/bin/tulez")" = "$install_dir/tulez-cli" ]; then
    rm -- "$HOME/.local/bin/tulez"
fi
if [ -f "$desktop_file" ] && grep -q '^X-Tulez-Managed=true$' "$desktop_file"; then
    rm -- "$desktop_file"
fi
rm -rf -- "$install_dir"
printf '%s\n' 'Tulez was removed. Your settings and conversion results were kept.'
