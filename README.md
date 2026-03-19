[![Docker build](https://github.com/frepke/wetty/actions/workflows/docker.yml/badge.svg?branch=main)](https://github.com/frepke/wetty/actions/workflows/docker.yml?query=branch%3Amain)
[![Latest release](https://img.shields.io/github/v/release/frepke/wetty?sort=semver)](https://github.com/frepke/wetty/releases/latest)
[![License](https://img.shields.io/github/license/frepke/wetty)](https://github.com/frepke/wetty/blob/main/LICENSE)
[![GHCR package](https://img.shields.io/badge/GHCR-ghcr.io%2Ffrepke%2Fwetty-blue)](https://github.com/frepke/wetty/pkgs/container/wetty)

# WeTTY Docker (Hardened & Production-Ready)

This repository provides a **secure, minimal, and production-ready Docker image** for WeTTY.

👉 Upstream project: https://github.com/butlerx/wetty  
👉 This repo is **NOT a fork**, but a Docker packaging layer.

---

## 🚀 Features

- Multi-stage Docker build
- Minimal runtime image (Debian slim)
- Non-root container (UID 10001)
- Tracks upstream by default (`WETTY_REF=main`)
- Optional pinning for reproducible builds (use a tag or commit SHA via build arg)
- No dev dependencies in runtime (`pnpm prune --prod`)
- Build-time pnpm cache (BuildKit cache mount) for faster rebuilds
- SSH client included

> Note: builds are only truly reproducible if you pin `WETTY_REF` to a specific tag or commit SHA. Using `main` means you’ll pick up upstream updates on rebuild.

---

## 📦 Usage

### Build
```bash
docker build -t wetty .
```

Pin upstream ref (optional):
```bash
docker build -t wetty --build-arg WETTY_REF=<tag-or-commit-sha> .
```

### Run
```bash
docker run -p 3000:3000 wetty
```

Open:  
http://localhost:3000

---

## 🧩 Docker Compose example

### Option A: Pull prebuilt image (GHCR)

Create `compose.yml`:

```yaml
services:
  wetty:
    image: ghcr.io/frepke/wetty:latest
    container_name: wetty
    security_opt:
      - no-new-privileges:true
    ports:
      - "3000:3000"
    environment:
      - BASE=/
      - SSHHOST=172.17.0.1
      - SSHUSER=root
      - TITLE=WeTTY
    restart: unless-stopped
```

Run:
```bash
docker compose up -d
```

### Option B: Build locally from this repository

Create `compose.yml`:

```yaml
services:
  wetty:
    build:
      context: .
      args:
        WETTY_REF: main   # or pin to tag/commit SHA for reproducible builds
    ports:
      - "3000:3000"
    environment:
      PORT: "3000"
      SSHHOST: "your-server"
      SSHPORT: "22"
      # BASE: "/"
    restart: unless-stopped
```

Run:
```bash
docker compose up --build
```

> This Compose example builds the image locally from this repository (it does not pull a prebuilt image).

---

## ⚙️ Configuration

Environment variables supported by WeTTY (depends on upstream version):

- PORT
- BASE
- SSHHOST
- SSHPORT

Example:
```bash
docker run -p 3000:3000 -e SSHHOST=your-server wetty
```

### Important: WETTY_REF is a build argument
`WETTY_REF` is used during `docker build` (as a **build-arg**), not as a runtime environment variable.

So set it like:
```bash
docker build --build-arg WETTY_REF=main -t wetty .
```

---

## 🔐 Security

- Runs as non-root user
- No dev dependencies in runtime
- Minimal attack surface

---

## 📜 License

Same as upstream:  
https://github.com/butlerx/wetty/blob/main/LICENSE
