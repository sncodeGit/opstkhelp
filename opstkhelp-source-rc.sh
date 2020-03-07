#!/bin/bash

### This prog need to provide the user with the ability to use all the functionality of Openstack API
### Functionality:
### 1) Print help : opstkhelp-get-info -h, --help
### 2) Switching to the interactive mode: opstkhelp-get-info RC_ZONE_NAME (user enter his command himself)
### Other usage should return an error

# Add shared for all prog from package (for all opstkhelp-*)
source init.sh

# User need help
if [[ ("$1" == "-h" || "$1" == "--help") && "$#" -eq "1" ]]
then
  echo -e "Usage: opstkhelp-source-rc [RC-ZONE-NAME]"
  echo -e "Usage: opstkhelp-source-rc [OPTIONS]\n"
  echo -e "Source (alias command - '.') rc-file of the selected rc-zone"
  echo -e "After using this command you can work with openstack API for this zone\n"
  echo -e "Important: The program works interactively by launching a new interactive bash shell"
  echo -e "To exit interactive mode, use:\nexit\n"
  echo -e "[RC-ZONE-NAME] - name of the target RC-zone\n"
  echo -e "[OPTIONS]:"
  echo -e "-h, --help          Get this page"
  exit 0

# Source rc-file of the zone passed as an argument ($1)
elif [ "$#" -eq "1" ]
then
  # Check this zone for a busy
  find_rc_zone "$1"

  # If this zone wasn't found
  if [ "$?" -eq "0" ]
  then
    echo "Zone '$1' wasn't found in the rc-zones file" >&2
    echo -e "1) To get all added zones names use:\nopstkhelp-get-info" >&2
    echo -e "2) To get help use:\nopstkhelp-source-rc --help" >&2
    exit 1

  # If zone was found
  else
    check_zone_pass "$1"

    # If password is correct
    if [ "$?" -eq "0" ]
    then
      source_rc_zone "$1"
      
      # Interactive console for work with openstack API
      echo "Enter 'exit' for exit from interactive mode"
      while [ true ]
      do
        echo -n "[${1}]> "
        read USER_INPUT
        eval $USER_INPUT
      done

      exit 0

    else
      echo "Password of this zone is incorrect" >&2
      echo -e "Try to add this zone again\nUse:" >&2
      echo -e "1) opstkhelp-remove-rc [ZONE-NAME]\n2) opstkhelp-add-rc [RC-FILE]" >&2
      echo "Attention: when deleting, the current rc-file of this zone will be deleted" >&2
      exit 1
    fi
  fi

# Usage error
else
  echo -e "Usage error.\nUse:\nopstkhelp-source-rc --help" >&2
  exit 1
fi