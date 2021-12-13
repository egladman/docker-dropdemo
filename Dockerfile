ARG REGISTRY=docker.io/
ARG DEBIAN_VERSION=bullseye

FROM ${REGISTRY}bitnami/minideb:${DEBIAN_VERSION}

RUN set -eux; \
    install_packages gosu procps; \
    mkdir /docker-entrypoint.d

COPY /entrypoint/docker-entrypoint.sh /
COPY /entrypoint/10-fix-permissions.sh /docker-entrypoint.d

RUN set -eux; \
    chmod +x /docker-entrypoint.sh /docker-entrypoint.d/*

ENTRYPOINT ["/docker-entrypoint.sh"]