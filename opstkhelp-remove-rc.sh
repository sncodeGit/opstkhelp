#!/bin/bash

### This prog need to remove rc-zone from programm local storage
### Functionality:
### 1) Print help : opstkhelp-remove-rc -h, --help
### 2) Remove rc-zone:  opstkhelp-remove-rc RC_ZONE_NAME
### Other usage should return an error

### [Read zone name] -> [Remove this zone record from rc-zones] ->
### [Delete this zone rc-file]

# Add shared for all prog from package (for all opstkhelp-*) vars and performs general functions
source init.sh

display_help(){
  echo -e "Usage: opstkhelp-remove-rc [RC-ZONE-NAME]"
  echo -e "Usage: opstkhelp-remove-rc [OPTIONS]\n"
  echo -e "Remove RC-zone from the local storage\n"
  echo -e "[RC-ZONE-NAME] - name of the target RC-zone\n"
  echo -e "[OPTIONS]:"
  echo -e "-h, --help            Get this page"
}

display_usage_error(){
  echo -e "Usage error.\nUse:\nopstkhelp-remove-rc --help" >&2
}

# User need help
if [ "$#" -eq "0" ] || [[ ("$1" == "-h" || "$1" == "--help") && "$#" -eq "1" ]]
then
  display_help # Func
  exit 0

# One arg (zone-name)
elif [ "$#" -eq "1" ]
then
  # Search this rc-zone name in the rc-zones file
  find_rc_zone "$1"
  # If name wasn't found in rc-zones files
  if [ "$?" -eq "0" ]
  then
    display_zone_not_find_error "$1" # Func
    exit 1
  # If this zone was found
  else
    remove_rc_zone "$1"
    echo "Succesfully! Zone '$1' was removed"
    exit 0
  fi

# Usage error
else
  display_usage_error # Func
  exit 1
fi