ARG IMAGE=ubuntu:bionic

# first image to download qemu and make it executable
FROM alpine AS qemu
ARG QEMU=x86_64
ARG QEMU_VERSION=v2.11.0
ADD https://github.com/multiarch/qemu-user-static/releases/download/${QEMU_VERSION}/qemu-${QEMU}-static /qemu-${QEMU}-static
RUN chmod +x /qemu-${QEMU}-static


FROM ${IMAGE} AS build
ARG QEMU=x86_64
COPY --from=qemu /qemu-${QEMU}-static /usr/bin/qemu-${QEMU}-static
ARG ARCH=amd64
ARG PROMETHEUS_ARCH=amd64
ARG VERSION=master
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
        && apt-get install -q -y software-properties-common \
        && add-apt-repository ppa:bitcoin/bitcoin \
        && apt-get update \
        && apt-get install -q -y build-essential curl libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils libboost-all-dev git  libdb4.8-dev libdb4.8++-dev \
        && apt-get upgrade -q -y \
        && apt-get dist-upgrade -q -y \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* \
        && cd /tmp \
        && git clone --branch ${VERSION} https://github.com/MultiChain/multichain.git \
        && cd multichain \
        && mkdir v8build \
        && cd v8build \
        && curl -sSL -o linux-v8.tar.gz https://github.com/MultiChain/multichain-binaries/raw/master/linux-v8.tar.gz \
        && tar xzf linux-v8.tar.gz \
        && cd .. \
        && ./autogen.sh \
        && ./configure \
        && make \
        && mv src/multichaind src/multichain-cli src/multichain-util /usr/local/bin \
        && rm -Rf /tmp/multichain* \
        && apt-get purge -q -y \
            automake \
            pkg-config \
            bsdmainutils \
            git \
            libboost-all-dev \
            libdb4.8-dev \
            libdb4.8++-dev \
            autotools-dev \
            libssl-dev \
            libevent-dev \
            libtool \
            build-essential \
            software-properties-common

# && apt-get autoremove -y

# Works!

CMD ["/bin/bash"]

LABEL de.uniba.ktr.multicahin.version=$VERSION \
      de.uniba.ktr.multicahin.name="Multichain" \
      de.uniba.ktr.multicahin.docker.cmd="docker run --name=multichain unibaktr/multichain multichain-cli" \
      de.uniba.ktr.multicahin.vendor="Marcel Grossmann" \
      de.uniba.ktr.multicahin.architecture=$ARCH \
      de.uniba.ktr.multicahin.vcs-ref=$VCS_REF \
      de.uniba.ktr.multicahin.vcs-url=$VCS_URL \
      de.uniba.ktr.multicahin.build-date=$BUILD_DATE
