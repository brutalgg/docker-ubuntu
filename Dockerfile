FROM --platform=linux/amd64 ubuntu:22.04 as s6-builder
ENV DEBIAN_FRONTEND="noninteractive"

ARG S6_OVERLAY_VERSION=v3.1.2.1 
ARG S6_OVERLAY_ARCH=x86_64

ADD ["https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz", "/tmp"]
RUN apt-get update && apt-get install -y xz-utils && mkdir -p /tmp/s6
RUN tar xf /tmp/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz -C /tmp/s6

FROM --platform=linux/amd64 ubuntu:22.04

LABEL maintainer="brutalgg"
ENV DEBIAN_FRONTEND="noninteractive" 
ENV LANGUAGE="C.UTF-8" 
ENV LANG="C.UTF-8" 
ENV LC_ALL="C.UTF-8" 
ENV TZ="America/New_York" 
ENV TERM="xterm"

COPY --from=s6-builder /tmp/s6 /

RUN \
  # Update and get dependencies
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y \
  locales \
  tzdata \
  && \
  # Add user
  echo "**** create abc user and make folders ****" && \
  useradd -u 911 -U -d /config -s /bin/false abc && \
  usermod -G users abc && \
  mkdir -p \
  /app \
  /config \
  /defaults && \
  # Generate locale
  echo "**** generate locale ****" && \
  locale-gen en_US.UTF-8 && \
  # Cleanup
  echo "**** cleanup ****" && \
  apt-get -y autoremove && \
  apt-get -y clean && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/* && \
  rm -rf /var/tmp/*

COPY root/ /

ENTRYPOINT ["/init"]