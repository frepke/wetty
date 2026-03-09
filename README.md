# frepke/wetty

A minimal Docker image repository for WeTTY: clone upstream `butlerx/wetty`, build it with `pnpm`, and run it in a small runtime image.

## What is included

- `Dockerfile` — multi-stage build for WeTTY
- `README.md` — usage notes
- `LICENSE` — MIT license for this repository
- `.github/workflows/docker.yml` — optional GitHub Actions workflow to build and publish to GHCR

## Build locally

```bash
docker build -t frepke/wetty:local .
```

## Run locally

```bash
docker run --rm -p 3000:3000 frepke/wetty:local
```

Then open:

```text
http://localhost:3000
```

## Notes

- This repository does not contain the WeTTY application source itself.
- The image clones the upstream WeTTY repository during the Docker build.

## Optional: publish to GHCR

The included GitHub Actions workflow can publish images to GitHub Container Registry on pushes to `main` and on tags.
