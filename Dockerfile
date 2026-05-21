FROM centos:7 AS centos7-base

ARG TARGETPLATFORM

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -eux; \
    case "${TARGETPLATFORM:-linux/amd64}" in \
      "linux/amd64") \
        sed -i \
          -e 's|^mirrorlist=|#mirrorlist=|g' \
          -e 's|^#baseurl=http://mirror.centos.org/centos/$releasever|baseurl=https://mirrors.aliyun.com/centos-vault/7.9.2009|g' \
          /etc/yum.repos.d/CentOS-*.repo \
        ;; \
      "linux/arm64") \
        mkdir -p /etc/yum.repos.d/bk; \
        mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bk; \
        curl -fsSL https://mirrors.aliyun.com/repo/Centos-altarch-7.repo -o /etc/yum.repos.d/CentOS-Base.repo \
        ;; \
      *) \
        echo "Unsupported TARGETPLATFORM=${TARGETPLATFORM}"; \
        exit 1 \
        ;; \
    esac; \
    yum makecache fast; \
    yum install -y \
      ca-certificates \
      curl \
      htop \
      unzip \
      vim \
      which; \
    localedef -c -f UTF-8 -i en_US en_US.UTF-8; \
    yum clean all; \
    rm -rf /var/cache/yum
ENV LC_ALL=en_US.UTF-8

FROM centos7-base AS pixi-bootstrap

ARG PIXI_VERSION=v0.69.0
ARG PIXI_HOME=/root/.pixi
ARG PIXI_GLOBAL_CHANNELS=conda-forge

ENV PIXI_HOME=${PIXI_HOME}
ENV PATH=${PIXI_HOME}/bin:${PATH}

RUN set -eux; \
    export PIXI_VERSION PIXI_HOME PIXI_NO_PATH_UPDATE=1; \
    curl -fsSL https://pixi.sh/install.sh | sh; \
    pixi --version

FROM pixi-bootstrap AS slim

ARG PIXI_GLOBAL_CHANNELS=conda-forge
ARG PIXI_SLIM_SPECS="rattler-build rattler-index"

RUN set -eux; \
    pixi global install -e tools -c "${PIXI_GLOBAL_CHANNELS}" ${PIXI_SLIM_SPECS}; \
    rm -rf /root/.cache "${PIXI_HOME}/cache"

FROM pixi-bootstrap AS normal

ARG PIXI_GLOBAL_CHANNELS=conda-forge
ARG PIXI_NORMAL_SPECS="constructor conda conda-build conda-recipe-manager git rattler-build rattler-index"

RUN set -eux; \
    pixi global install -e tools -c "${PIXI_GLOBAL_CHANNELS}" ${PIXI_NORMAL_SPECS}; \
    rm -rf /root/.cache "${PIXI_HOME}/cache"

FROM pixi-bootstrap AS gui-builder

RUN set -eux; \
    yum makecache fast; \
    yum install -y \
      alsa-lib \
      binutils \
      chrpath \
      coreutils \
      dbus-devel \
      file \
      findutils \
      gtk2-devel \
      help2man \
      libICE-devel \
      libselinux \
      libSM-devel \
      libstdc++-devel \
      libstdc++-static \
      libx11 \
      libX11-devel \
      libXcomposite \
      libXcursor \
      libXdamage \
      libXext \
      libXext-devel \
      libXi \
      libXrender-devel \
      libXScrnSaver \
      libxshmfence-devel \
      libXt-devel \
      libXtst \
      libXxf86vm \
      libXxf86vm-devel \
      m4 \
      make \
      mesa-dri-drivers \
      mesa-libGL \
      mesa-libglapi \
      patch \
      rsync \
      sed \
      texinfo \
      wget \
      xorg-x11-proto-devel \
      xorg-x11-server-Xvfb; \
    yum clean all; \
    rm -rf /var/cache/yum

ARG PIXI_GLOBAL_CHANNELS=conda-forge
ARG PIXI_NORMAL_SPECS="constructor conda conda-build conda-recipe-manager git rattler-build rattler-index"

RUN set -eux; \
    pixi global install -e tools -c "${PIXI_GLOBAL_CHANNELS}" ${PIXI_NORMAL_SPECS}; \
    rm -rf /root/.cache "${PIXI_HOME}/cache"

FROM gui-builder AS gui
