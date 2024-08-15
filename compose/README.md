Citra Multiplayer Dedicated Lobby using Docker Compose
=====
This example defines a basic set up for a Citra Multiplayer Dedicated Lobby using Docker Compose. 

## Project structure
```shell
.
├── docker-compose.yml
├── citra-room.env
├── secret.txt
└── README.md
```

## [Compose file](docker-compose.yml)
```yaml
services:
  citra-room:
    image: k4rian/citra-room:latest
    container_name: citra-room
    hostname: citra-room
    volumes:
      - data:/home/citra
      - /etc/localtime:/etc/localtime:ro
    env_file:
      - citra-room.env
    secrets:
      - citraroom
    ports:
      - 24872:24872/tcp
      - 24872:24872/udp
    restart: unless-stopped

volumes:
  data:

secrets:
  citraroom:
    file: ./secret.txt
```

* The environment file *[citra-room.env](citra-room.env)* holds the server environment variables.

* The server password is defined in the *[secret.txt](secret.txt)* file.<br>
Compose will mount it to `/run/secrets/citraroom` within the container.

* The secret name must be `citraroom`.  

* To make the server public, omit the `secrets` definitions in the Compose file.

## Deployment
```bash
docker compose -p citra-room up -d
```
> The project is using a volume in order to store the server data that can be recovered if the container is removed and restarted.

## Expected result
Check that the container is running properly:
```bash
docker ps | grep "citra"
```

To see the server log output:
```bash
docker compose -p citra-room logs
```

## Stop the container
Stop and remove the container:
```bash
docker compose -p citra-room down
```

Both the container and its volume can be removed by providing the `-v` argument:
```bash
docker compose -p citra-room down -v
```