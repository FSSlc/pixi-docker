# pixi-docker

CentOS 7 based Pixi images for maintaining legacy build environments.

## Image targets

- `slim`: minimal Pixi tooling, includes `rattler-build` and `rattler-index`
- `normal`: adds `git`, `conda`, `conda-build`, `conda-recipe-manager`, `constructor`
- `gui`: extends `normal` with GUI and X11 related build dependencies

All images are built from the same multi-stage `Dockerfile` and published to `ghcr.io/fsslc/pixi`.

## Pixi version tracking

The tracked Pixi release is stored in `.pixi-version`, and the Dockerfile default `ARG PIXI_VERSION` is kept in sync with it.

The workflow `.github/workflows/update-pixi-version.yaml` checks the latest GitHub release from `prefix-dev/pixi` every 6 hours. When the upstream tag changes, it updates `.pixi-version`, commits the change to `main`, and dispatches the image build workflow automatically.

## Published tags

- `latest`: `normal` target
- `slim`: `slim` target
- `gui`: `gui` target
- `latest-<sha>`, `slim-<sha>`, `gui-<sha>`: commit-based tags for traceability
- `vX.Y.Z`, `vX.Y.Z-slim`, `vX.Y.Z-gui`: tag-based release images

## Local build examples

```bash
docker build --target slim -t local/pixi:slim .
docker build --target normal -t local/pixi:latest .
docker build --target gui -t local/pixi:gui .
```

You can override the Pixi installer version at build time:

```bash
docker build --target normal --build-arg PIXI_VERSION=v0.59.0 -t local/pixi:latest .
```
