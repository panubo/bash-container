FROM docker.io/debian:stretch-slim

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends curl ca-certificates git wget procps shellcheck \
  ;

RUN set -x \
  && GOMPLATE_VERSION=v2.2.0 \
  && GOMPLATE_CHECKSUM=0e09e7cd6fb5e96858255a27080570624f72910e66be5152b77a2fd21d438dd7 \
  && wget -nv -O /tmp/gomplate_linux-amd64-slim -L https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_linux-amd64-slim \
  && echo "${GOMPLATE_CHECKSUM}  gomplate_linux-amd64-slim" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM; ) \
  && mv /tmp/gomplate_linux-amd64-slim /usr/local/bin/gomplate \
  && chmod +x /usr/local/bin/gomplate \
  && rm -f /tmp/* \
  ;

RUN set -x \
  && cd ~ \
  && git clone https://github.com/bats-core/bats-core.git \
  && cd bats-core \
  && ./install.sh /usr/local \
  ;

COPY rendered/panubo-functions.sh /panubo-functions.sh
  