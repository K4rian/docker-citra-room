# Build the server binary
FROM alpine:latest as builder

RUN apk update \
    && apk -U add --no-cache \
        build-base \
        binutils-gold \
        ca-certificates \
        cmake \
        glslang \
        libstdc++ \
        linux-headers \
        ninja-build \
        openssl-dev \
        wget \
        xz \
    && export PATH=$PATH:/bin:/usr/local/bin:/usr/bin:/sbin:/usr/lib/ninja-build/bin \
    && mkdir -p /server/lib /tmp/citra/build \
    && cd /tmp/citra \
    && wget -c "https://github.com/K4rian/docker-citra-room/releases/download/v0.2798/canary-unified-source-20240304-d996981.tar.xz" -O citra-unified.tar.xz \
    && tar --strip-components=1 -xf citra-unified.tar.xz \
    && cd /tmp/citra/build \
    && { echo "#!/bin/ash"; \
         echo "CFLAGS=\"-ftree-vectorize -flto\""; \
         echo "if [[ \"$(uname -m)\" == \"aarch64\" ]]; then"; \
         echo "  CFLAGS=\"$CFLAGS -march=armv8-a+crc+crypto\""; \
         echo "elif [[ \"$(uname -m)\" == \"x86_64\" ]]; then"; \
         echo "  CFLAGS=\"$CFLAGS -march=core2 -mtune=intel\""; \
         echo "fi"; \
         echo "export CFLAGS"; \
         echo "export CXXFLAGS=\"$CFLAGS\""; \
         echo "export LDFLAGS=\"-flto -fuse-linker-plugin -fuse-ld=gold\""; \
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

# Set-up the server
FROM alpine:latest

ENV USERNAME citra
ENV USERHOME /home/$USERNAME

# Required
ENV CITRA_PORT 24872
ENV CITRA_ROOMNAME "Citra Room"
ENV CITRA_PREFGAME "Any"
ENV CITRA_MAXMEMBERS 4
ENV CITRA_BANLISTFILE "bannedlist.cbl"
ENV CITRA_LOGFILE "citra-room.log"
# Optional
ENV CITRA_ROOMDESC ""
ENV CITRA_PREFGAMEID "0"
ENV CITRA_PASSWORD ""
ENV CITRA_ISPUBLIC 0
ENV CITRA_TOKEN ""
ENV CITRA_WEBAPIURL ""

RUN apk update \
    && adduser --disabled-password $USERNAME \
    && rm -rf /tmp/* /var/tmp/*

COPY --from=builder --chown=$USERNAME /server/ $USERHOME/
COPY --chown=$USERNAME ./container_files/ $USERHOME/

USER $USERNAME
WORKDIR $USERHOME

RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["./docker-entrypoint.sh"]