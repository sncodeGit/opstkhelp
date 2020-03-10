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

# User need help
if [[ ("$1" == "-h" || "$1" == "--help") && "$#" -eq "1" ]]
then
  echo -e "Usage: opstkhelp-get-info (Display names of all added rc-zones)"
  echo -e "Usage: opstkhelp-get-info [RC-ZONE-NAME] (Display all servers from the target rc-zone)"
  echo -e "Usage: opstkhelp-get-info -s [SERVER-NAME] [RC-ZONE-NAME] (Display information about server)"
  echo -e "Usage: opstkhelp-get-info [OTHER-OPTIONS] (Get this page)\n"
  echo -e "Display information about added rc-zones\n"
  echo -e "[RC-ZONE-NAME] - name of the target RC-zone"
  echo -e "[SERVER-NAME] - name of the target server\n"
  echo -e "[OTHER-OPTIONS]:"
  echo -e "-h, --help            Get this page"
  exit 0

# Display all of rc-zones names
elif [ "$#" -eq "0" ]
then
  get_all_zones # Return values in the GET_ALL_ZONES var
  echo "$GET_ALL_ZONES"
  exit 0

# Display all servers from the target rc-zone ($1 != '-h', '--help')
elif [ "$#" -eq "1" ]
then
  # Check this zone for a busy
  find_rc_zone "$1"

  # If this zone wasn't found
  if [ "$?" -eq "0" ]
  then
    echo "Zone '$1' wasn't found in the rc-zones file" >&2
    echo -e "1) To get all added zones names use:\nopstkhelp-get-info" >&2
    echo -e "2) To get help use:\nopstkhelp-get-info --help" >&2
    exit 1

  # If zone was found
  else
    check_zone_pass "$1"

    # If password is correct
    if [ "$?" -eq "0" ]
    then
      get_zone_servers "$1" "0" # Return GET_ZONE_SERVERS
      echo "$GET_ZONE_SERVERS"
      exit 0

    else
      echo "Password of this zone is incorrect" >&2
      echo -e "Try to add this zone again\nUse:" >&2
      echo -e "1) opstkhelp-remove-rc [ZONE-NAME]\n2) opstkhelp-add-rc [RC-FILE]" >&2
      echo "Attention: when deleting, the current rc-file of this zone will be deleted" >&2
      exit 1
    fi
  fi

# Get information about server
elif [[ "$#" -eq "3" ]]
then
  # Parse SERVER_NAME and RC_ZONE_NAME
  while [ "$1" != "" ]
  do
    if [ "$1" != "-s" ]
    then
      if [ "$RC_ZONE" != "" ]
      then
        SERVER_NAME="$1"
      else
        RC_ZONE_NAME="$1"
      fi
    fi
    shift
  done

  # Return GET_SERVER_INFO var
  get_server_info "$RC_ZONE_NAME" "$SERVER_NAME"

  echo "GET_SERVER_INFO"

# Usage error
else
  echo -e "Usage error.\nUse:\nopstkhelp-get-info --help" >&2
  exit 1
fi