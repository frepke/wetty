# WeTTY Docker (Hardened & Production-Ready)

This repository provides a **secure, minimal, and production-ready Docker image** for WeTTY.

👉 Upstream project: https://github.com/butlerx/wetty  
👉 This repo is **NOT a fork**, but a Docker packaging layer.

---

## 🚀 Features

- Multi-stage Docker build
- Minimal runtime image (Debian slim)
- Non-root container (UID 10001)
- Reproducible builds (pinned PNPM + optional commit pinning)
- No lifecycle scripts in production
- Optimized for CI/CD usage
- SSH client included

---

## 📦 Usage

### Build
docker build -t wetty .

### Run
docker run -p 3000:3000 wetty

Open:
http://localhost:3000

---

## ⚙️ Configuration

Environment variables supported by WeTTY:

- PORT
- BASE
- SSHHOST
- SSHPORT

Example:
docker run -p 3000:3000 -e SSHHOST=your-server wetty

---

## 🔐 Security

- Runs as non-root user
- No dev dependencies in runtime
- Minimal attack surface
- No lifecycle scripts executed after build

---

## 📜 License

Same as upstream:
https://github.com/butlerx/wetty/blob/main/LICENSE
