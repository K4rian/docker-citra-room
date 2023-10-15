#!/bin/ash
# Citra Multiplayer Dedicated Lobby Startup Script
#
# Server Files: /home/citra

export LD_LIBRARY_PATH=$HOME/lib:$LD_LIBRARY_PATH

clear

s_command="
$HOME/citra-room \
--port ${CITRA_PORT} \
--room-name \"${CITRA_ROOMNAME}\" \
--preferred-game \"${CITRA_PREFGAME}\" \
--max_members ${CITRA_MAXMEMBERS} \
--ban-list-file \"$CITRA_BANLISTFILE\" \
--log-file \"${CITRA_LOGFILE}\""
s_password="${CITRA_PASSWORD}"

add_optional_arg() {
  while [[ "$#" -gt 0 ]]; do
    s_command="$s_command $1"
    shift
  done
}

if [ ! "x$CITRA_ROOMDESC" = "x" ]; then
  add_optional_arg "--room-description" "\"${CITRA_ROOMDESC}\""
fi

if [ ! "x$CITRA_PREFGAMEID" = "x" ]; then
  add_optional_arg "--preferred-game-id" "\"${CITRA_PREFGAMEID}\""
fi

if [ "x$s_password" = "x" ] \
  && [ -f "/run/secrets/citraroom" ]; then
  s_password=$(cat "/run/secrets/citraroom")
fi

if [ ! "x$s_password" = "x" ]; then
  add_optional_arg "--password" "\"${s_password}\""
fi

if [ ! "x$CITRA_ISPUBLIC" = "x" ] \
 && [ $CITRA_ISPUBLIC = 1 ]; then
  if [ ! "x$CITRA_TOKEN" = "x" ]; then
    add_optional_arg "--token" "\"${CITRA_TOKEN}\""
  fi

  if [ ! "x$CITRA_WEBAPIURL" = "x" ]; then
    add_optional_arg "--web-api-url" "\"${CITRA_WEBAPIURL}\""
  fi

  if [ ! "x$CITRA_ENABLEMODS" = "x" ] \
   && [ $CITRA_ENABLEMODS = 1 ]; then
    add_optional_arg "--enable-citra-mods"
  fi
fi

echo "░█▀▀░▀█▀░▀█▀░█▀▄░█▀█░░░█▀▄░█▀▀░█▀▄░▀█▀░█▀▀░█▀█░▀█▀░█▀▀░█▀▄░░░█▀▄░█▀█░█▀█░█▄█"
echo "░█░░░░█░░░█░░█▀▄░█▀█░░░█░█░█▀▀░█░█░░█░░█░░░█▀█░░█░░█▀▀░█░█░░░█▀▄░█░█░█░█░█░█"
echo "░▀▀▀░▀▀▀░░▀░░▀░▀░▀░▀░░░▀▀░░▀▀▀░▀▀░░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀▀░░░░▀░▀░▀▀▀░▀▀▀░▀░▀"

eval "$s_command"
