#!/usr/bin/env bash

set -o pipefail -o errexit

if [[ $(id -u) -ne 0 ]]; then
    log::debug "Not running as root. Skipping..."
    exit 0
fi

log::info "Changing ownership for directory '/example'."
chown -R "$UID:$GID" /example
