<p align="center">
 <img alt="docker-citra-room logo" src="https://raw.githubusercontent.com/K4rian/docker-citra-room/assets/icons/logo-docker-citra-room.svg" width="25%" align="center">
</p>

A Docker image for the [Citra][1] multiplayer server based on the official [Alpine Linux][2] [image][3].<br>
The server allows you to play many [supported local wireless games][4] via netplay using the [Citra][1] emulator.

---
<div align="center">

Docker Tag  | Version | Platform     | Description
---         | ---     | ---          | ---
[latest][5] | 1.3     | amd64, arm64 | Latest release (Canary 2798)
</div>
<p align="center"><a href="#environment-variables">Environment variables</a> &bull; <a href="#password-protection">Password protection</a> &bull; <a href="#usage">Usage</a> &bull; <a href="#using-compose">Using Compose</a> &bull; <a href="#manual-build">Manual build</a> <!-- &bull; <a href="#see-also">See also</a> --> &bull; <a href="#license">License</a></p>

---
## Environment variables
Some environment variables can be tweaked when creating a container to define the server configuration:

<details>
<summary>Click to expand</summary>

Variable          | Default value  | Description
---               | ---            | ---
CITRA_PORT        | 24872          | Port to listen on (TCP/UDP).
CITRA_ROOMNAME    | Citra Room     | Name of the room.
CITRA_PREFGAME    | Any            | Name of the preferred game.
CITRA_MAXMEMBERS  | 4              | Maximum number of members (2-16).
CITRA_BANLISTFILE | bannedlist.cbl | File which Citra will store ban records in.
CITRA_LOGFILE     | citra-room.log | File path to store the logs.
CITRA_ROOMDESC    |                | (Optional) Description of the room.
CITRA_PREFGAMEID  | 0              | (Optional) Preferred game title identifier. You can find the Title ID with the game list of Citra (right-click on a game -> `Properties`).
CITRA_PASSWORD    |                | (Optional) Room password *(__NOT__ recommended, see the section below)*.
CITRA_ISPUBLIC    | 0              | (Optional) Make the room public. Valid User Token and Web API URL are required.
CITRA_TOKEN       |                | (Optional) The user token to use for the room. Required to make the room public.
CITRA_WEBAPIURL   |                | (Optional) URL to a custom web API. Required to make the room public.

</details>

## Password protection
The server can be protected with a (clear, unencrypted) password by:

— Bind mount a text file containing the password into the container.<br>
The mountpoint path has to be `/run/secrets/citraroom`.<br>
This is the __recommended__ method. See the second example in the section below.

— Using the `CITRA_PASSWORD` environment variable when creating the container.<br>
This method is __NOT__ recommended for production since all environment variables are visible via `docker inspect` to any user that can use the `docker` command. 

## Usage
__Example 1:__<br>
Run a public server for `TLOZ: Triforce Heroes` on port `44872` with a maximum of `12 members`:<br>
— *You need a valid __User Token__ to make the server reachable via the public room browser.*
```bash
docker run -d \
  --name citra-room \
  -p 44872:44872/tcp \
  -p 44872:44872/udp \
  -e CITRA_PORT=44872 \
  -e CITRA_ROOMNAME="USA East - Tri Force Heroes" \
  -e CITRA_ROOMDESC="A room dedicated to TLOZ: Tri Force Heroes" \
  -e CITRA_PREFGAME="Tri Force Heroes" \
  -e CITRA_PREFGAMEID="0004000000177000" \
  -e CITRA_MAXMEMBERS=12 \
  -e CITRA_ISPUBLIC=1 \
  -e CITRA_TOKEN="<USER_TOKEN>" \
  -e CITRA_WEBAPIURL="<CUSTOM_API_URL>" \
  -i k4rian/citra-room
```

__Example 2:__<br>
Run a private password-protected server using default configuration:<br>
— *In this example, the password is stored in the `secret.txt` file located in the current working directory.* 
```bash
docker run -d \
  --name citra-room \
  -p 24872:24872/tcp \
  -p 24872:24872/udp \
  -v "$(pwd)"/secret.txt:/run/secrets/citraroom:ro \
  -i k4rian/citra-room
```

__Example 3:__<br />
Run a password-protected __testing__ server on port `6666`:<br>
```bash
docker run -d \
  --name citra-room-test \
  -p 6666:6666/tcp \
  -p 6666:6666/udp \
  -e CITRA_PORT=6666 \
  -e CITRA_PASSWORD="testing" \
  -i k4rian/citra-room
```

## Using Compose
See [compose/README.md][6]

## Manual build
__Requirements__:<br>
— Docker >= __18.09.0__<br>
— Git *(optional)*

Like any Docker image the building process is pretty straightforward: 

- Clone (or download) the GitHub repository to an empty folder on your local machine:
```bash
git clone https://github.com/K4rian/docker-citra-room.git .
```

- Then run the following command inside the newly created folder:
```bash
docker build --no-cache -t k4rian/citra-room .
```
> The building process can take up to 10 minutes depending on your hardware specs. <br>
> A quad-core CPU with at least 1 GB of RAM and 2 GB of disk space is recommended for the compilation.

<!---
## See also
* __[Citra-Room Egg](https://github.com/K4rian/)__ — A custom egg of Citra-Room for the Pterodactyl Panel.
* __[Citra-Room Template](https://github.com/K4rian/)__ — A custom template of Citra-Room ready to deploy from the Portainer Web UI.
--->

## License
[MIT][7]

[1]: https://web.archive.org/web/20240304214217/https://citra-emu.org/ "Citra Project Website (Archive/March 4, 2024)"
[2]: https://www.alpinelinux.org/ "Alpine Linux Official Website"
[3]: https://hub.docker.com/_/alpine "Alpine Linux Docker Image"
[4]: https://en.wikipedia.org/wiki/List_of_Nintendo_3DS_Wi-Fi_Connection_games "List of 3DS Wi-Fi Connection Games"
[5]: https://github.com/K4rian/docker-citra-room/blob/master/Dockerfile "Latest Dockerfile"
[6]: https://github.com/K4rian/docker-citra-room/tree/master/compose "Compose Files"
[7]: https://github.com/K4rian/docker-citra-room/blob/master/LICENSE