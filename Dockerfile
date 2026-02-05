FROM centos:7

# buildx 会注入 TARGETPLATFORM，形式例如: "linux/amd64" 或 "linux/arm64"
ARG TARGETPLATFORM

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -eux; \
    case "$TARGETPLATFORM" in \
      "linux/amd64") \
        sed -i -e "s|^mirrorlist=|#mirrorlist=|g" \
               -e "s|^#baseurl=http://mirror.centos.org/centos/\\$releasever|baseurl=https://mirrors.aliyun.com/centos-vault/7.9.2009|g" /etc/yum.repos.d/CentOS-*.repo;; \
      "linux/arm64") \
        mkdir -p /etc/yum.repos.d/bk && \
        mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bk && \
        curl -fsSL http://mirrors.aliyun.com/repo/Centos-altarch-7.repo -o /etc/yum.repos.d/CentOS-Base.repo;; \
      *) \
        echo "Unsupported TARGETPLATFORM=$TARGETPLATFORM"; exit 1;; \
    esac; \
    # 通用后续步骤：安装 pixi 并用其二进制路径直接调用，避免依赖于 shell session 的 source
    curl -fsSL https://pixi.sh/install.sh | sh; \
    printf '\neval "$(pixi completion --shell bash)"\n' >> /root/.bashrc || true; \
    # 直接用安装到 /root/.pixi/bin 的二进制执行，确保在同一 RUN 中可用
    /root/.pixi/bin/pixi global install -e tools rattler-build git; \
    rm -rf /root/.cache

ENV PATH="/root/.pixi/bin:${PATH}"
