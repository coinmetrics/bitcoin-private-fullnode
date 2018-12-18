FROM ubuntu:18.04 as builder

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		autoconf \
		automake \
		bsdmainutils \
		build-essential \
		ca-certificates \
		g++-multilib \
		git \
		libc6-dev \
		libtool \
		m4 \
		ncurses-dev \
		pkg-config \
		python \
		unzip \
		wget \
		zlib1g-dev \
	; \
	rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 -s /bin/bash builder
USER builder
WORKDIR /home/builder

ARG VERSION

RUN git clone --depth=1 --branch=${VERSION} https://github.com/BTCPrivate/BitcoinPrivate.git

RUN set -ex; \
	cd BitcoinPrivate; \
	./btcputil/build.sh -j$(nproc)


FROM ubuntu:18.04

COPY --from=builder /home/builder/prefix/btcpd /home/builder/BitcoinPrivate/btcputil/fetch-params.sh /usr/bin/

RUN useradd -m -u 1000 -s /bin/bash runner
USER runner

RUN fetch-params.sh

ENTRYPOINT ["btcpd"]
