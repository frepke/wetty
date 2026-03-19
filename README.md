# Wetty

Wetty is a terminal in your browser to ssh into your remote servers. The implementation leverages Docker for easier deployment and configuration.

## Docker Example

To run Wetty using Docker, you can use the following command:
```bash
docker run -it --rm -p 3000:3000 \
  -e USER=your-username \
  -e PASSWORD=your-password \
  -e WETTY_REF=your-git-reference \
  wetty/wetty
```

## Docker Compose Example

Using Docker Compose allows for a more structured configuration. Below is an example `docker-compose.yml` file:

```yaml
version: "3"
services:
  wetty:
    image: wetty/wetty
    ports:
      - "3000:3000"
    environment:
      - USER=your-username
      - PASSWORD=your-password
      - WETTY_REF=your-git-reference
    build:
      context: .
      args:
        WETTY_REF: your-git-reference
        
    command: ["sh", "-c", "npm start"]
```

Make sure to replace `your-username`, `your-password`, and `your-git-reference` with your actual values.  

## Behavior
The behavior of Wetty may change based on the Dockerfile updates to ensure it aligns with the latest coding practices and enhancements. Make sure to consult the Dockerfile for any additional configuration parameters needed based on the functionality you wish to enable.
