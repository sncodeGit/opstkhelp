#!/bin/bash

### This prog need to get info about rc-zones added earlier
### Functionality:
### 1) Print help : opstkhelp-get-info -h, --help
### 2) Display the names of all RC-zones and their password validation: opstkhelp-get-info
### 3) Display the names of all the servers that are located in this RC-zone: opstkhelp-get-info RC_ZONE_NAME
### Other usage should return an error

# Add shared for all prog from package (for all opstkhelp-*)
source init.sh

# User need help
if [[ ("$1" == "-h" || "$1" == "--help") && "$#" -eq "1" ]]
then
  echo -e "Usage: opstkhelp-get-info (Display names of all added rc-zones and result of their password validation)"
  echo -e "Usage: opstkhelp-get-info [RC-ZONE-NAME] (Display all servers from the target rc-zone)"
  echo -e "Usage: opstkhelp-get-info [OPTIONS]\n"
  echo -e "Display information about added rc-zones\n"
  echo -e "[RC-ZONE-NAME] - name of the target RC-zone\n"
  echo -e "[OPTIONS]:"
  echo -e "-h, --help          Get this page"
  exit 0

# Display all of rc-zones names
elif [ "$#" -eq "0" ]
then
  get_all_zones # Return values in the GET_ALL_ZONES var
  echo -e "All added zones:\n----------"
  echo "$GET_ALL_ZONES"
  echo "----------"

  # Check password of all rc-zones
  echo -e "\nPasswords verification results:"
  HAVE_PASS_TROUBLE=0 # Have a password problem?
  for RC_ZONE in $GET_ALL_ZONES
  do
    check_zone_pass "$RC_ZONE"
    # If password is incorrect
    if [ "$?" -eq "1" ]
    then
      if [ "$HAVE_PASS_TROUBLE" -eq "0" ]
      then
        echo "----------"
        HAVE_PASS_TROUBLE=1
      fi
      echo "Having problems with zone '$RC_ZONE' password"
    fi
  done
  if [ "$HAVE_PASS_TROUBLE" -eq "1" ]
  then
    echo "----------"
    echo -e "Try to add this zone again\nUse:"
    echo -e "opstkhelp-remove-rc [ZONE-NAME]\nopstkhelp-add-rc"
    echo "Attention: when deleting, the current rc-file of this zone will be deleted"
  else
    echo -e "All passwords are correct"
  fi
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
    echo -e "To get all added zones names use:\nopstkhelp-get-info" >&2
    exit 1

  # If zone was found
  else
    check_zone_pass "$1"

    # If password is correct
    if [ "$?" -eq "0" ]
    then
      get_zone_servers "$1" # Return GET_ZONE_SERVERS
      echo -e "All zone '$1' servers:\n----------"
      echo "$GET_ZONE_SERVERS"
      echo "----------"
      exit 0

    else
      echo "Password of this zone is incorrect" >&2
      echo -e "Try to add this zone again\nUse:" >&2
      echo -e "opstkhelp-remove-rc [ZONE-NAME]\nopstkhelp-add-rc" >&2
      echo "Attention: when deleting, the current rc-file of this zone will be deleted" >&2
      exit 1
    fi
  fi

# Usage error
else
  echo -e "Usage error.\nUse:\nopstkhelp-get-info --help" >&2
  exit 1
fi