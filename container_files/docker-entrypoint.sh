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
fi

print_header() {
  local pf="● %-19s %-25s\n"

  [ ! "x$CITRA_ROOMDESC" = "x" ] && room_desc="${CITRA_ROOMDESC}" || room_desc="(unset)"
  [ ! "x$s_password" = "x" ] && room_pass="Yes" || room_pass="No"
  [ $CITRA_ISPUBLIC = 1 ] && room_public="Yes" || room_public="No"
  [ ! "x$CITRA_PREFGAMEID" = "x" ] && room_pgid="${CITRA_PREFGAMEID}" || room_pgid="(unset)"
  [ ! "x$CITRA_WEBAPIURL" = "x" ] && room_api="${CITRA_WEBAPIURL}" || room_api="(unset)"

  printf "\n"
  printf "░█▀▀░▀█▀░▀█▀░█▀▄░█▀█░░░█▀▄░█▀▀░█▀▄░▀█▀░█▀▀░█▀█░▀█▀░█▀▀░█▀▄░░░█▀▄░█▀█░█▀█░█▄█\n"
  printf "░█░░░░█░░░█░░█▀▄░█▀█░░░█░█░█▀▀░█░█░░█░░█░░░█▀█░░█░░█▀▀░█░█░░░█▀▄░█░█░█░█░█░█\n"
  printf "░▀▀▀░▀▀▀░░▀░░▀░▀░▀░▀░░░▀▀░░▀▀▀░▀▀░░▀▀▀░▀▀▀░▀░▀░░▀░░▀▀▀░▀▀░░░░▀░▀░▀▀▀░▀▀▀░▀░▀\n"
  printf "\n"
  printf "$pf" "Port:" "${CITRA_PORT}"
  printf "$pf" "Name:" "${CITRA_ROOMNAME}"
  printf "$pf" "Description:" "${room_desc}"
  printf "$pf" "Password:" "${room_pass}"
  printf "$pf" "Public:" "${room_public}"
  printf "$pf" "Preferred Game:" "${CITRA_PREFGAME}"
  printf "$pf" "Preferred Game ID:" "${room_pgid}"
  printf "$pf" "Maximum Members:" "${CITRA_MAXMEMBERS}"
  printf "$pf" "Banlist File:" "${CITRA_BANLISTFILE}"
  printf "$pf" "Log File:" "${CITRA_LOGFILE}"
  printf "$pf" "Web API URL:" "${room_api}"
  printf "\n"
}

print_header
eval "$s_command"