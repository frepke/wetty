# Wetty Docker Image

![Build](https://github.com/frepke/wetty/actions/workflows/docker-build.yml/badge.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/frepke/wetty)
![License](https://img.shields.io/github/license/frepke/wetty)

Docker image for **WeTTY (Web + TTY)** built from the latest upstream source.

This repository automatically builds a container image using GitHub Actions and publishes it to **GitHub Container Registry**.

## What is WeTTY

WeTTY is a web-based terminal that allows you to access a system shell through a browser using SSH.

Project homepage: https://github.com/butlerx/wetty

## Container Image

The image is available at:

```
ghcr.io/frepke/wetty:latest
```

## Quick Start (Docker)

Run the container directly:

```
docker run -d \
  -p 3000:3000 \
  -e SSHHOST=host.docker.internal \
  -e SSHUSER=root \
  ghcr.io/<your-username>/wetty:latest
```

Then open:

```
http://localhost:3000
```

## Docker Compose Example

```
services:
  wetty:
    image: ghcr.io/<your-username>/wetty:latest
    container_name: wetty
    ports:
      - "14830:3000"
    environment:
      SSHHOST: 172.17.0.1
      SSHUSER: root
      BASE: /
      TITLE: WeTTY
    restart: unless-stopped
```

Access via:

```
http://<server-ip>:14830
```

## Environment Variables

| Variable | Description            |
| -------- | ---------------------- |
| SSHHOST  | SSH host to connect to |
| SSHUSER  | Default SSH username   |
| BASE     | Base URL path          |
| TITLE    | Page title             |

## Building Locally

```
git clone https://github.com/<your-username>/wetty-docker.git
cd wetty-docker
docker build -t wetty .
```

Run:

```
docker run -p 3000:3000 wetty
```

## CI / Image Build

Images are built automatically using **GitHub Actions** and pushed to:

GitHub Container Registry (GHCR).

## Disclaimer

This repository only provides a container build for WeTTY and is not affiliated with the upstream project.
