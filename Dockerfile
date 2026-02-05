FROM centos:7

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN curl -fsSL https://pixi.sh/install.sh | sh; \
    printf '\neval "$(pixi completion --shell bash)"\n' >> /root/.bashrc || true; \
    /root/.pixi/bin/pixi global install -e tools rattler-build git; \
    rm -rf /root/.cache

ENV PATH="/root/.pixi/bin:${PATH}"
