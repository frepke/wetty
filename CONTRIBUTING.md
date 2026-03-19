# Contributing

Thanks for considering a contribution!

## What this repo is (and isn’t)

This repository is a **Docker packaging layer** for the upstream WeTTY project:
- Upstream: https://github.com/butlerx/wetty

Please avoid changes that belong upstream (feature requests/bugs in WeTTY itself).

## How to contribute

### Issues
When opening an issue, please include:
- what you expected vs what happened
- the exact image tag (e.g. `ghcr.io/frepke/wetty:v0.1.0`)
- your host OS + Docker/Compose version
- logs (redact secrets)

### Pull Requests
PRs are welcome for:
- Dockerfile hardening and best practices
- build performance improvements
- documentation improvements (README)
- CI workflow improvements

Please ensure:
- `docker build .` succeeds locally
- README examples remain valid
- changes are kept minimal and focused

## Versioning / Releases

Releases use tags: `vMAJOR.MINOR.PATCH` (e.g. `v0.1.1`).
Tag pushes trigger a GHCR build for the matching image tag.