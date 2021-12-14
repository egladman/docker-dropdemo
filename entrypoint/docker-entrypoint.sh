#!/usr/bin/env bash

set -o pipefail -o errexit

export GID=${GID:-$UID}

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

for f in /docker-entrypoint.d/*.sh; do
    if [[ ${SKIP_ENTRYPOINTD,,} == true ]]; then
	      log::info "Skipping executables in /docker-entrypoint.d"
	      break
    fi

    if [[ -x "$f" ]]; then # It's executable
	      log::info "Executing '${f}'"
	      "$f"
    else
	      log::warn "Ignoring '${f}'. Not executable."
    fi
done

log::info "Finished configuration. Launching ${@::1}"

if [[ $(id -u) -eq 0 ]] && [[ -n "$UID" ]]; then
    log::info "Running as root. Dropping privileges to uid ${UID}."
    set -- gosu $UID:$GID "$@"
fi

exec "$@"
