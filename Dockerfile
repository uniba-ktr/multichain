ARG IMAGE=ubuntu:bionic

FROM ${IMAGE}
MAINTAINER Hendrik Cech <hendrik.cech@gmail.com>

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
        && git clone https://github.com/MultiChain/multichain.git
RUN  cd /tmp/multichain \
        && mkdir v8build \
        && cd v8build \
        && curl -sSL -o linux-v8.tar.gz https://github.com/MultiChain/multichain-binaries/raw/master/linux-v8.tar.gz \
        && tar xzf linux-v8.tar.gz \
        && cd .. \
        && ./autogen.sh \
        && ./configure
RUN make \
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
