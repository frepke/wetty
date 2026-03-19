# Wetty

Wetty is a terminal in your browser operating over SSH. It provides a rich interactive experience in the cloud.

## Docker Image

### Usage
To run Wetty as a Docker container, you can use the following Docker Compose example:

```yaml
yml
version: '3.8'
services:
  wetty:
    image: frepke/wetty:latest
    environment:
      - WETTY_REF=your-desired-version
    ports:
      - '3000:3000'
    volumes:
      - ./your-local-directory:/home
      - pnpm-cache:/root/.local/share/pnpm-store
    tmpfs:
      - /tmp

volumes:
  pnpm-cache:
```

## Features
- Tracks upstream main by default.
- Supports pinning by WETTY_REF.
- PNPM cache mount for build optimization.
- Runs as a non-root user.
- Exposes port 3000.