# Wetty

Wetty is a terminal in your browser. It uses WebSockets to communicate with a backend terminal and allows you to run terminal applications in your web browser.

## Getting Started

### Prerequisites

* Docker
* Docker Compose

### Running Wetty

You can run Wetty using Docker Compose. Here is a sample `docker-compose.yml` file:

```yaml
version: '3'
services:
  web:
    image: wetty
    command: /bin/sh -c "while true; do sleep 30; done;"
    ports:
      - '3000:3000'
```

### Commands

To start Wetty, use the following command:

```bash
docker-compose up --build
```

> This Compose example builds the image locally from this repository (it does not pull a prebuilt image).

### Accessing Wetty

Open your web browser and navigate to `http://localhost:3000/` to access Wetty.