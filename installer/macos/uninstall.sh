#!/bin/sh
set -eu

install_dir="$HOME/Applications/Tulez.app"
if [ -L "$install_dir" ] || [ ! -d "$install_dir" ]; then
    printf '%s\n' "No ordinary Tulez app bundle was found at $install_dir."
    exit 1
fi
resolved_parent=$(CDPATH= cd -- "$HOME/Applications" && pwd -P)
resolved_app=$(CDPATH= cd -- "$install_dir" && pwd -P)
if [ "$resolved_app" != "$resolved_parent/Tulez.app" ]; then
    printf '%s\n' 'Refusing to remove an app outside the expected Applications directory.'
    exit 1
fi
bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$install_dir/Contents/Info.plist")
if [ "$bundle_id" != 'io.github.tulezready.tulez' ]; then
    printf '%s\n' 'The bundle is not Tulez.'
    exit 1
fi
"$install_dir/Contents/MacOS/Tulez" --uninstall-cleanup
if [ -L "$HOME/.local/bin/tulez" ] && [ "$(readlink "$HOME/.local/bin/tulez")" = "$install_dir/Contents/MacOS/tulez-cli" ]; then
    rm -- "$HOME/.local/bin/tulez"
fi
rm -rf -- "$install_dir"
printf '%s\n' 'Tulez was removed. Your settings and conversion results were kept.'
