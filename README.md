# WeTTY Docker Image

[![Docker](https://img.shields.io/badge/docker-ghcr.io%2Ffrepke%2Fwetty-blue)](https://ghcr.io/frepke/wetty)
[![Build](https://github.com/frepke/wetty/actions/workflows/docker.yml/badge.svg)](https://github.com/frepke/wetty/actions)

Docker image for **WeTTY**, a browser-based terminal that provides SSH access through a web browser.

This repository builds WeTTY directly from the official upstream project and packages it as a lightweight container image.

Upstream project:
https://github.com/butlerx/wetty

---

## Image

```text
ghcr.io/frepke/wetty:latest
```

---

## Quick start

```bash
docker run -p 3000:3000 ghcr.io/frepke/wetty:latest
```

Open:

```text
http://localhost:3000
```

---

## Example with SSH target

```bash
docker run -d \
  -p 3000:3000 \
  ghcr.io/frepke/wetty:latest \
  --ssh-host=myserver \
  --ssh-user=myuser
```

---

## Reverse proxy example

```bash
docker run -p 3000:3000 ghcr.io/frepke/wetty:latest --base=/wetty
```

Access:

```text
https://example.com/wetty
```

---

## Local build

```bash
git clone https://github.com/frepke/wetty.git
cd wetty
docker build -t wetty .
```

Run:

```bash
docker run -p 3000:3000 wetty
```

---

## How this image is built

The Dockerfile:

1. clones the official **butlerx/wetty** repository
2. installs dependencies using **pnpm**
3. builds the web client
4. copies only the required runtime files into a smaller final image

This repository contains only the Docker build environment, not the WeTTY source code.

---

## Included quality-of-life extras

- OCI image labels for a cleaner GHCR package page
- multi-arch builds for `linux/amd64` and `linux/arm64`
- automatic tagging for `latest`, git tags and commit SHA
- Dependabot config for GitHub Actions updates

---

## License

MIT License.

WeTTY itself is also distributed under the MIT license by its upstream authors.
