#!/usr/bin/env bash

set -euo pipefail

# Pants uses scie-pants for binary distribution
GH_REPO="https://github.com/pantsbuild/scie-pants"
TOOL_NAME="pants"
# Use update --help command which doesn't require a project configuration
TOOL_TEST="SCIE_BOOT=update pants --help"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//'
}

list_all_versions() {
	list_github_tags
}

calculate_os() {
	local os
	os="$(uname -s)"
	if [[ "${os}" =~ [Ll]inux ]]; then
		echo "linux"
	elif [[ "${os}" =~ [Dd]arwin ]]; then
		echo "macos"
	elif [[ "${os}" =~ [Ww]in|[Mm][Ii][Nn][Gg] ]]; then
		echo "windows"
	else
		fail "Pants is not supported on this operating system (${os})."
	fi
}

calculate_arch() {
	local arch
	arch="$(uname -m)"
	if [[ "${arch}" =~ x86[_-]64 ]]; then
		echo "x86_64"
	elif [[ "${arch}" =~ arm64|aarch64 ]]; then
		echo "aarch64"
	else
		fail "Pants is not supported for this chip architecture (${arch})."
	fi
}

download_release() {
	local version filename url sha256_url
	version="$1"
	filename="$2"

	# Find the latest version if "latest" is specified
	if [ "$version" = "latest" ]; then
		version=$(list_all_versions | sort_versions | tail -n1)
		if [ -z "$version" ]; then
			fail "No releases found for $TOOL_NAME."
		fi
		echo "Using latest version: $version"
	fi

	local os arch
	os="$(calculate_os)"
	arch="$(calculate_arch)"

	# Construct the binary name: scie-pants-{OS}-{ARCH}
	local binary_name="scie-pants-${os}-${arch}"
	url="$GH_REPO/releases/download/v${version}/${binary_name}"
	sha256_url="${url}.sha256"

	# Download with original name for checksum verification
	local download_dir
	download_dir="$(dirname "$filename")"
	local temp_file="${download_dir}/${binary_name}"

	echo "* Downloading $TOOL_NAME release $version for ${os}-${arch}..."
	curl "${curl_opts[@]}" -o "$temp_file" -C - "$url" || fail "Could not download $url"

	# Download and verify SHA256
	local sha256_file="${temp_file}.sha256"
	curl "${curl_opts[@]}" -o "$sha256_file" "$sha256_url" || fail "Could not download $sha256_url"

	# Verify checksum
	echo "* Verifying checksum..."
	(
		cd "$download_dir"
		if command -v sha256sum &>/dev/null; then
			sha256sum -c --status "$(basename "$sha256_file")" || fail "Checksum verification failed"
		elif command -v shasum &>/dev/null; then
			shasum -a 256 -c --status "$(basename "$sha256_file")" || fail "Checksum verification failed"
		else
			fail "Neither sha256sum nor shasum found. Cannot verify checksum."
		fi
	)

	# Rename to final filename after verification
	mv "$temp_file" "$filename"

	# Remove the checksum file
	rm "$sha256_file"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"

		# Copy the pants binary from the download directory
		local binary_path="$ASDF_DOWNLOAD_PATH/$TOOL_NAME"
		cp "$binary_path" "$install_path/$TOOL_NAME"
		chmod +x "$install_path/$TOOL_NAME"

		# Verify the binary is executable
		test -x "$install_path/$TOOL_NAME" || fail "Expected $install_path/$TOOL_NAME to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
