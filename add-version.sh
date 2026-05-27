#!/bin/bash

#
# Copyright contributors to the Galasa project
#
# SPDX-License-Identifier: EPL-2.0
#

# This script downloads the Windows galasactl binary from GitHub releases,
# calculates the SHA-256 hash, and creates/updates Scoop manifest files.
# This matches the workflow used for Homebrew tap updates.

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUCKET_DIR="${SCRIPT_DIR}/bucket"

#-----------------------------------------------------------------------------------------
# Set Colors
#-----------------------------------------------------------------------------------------
bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 76)
white=$(tput setaf 7)
blue=$(tput setaf 25)

#-----------------------------------------------------------------------------------------
# Headers and Logging
#-----------------------------------------------------------------------------------------
h1() { printf "\n${underline}${bold}${blue}%s${reset}\n" "$@" ;}
h2() { printf "\n${underline}${bold}${white}%s${reset}\n" "$@" ;}
info() { printf "${white}➜ %s${reset}\n" "$@" ;}
success() { printf "${green}✔ %s${reset}\n" "$@" ;}
error() { printf "${red}✖ %s${reset}\n" "$@" ;}

#-----------------------------------------------------------------------------------------
# Functions
#-----------------------------------------------------------------------------------------
function usage {
    info "Syntax: add-version.sh [OPTIONS]"
    cat << EOF
Options are:
-v | --version {version}: For example 0.48.0. The version to download and process.
-h | --help : Display this help text.
EOF
}

function check_exit_code () {
    if [[ "$1" != "0" ]]; then 
        error "$2" 
        exit 1  
    fi
}

function download_executable() {
    url_to_download_from=$1
    download_target_file_path=$2
    h2 "Downloading from $url_to_download_from"
    response_code=$(curl -L --silent --write-out '%{response_code}' -o $download_target_file_path $url_to_download_from)
    if [[ "$response_code" != "200" ]]; then 
        error "Failed to download version $version_to_add from url $url_to_download_from. Response code: $response_code" 
        exit 1 
    fi
    success "Downloaded OK."
}

function create_versioned_manifest() {
    hash=$1
    manifest_file_path="$BUCKET_DIR/galasactl@${version_to_add}.json"
    h2 "Creating versioned manifest file $manifest_file_path"

    cat << EOF > $manifest_file_path
{
  "version": "$version_to_add",
  "description": "Galasa CLI tool for managing and running Galasa tests. Version $version_to_add",
  "homepage": "https://galasa.dev",
  "license": "EPL-2.0",
  "architecture": {
    "64bit": {
      "url": "https://github.com/galasa-dev/galasa/releases/download/v$version_to_add/galasactl-windows-x86_64.exe",
      "hash": "$hash",
      "bin": [
        [
          "galasactl-windows-x86_64.exe",
          "galasactl"
        ]
      ]
    }
  },
  "checkver": {
    "github": "https://github.com/galasa-dev/galasa"
  },
  "autoupdate": {
    "architecture": {
      "64bit": {
        "url": "https://github.com/galasa-dev/galasa/releases/download/v\$version/galasactl-windows-x86_64.exe"
      }
    }
  }
}
EOF

    check_exit_code $? "Failed to create the versioned manifest file $manifest_file_path"
    success "Versioned manifest file created OK."
}

function update_latest_manifest() {
    hash=$1
    manifest_file_path="$BUCKET_DIR/galasactl.json"
    h2 "Updating latest-version manifest file $manifest_file_path"

    cat << EOF > $manifest_file_path
{
  "version": "$version_to_add",
  "description": "Galasa CLI tool for managing and running Galasa tests. Latest version",
  "homepage": "https://galasa.dev",
  "license": "EPL-2.0",
  "architecture": {
    "64bit": {
      "url": "https://github.com/galasa-dev/galasa/releases/download/v$version_to_add/galasactl-windows-x86_64.exe",
      "hash": "$hash",
      "bin": [
        [
          "galasactl-windows-x86_64.exe",
          "galasactl"
        ]
      ]
    }
  },
  "checkver": {
    "github": "https://github.com/galasa-dev/galasa"
  },
  "autoupdate": {
    "architecture": {
      "64bit": {
        "url": "https://github.com/galasa-dev/galasa/releases/download/v\$version/galasactl-windows-x86_64.exe"
      }
    }
  }
}
EOF

    check_exit_code $? "Failed to update the latest manifest file $manifest_file_path"
    success "Latest manifest file updated OK."
}

#-----------------------------------------------------------------------------------------
# Process parameters
#-----------------------------------------------------------------------------------------
version_to_add=""
while [ "$1" != "" ]; do
    case $1 in
        -v | --version )        shift
                                version_to_add="$1"
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     error "Unexpected argument $1"
                                usage
                                exit 1
    esac
    shift
done

if [[ "${version_to_add}" == "" ]]; then
    error "Need to use the --version {version} parameter."
    usage
    exit 1
fi

h1 "Adding version $version_to_add"

# Create temp directory
mkdir -p "${SCRIPT_DIR}/temp"
check_exit_code $? "Couldn't create temporary folder"

# Download the Windows binary from GitHub releases
url_to_download_from="https://github.com/galasa-dev/galasa/releases/download/v${version_to_add}/galasactl-windows-x86_64.exe"
target_file_path="${SCRIPT_DIR}/temp/galasactl-windows-x86_64.exe"

download_executable "$url_to_download_from" "$target_file_path"

# Calculate SHA-256 hash
h2 "Calculating SHA-256 hash..."
if command -v sha256sum &> /dev/null; then
    # Linux
    hash=$(sha256sum "$target_file_path" | cut -f1 -d' ')
elif command -v shasum &> /dev/null; then
    # macOS
    hash=$(shasum --algorithm 256 "$target_file_path" | cut -f1 -d' ')
else
    error "Neither sha256sum nor shasum command found"
    exit 1
fi

info "SHA-256 hash is $hash"

# Create versioned manifest
create_versioned_manifest "$hash"

# Update latest manifest
update_latest_manifest "$hash"

success "All done OK."
success "  Versioned manifest: ${BUCKET_DIR}/galasactl@${version_to_add}.json"
success "  Latest manifest: ${BUCKET_DIR}/galasactl.json"
success "  Version: ${version_to_add}"
success "  Hash: ${hash}"

# Made with Bob
