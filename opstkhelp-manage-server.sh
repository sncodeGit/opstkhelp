#!/bin/bash

### This prog need to start or stop servers
### Functionality:
### 1) Print help : opstkhelp-manage-server -h, --help
### 2) Start or stop server from specified rc-zone: opstkhelp-manage-server -z ZONE_NAME ['start'|'stop'] SERVER_NAME
### 3) Start or stop all servers (from all added rc-zones) with specified name: opstkhelp-manage-server -a ['start'|'stop'] SERVER_NAME
### 4) Start or stop server (without information about rc-zone): opstkhelp-manage-server ['start'|'stop'] SERVER_NAME
### -- Update all servers-lists files of all zones
### 5) Start or stop server (without information about rc-zone): opstkhelp-manage-server -w ['start'|'stop'] SERVER_NAME
### -- Not update servers-lists files
### Other usage should return an error
### 1) If the '-z' flag is used with other flags, then these flags are ignored

# Add shared for all prog from package (for all opstkhelp-*) vars and performs general functions
source init.sh

display_help(){
  echo -e "Usage: opstkhelp-manage-server [OPTIONS] ['start'|'stop' SERVER-NAME]"
  echo -e "Usage: opstkhelp-manage-server [OTHER-OPTIONS]\n"
  echo -e "Manage selected server (start or stop)\n"
  echo -e "[SERVER-NAME] - name of target server\n"
  echo -e "[OTHER-OPTIONS]:"
  echo -e "-h, --help            Get this page.\n"
  echo -e "[OPTIONS]:"
  echo -e "-z                    Specify rc-zone for this server."
  echo -e "                      If this flag is specified, the other flags are ignored."
  echo -e "-a                    If the server's rc-zone is not specified (-z, --rc-zone flag),"
  echo -e "                      this flag will perform the necessary action with servers that have specified name"
  echo -e "                      from all zones. If server's rc-zone was specified then that flag will be ignored."
  echo -e "-w                    By default, without using the -z (--rc-zone) flag, the program updates the servers-lists (cache) files of all zones."
  echo -e "                      This behavior can be disabled using this flag. Use this flag only if you are sure"
  echo -e "                      that the list of servers has not been updated since the last updates the servers-lists files of all zones."
  echo -e "Examples:"
  echo -e "opstkhelp-manage-server -z ZONE_NAME start SERVER_NAME"
  echo -e "--- Start server named SERVER_NAME located in zone named ZONE_NAME."
  echo -e "opstkhelp-manage-server -a stop SERVER_NAME"
  echo -e "--- Stop server named SERVER_NAME."
  echo -e "--- If servers with this name are found in multiple zones,"
  echo -e "--- all of them will be stopped."
  echo -e "opstkhelp-manage-server -w start SERVER_NAME"
  echo -e "--- Start a server with this name located in any of the added zones."
  echo -e "--- If multiple servers with this name are found in the servers-list (cache), an error will be generated."
  echo -e "opstkhelp-manage-server -w -a start SERVER_NAME"
  echo -e "--- Start server named SERVER_NAME located in any zone."
  echo -e "--- Using servers-lists (cache) to find the right zones."
}

display_usage_error(){
  echo -e "Usage error\nUse:\nopstkhelp-manage-server --help" >&2
}

# User need help
# [opstkhelp-manage-server --help] or [opstkhelp-manage-server -h]
if [[ ("$1" == "-h" || "$1" == "--help") && "$#" -eq "1" ]]
then
  display_help # Func
  exit 0
fi

# Vars initialization

# Values:
# '1') if flag '-a' is set
# other) if flag '-a' isn't set
ARG_ALL_SERVERS_FLAG="0"

# Values:
# '1') if flag '-w' is set
# other) if flag '-w' isn't set
ARG_USE_CASHE_FLAG="0"

# Zone name arg (if flag '-z' are used)
ARG_RC_ZONE_NAME=""

# Server name arg
ARG_SERVER_NAME=""

# Server action arg ('start' or 'stop')
ARG_SERVER_ACTION=""

# Flags parsing
while getopts "z:aw" opt &> /dev/null
do
  case "$opt" in
    z)
      check_flag_arg "$OPTARG"
      if [ "$?" -eq "1" ]
      then
        display_usage_error
        exit 1
      fi

      ARG_RC_ZONE_NAME="$OPTARG"
      ;;
    a)
      ARG_ALL_SERVERS_FLAG="1"
      ;;
    w)
      ARG_USE_CASHE_FLAG="1"
      ;;
    \?)
      display_usage_error
      exit 1
      ;;
  esac
done

# Shift prog args to arg ['start'|'stop']
shift $((OPTIND - 1))

ARG_SERVER_ACTION="$1"
ARG_SERVER_NAME="$2"

# Manage server from specified rc-zone
# [opstkhelp-manage-server * -z ZONE_NAME 'start'|'stop' SERVER_NAME] (* - other flags)
if [[ "$ARG_RC_ZONE_NAME" != "" ]]
then
  # Search this zone in rc-zones file
  check_rc_zone_name_correctness "$ARG_RC_ZONE_NAME"

  # Check rc-zone pass
  check_rc_zone_pass_correctness "$ARG_RC_ZONE_NAME"

  # Search server in rc-zone
  check_server_rc_zone_correctness "$ARG_RC_ZONE_NAME" "$ARG_SERVER_NAME"

  # Server management
  manage_rc_zone_server "$ARG_RC_ZONE_NAME" "$ARG_SERVER_NAME" "$ARG_SERVER_ACTION"
fi

# Usage error
# Other [opstkhelp-manage-server *]
display_usage_error # Func
exit 1