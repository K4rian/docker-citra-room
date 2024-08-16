FROM alpine:3.20 AS builder

WORKDIR /tmp/citra

RUN apk update \
    && apk -U add --no-cache \
        build-base=0.5-r3 \
        binutils-gold=2.42-r0 \
        ca-certificates=20240705-r0 \
        cmake=3.29.3-r0 \
        glslang=1.3.261.1-r0 \
        libstdc++=13.2.1_git20240309-r0 \
        linux-headers=6.6-r0 \
        ninja-build=1.12.1-r0 \
        openssl-dev=3.3.1-r3 \
        wget=1.24.5-r0 \
        xz=5.6.2-r0 \
    && export PATH=$PATH:/bin:/usr/local/bin:/usr/bin:/sbin:/usr/lib/ninja-build/bin \
    && mkdir -p /server/lib /tmp/citra/build \
    && wget --show-progress -q -c -O "citra-unified.tar.xz" "https://github.com/K4rian/docker-citra-room/releases/download/v0.2798/canary-unified-source-20240304-d996981.tar.xz" \
    && tar --strip-components=1 -xf citra-unified.tar.xz \
    && { echo "#!/bin/ash"; \
         echo "SCRIPT_DIR=\$(dirname \"\$(readlink -f \"\$0\")\")"; \
         echo "cd \$SCRIPT_DIR"; \
         echo "LDFLAGS=\"-flto -fuse-linker-plugin -fuse-ld=gold\""; \
         echo "CFLAGS=\"-ftree-vectorize -flto\""; \
         echo "if [[ \"$(uname -m)\" == \"aarch64\" ]]; then"; \
         echo "  CFLAGS=\"-O2\""; \
         echo "  LDFLAGS=\"\""; \
         echo "elif [[ \"$(uname -m)\" == \"x86_64\" ]]; then"; \
         echo "  CFLAGS=\"$CFLAGS -march=core2 -mtune=intel\""; \
         echo "fi"; \
         echo "export CFLAGS"; \
         echo "export CXXFLAGS=\"$CFLAGS\""; \
         echo "export LDFLAGS"; \
         echo "cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release \\"; \
         echo " -DENABLE_SDL2=OFF -DENABLE_QT=OFF -DENABLE_COMPATIBILITY_LIST_DOWNLOAD=OFF \\"; \
         echo " -DUSE_DISCORD_PRESENCE=OFF -DENABLE_FFMPEG_VIDEO_DUMPER=OFF -DUSE_SYSTEM_OPENSSL=ON \\"; \
         echo " -DCITRA_WARNINGS_AS_ERRORS=OFF -DENABLE_LTO=ON"; \
         echo "ninja citra-room "; \
       } >/tmp/citra/build/build.sh \
    && chmod +x /tmp/citra/build/build.sh \
    && /tmp/citra/build/build.sh \
    && cp /tmp/citra/build/bin/Release/citra-room /server/citra-room \
    && strip /server/citra-room \
    && chmod +x /server/citra-room \
    && cp /usr/lib/libgcc_s.so.1 /server/lib/libgcc_s.so.1 \
    && cp /usr/lib/libstdc++.so.6 /server/lib/libstdc++.so.6 \
    && echo -e "CitraRoom-BanList-1" > /server/bannedlist.cbl \
    && touch /server/citra-room.log \
    && rm -R /tmp/citra

FROM alpine:3.20

ENV USERNAME=citra
ENV USERHOME=/home/$USERNAME

# Required
ENV CITRA_PORT=24872
ENV CITRA_ROOMNAME="Citra Room"
ENV CITRA_PREFGAME="Any"
ENV CITRA_MAXMEMBERS=4
ENV CITRA_BANLISTFILE="bannedlist.cbl"
ENV CITRA_LOGFILE="citra-room.log"
# Optional
ENV CITRA_ROOMDESC=""
ENV CITRA_PREFGAMEID="0"
ENV CITRA_PASSWORD=""
ENV CITRA_ISPUBLIC=0
ENV CITRA_TOKEN=""
ENV CITRA_WEBAPIURL=""

RUN apk update \
    && adduser --disabled-password $USERNAME \
    && rm -rf /tmp/* /var/tmp/*

COPY --from=builder --chown=$USERNAME /server/ $USERHOME/
COPY --chown=$USERNAME ./container_files/ $USERHOME/

USER $USERNAME
WORKDIR $USERHOME

RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]