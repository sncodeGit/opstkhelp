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

# Add shared for all prog from package (for all opstkhelp-*) vars and performs general functions
source init.sh

display_help(){
  echo -e "Usage: opstkhelp-manage-server [OPTIONS] ['start'|'stop' SERVER-NAME]\n"
  echo -e "Manage selected server (start or stop)\n"
  echo -e "[SERVER-NAME] - name of target server\n"
  echo -e "[OPTIONS]:"
  echo -e "-h, --help            Get this page."
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

# User need help
if [ "$#" -eq "0" ] || [[ ("$1" == "-h" || "$1" == "--help") && "$#" -eq "1" ]]
then
  display_help # Func
  exit 0
fi

check_opt_arg(){
  
}

# Flags parsing
while getopts "z:aw" opt &> /dev/null
do
  case "$opt" in
    z)
      check_opt_arg "$OPTARG"
      ;;
    a)
      echo "find a"
      ;;
    w)
      echo "find w"
      ;;
    \?)
      echo "ill arg"
      exit 0
      ;;
  esac
done