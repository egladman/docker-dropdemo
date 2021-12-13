#!/usr/bin/env bash

set -o pipefail -o errexit

_log() {
    # Usage: _log <prefix> <message>
    #        _log WARN "hello world"

    printf -v now '%(%m-%d-%Y %H:%M:%S)T' -1
    printf '%b\n' "[${1:: 4}] ${now} ${0##*/} ${2}"
}

log::info() {
    _log "INFO" "$*"
}

if [[ $(id -u) -ne 0 ]]; then
    log::info "Not running as root. Skipping..."
    exit 0
fi

chown -R $UID:$GID /example
