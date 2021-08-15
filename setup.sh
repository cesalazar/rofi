#!/usr/bin/env bash

# Install script for rofi themes

# Debug options
# See: https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
# set -euxo pipefail

# Dirs
DIR="$(cd "$(dirname "$0")" || exit 1; pwd -P)"
FONTS_DIR="$HOME/.local/share/fonts"
ROFI_DIR="$HOME/.config/rofi"

# Install Fonts
install_fonts() {
	printf "%s\n" "[*] Installing Fonts..."
	if [[ ! -d "$FONTS_DIR" ]]; then
		mkdir -p "$FONTS_DIR"
	fi
	cp -rf "$DIR"/fonts/* "$FONTS_DIR"

	# Regenerate font cache files
	if [[ $(command -v fc-cache) ]]; then
		fc-cache
	fi
}

# Initialize a repo with the files copied
init_git_repository() {
	# Do not attempt to initialize the repository if git is not configured
	if [[ ! $(git config user.name || git config user.email) ]]; then
		return 1
	fi

	printf "%s\n" "[*] Initializing Repository..."

	cd "$ROFI_DIR" || return 1
	git init -q && git add . && git commit -m "Initial commit" \
		-m "Source: https://github.com/adi1090x/rofi" > /dev/null
}

# Install Themes
install_themes() {
	if [[ -d "$ROFI_DIR" ]]; then
		printf "%s\n" "[*] Creating a backup of your rofi config..."
		mv "$ROFI_DIR" "${ROFI_DIR}.old"
	fi

	mkdir -p "$ROFI_DIR"
	cp -rf "$DIR/$RES"/* "$ROFI_DIR"

	if [[ ! -f "$ROFI_DIR/config.rasi" ]]; then
		printf "%s\n" "[!] Failed to install."
		return 1
	fi

	# Check if git is installed
	[[ $(command -v git) ]] && init_git_repository

	printf "%s\n" "[*] Successfully Installed."
	return 0
}

# Main
main() {
	clear
	cat <<- EOF
		[*] Installing Rofi Themes...

		[*] Choose your screen resolution -
		[1] 1920x1080
		[2] 1366x768

	EOF

	# shellcheck disable=SC2162
	read -p "[?] Select Option: "

	if [[ $REPLY == "1" ]]; then
		RES="1080p"
	elif [[ $REPLY == "2" ]]; then
		RES="720p"
	else
		printf "%s\n" "[!] Invalid Option ($REPLY), type 1 or 2. Exiting."
		exit 1
	fi

	install_fonts
	install_themes

	# Exit code determined by the output of install_themes
	exit $?
}

main

# vim: fdm=manual tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
