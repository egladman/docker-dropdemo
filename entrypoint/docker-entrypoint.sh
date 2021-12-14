#!/usr/bin/env bash

set -o pipefail -o errexit

_log() {
    # Usage: _log <prefix> <message>
    #        _log WARN "hello world"

    printf -v now '%(%m-%d-%Y %H:%M:%S)T' -1
    printf '%b\n' "[${1:: 4}] ${now} ${0##*/} ${2}"
}

log::warn() {
    _log "WARN" "$*"
}

log::info() {
    _log "INFO" "$*"
}

log::debug() {
    [[ "$DEBUG_ENTRYPOINT" == false ]] && return
    _log "DEBUG" "$*"
}

log::error() {
    _log "ERROR" "$*"
}

export GID=${GID:-$UID}
export DEBUG_ENTRYPOINT=${DEBUG_ENTRYPOINT:-false}
export -f _log log::warn log::info log::debug log::error

for f in /docker-entrypoint.d/*.sh; do
    if [[ "${SKIP_ENTRYPOINTD,,}" == true ]]; then
	      log::info "Skipping executables in '/docker-entrypoint.d'"
	      break
    fi

    if [[ -x "$f" ]]; then # It's executable
	      log::info "Executing '${f}'."
	      "$f"
    else
	      log::warn "Ignoring '${f}'. Not executable."
    fi
done

if [[ -z "$1" ]] && [[ -s /var/cache/docker-command ]]; then
    log::debug "No command passed. Reading '/var/cache/docker-command'."
    mapfile -t file_data < /var/cache/docker-command
    set -- "${file_data[@]}"
elif [[ -z "$1" ]]; then
    log::error "No command passed to entrypoint."
    exit 127
fi

# shellcheck disable=SC2145
log::info "Finished configuration. Launching '${@:1:1}'."

if [[ $(id -u) -eq 0 ]] && [[ -n "$UID" ]]; then
    log::info "Running as root. Dropping privileges to uid ${UID}."
    set -- gosu "$UID:$GID" "$@"
fi

exec "$@"
