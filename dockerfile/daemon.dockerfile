ARG BUILDPLATFORM=linux/amd64
ARG EMBEDDED_JAVA_VERSION=21

FROM --platform=${BUILDPLATFORM} node:lts-alpine AS builder

WORKDIR /src
COPY . /src

RUN apk add --no-cache wget &&\
    chmod a+x ./install-dependents.sh &&\
    chmod a+x ./build.sh &&\
    ./install-dependents.sh &&\
    ./build.sh &&\
    wget --input-file=lib-urls.txt --directory-prefix=production-code/daemon/lib/ &&\
    chmod a+x production-code/daemon/lib/*

FROM ghcr.io/linuxserver/baseimage-debian:trixie

ARG EMBEDDED_JAVA_VERSION

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    wget \
    apt-transport-https \
    gpg &&\
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash &&\
    wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null &&\
    echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list &&\
    mkdir -p /usr/share/man/man1 &&\
    apt-get update && \
    apt-get install -y --no-install-recommends \
    nodejs \
    temurin-${EMBEDDED_JAVA_VERSION}-jdk && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/production-code/daemon/ /opt/mcsmanager/daemon/

COPY dockerfile/daemon/ /

EXPOSE 24444

ENV MCSM_INSTANCES_BASE_PATH=/opt/mcsmanager/daemon/data/InstanceData

VOLUME ["/opt/mcsmanager/daemon/data", "/opt/mcsmanager/daemon/logs"]
