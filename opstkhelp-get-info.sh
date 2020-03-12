#!/bin/bash

### This prog need to get info about rc-zones (and servers) added earlier
### Functionality:
### 1) Print help : opstkhelp-get-info -h, --help
### 2) Display the names of all added RC-zones: opstkhelp-get-info
### 3) Display the names of all the servers that are located in this RC-zone: opstkhelp-get-info RC_ZONE_NAME
### 4) Display info about server: opstkhelp-get-info -s SERVER_NAME RC_ZONE_NAME
### Other usage should return an error

# Add shared for all prog from package (for all opstkhelp-*) vars and performs general functions
source init.sh

display_help(){
  echo -e "Usage: opstkhelp-get-info                                  Display names of all added rc-zones"
  echo -e "Usage: opstkhelp-get-info [RC-ZONE-NAME]                   Display all servers from the target rc-zone"
  echo -e "Usage: opstkhelp-get-info -s [SERVER-NAME] [RC-ZONE-NAME]  Display information about server"
  echo -e "Usage: opstkhelp-get-info [OTHER-OPTIONS]                  Get this page\n"
  echo -e "Display information about added rc-zones\n"
  echo -e "[RC-ZONE-NAME] - name of the target RC-zone"
  echo -e "[SERVER-NAME] - name of the target server\n"
  echo -e "[OTHER-OPTIONS]:"
  echo -e "-h, --help            Get this page"
}

display_usage_error(){
  echo -e "Usage error\nUse:\nopstkhelp-get-info --help" >&2
}

# User need help
# [opstkhelp-get-info -h] or [opstkhelp-get-info --help]
if [[ ("$1" == "-h" || "$1" == "--help") && "$#" -eq "1" ]]
then
  display_help # Func
  exit 0
fi

# Display all of rc-zones names
# [opstkhelp-get-info]
if [ "$#" -eq "0" ]
then
  get_all_zones # Return values in the GET_ALL_ZONES var
  echo "$GET_ALL_ZONES"
  exit 0
fi

# Display all servers from the target rc-zone ($1 != '-h', '--help')
# [opstkhelp-get-info SERVER_NAME]
if [ "$#" -eq "1" ]
then
  # Search rc-zone name in rc-zones file
  check_rc_zone_name_correctness "$1"

  # Check rc-zone password correctness
  check_rc_zone_pass_correctness "$1"
  
  get_zone_servers "$1" "0" # Return GET_ZONE_SERVERS
  echo "$GET_ZONE_SERVERS"
  exit 0
fi

# Get information about server
# [opstkhelp-get-info -s SERVER_NAME RC_ZONE_NAME]
if [[ "$#" -eq "3" ]]
then
  # Vars initialization
  ARG_RC_ZONE_NAME=""
  ARG_SERVER_NAME=""

  # Parse SERVER_NAME and RC_ZONE_NAME
  while getopts "s:" opt &> /dev/null
  do
    case "$opt" in
      s)
        check_flag_arg "$OPTARG"
        if [ "$?" -eq "1" ]
        then
          display_usage_error
          exit 1
        fi
        ARG_SERVER_NAME="$OPTARG"
        ;;
      \?)
        display_usage_error
        exit 1
        ;;
    esac
  done

  shift $((OPTIND - 1))
  ARG_RC_ZONE_NAME="$1"

  # If the parameter sequence is not correct
  if [ "$1" == "" ]
  then
    display_usage_error # Func
    exit 1
  fi

  # Search this zone in rc-zones file
  check_rc_zone_name_correctness "$1"

  # Check rc-zone pass
  check_rc_zone_pass_correctness "$1"

  # Search server in rc-zone
  check_server_rc_zone_correctness "$ARG_RC_ZONE_NAME" "$ARG_SERVER_NAME"

  # Return GET_SERVER_INFO var
  get_server_info "$ARG_RC_ZONE_NAME" "$ARG_SERVER_NAME"

  echo "$GET_SERVER_INFO"
  exit 0
fi

# Usage error
# Other [opstkhelp-get-info *]
display_usage_error # Func
exit 1