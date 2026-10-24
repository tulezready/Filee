#!/bin/sh
set -eu

source_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
install_dir="$HOME/Applications/Tulez.app"
bin_dir="$HOME/.local/bin"
if [ -e "$install_dir" ] || [ -L "$install_dir" ]; then
    printf '%s\n' "An installation already exists at $install_dir. Run uninstall.sh first."
    exit 1
fi
# A filee link left by an earlier Filee whose app is gone (moved to the Trash instead of uninstall.sh) is replaced.
# Anything else at that path isn't ours and stays.
stale_link=false
if [ -L "$bin_dir/tulez" ] && [ ! -e "$bin_dir/tulez" ]; then
    case $(readlink "$bin_dir/tulez") in
        */Filee.app/Contents/MacOS/filee-cli) stale_link=true ;;
    esac
fi
if [ "$stale_link" = false ] && { [ -e "$bin_dir/tulez" ] || [ -L "$bin_dir/tulez" ]; }; then
    printf '%s\n' "$bin_dir/tulez already exists. Remove or rename it before installing Tulez."
    exit 1
fi
test -x "$source_dir/Tulez.app/Contents/MacOS/Tulez"
mkdir -p "$HOME/Applications" "$bin_dir"
/usr/bin/ditto "$source_dir/Tulez.app" "$install_dir"
# ditto keeps the download's quarantine flag: macOS would then start Filee from a translocated copy and could stop
# the filee command without a word (#316).
/usr/bin/xattr -dr com.apple.quarantine "$install_dir" 2>/dev/null || true
if [ "$stale_link" = true ]; then
    rm -f -- "$bin_dir/tulez"
    printf '%s\n' "Replaced the tulez link left by an earlier installation."
fi
ln -s "$install_dir/Contents/MacOS/tulez-cli" "$bin_dir/tulez"
printf '%s\n' "Installed $install_dir" "CLI: $bin_dir/tulez (add $bin_dir to PATH if needed)."
printf '%s\n' 'Open Tulez from Applications. Grant Accessibility and Finder Automation access when requested.'
printf '%s\n' 'If Tulez is already listed and switched on under Accessibility, remove it with the - button and add it again with +.'
