FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG CONTAINER_USER=ubuntu
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN : \
  && apt-get clean \
  && apt-get update \
  && apt-get install -y \
    apt-utils \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    apt-transport-https \
    gpg \
    wget \
    cmake \
    make \
    clang \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    libstdc++-12-dev \
    python3 \
    python3-venv \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* \
  && update-alternatives --install /usr/bin/python python /usr/bin/python3 10 \
  && :

# AWS CLI
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates \
    && curl -fsSL https://awscli.amazonaws.com/v2/install.sh \
       | bash -s -- --system \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/flutter
RUN git clone https://github.com/flutter/flutter.git /opt/flutter

ENV PATH="/opt/flutter/bin:${PATH}"

RUN flutter --version \
    && dart --version

RUN flutter config --enable-web \
    && flutter config --enable-linux-desktop \
    && flutter precache --web --linux \
    && flutter --disable-analytics \
    && flutter doctor -v

RUN dart --disable-analytics
    
RUN chown -R ${CONTAINER_USER} /opt/flutter

USER ${CONTAINER_USER}
ENV USER=${CONTAINER_USER}
CMD [ "/bin/bash" ]
