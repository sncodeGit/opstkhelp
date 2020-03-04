#!/bin/bash

### This prog need to add rc-file in programm loacal storage
### Functionality:
### 1) Print help : opstkhelp-add-rc -h, --help
### 2) Add rc-file:  opstkhelp-add-rc RC_FILE
### Other usage should return an error

# Add some shared vars
source vars.sh
# Add some func for work with Openstack API
source ${SUBFUNCTIONS_PATH}/openstack_api_func.sh
# Add some func for work with local rc-zone storage
source ${SUBFUNCTIONS_PATH}/rc_zone_func.sh

# User need help
if [ $# -eq 0 ] || [[ ("$1" == "-h" || "$1" == "--help") && $# -eq 1 ]]
then
    echo -e "Usage: opstkhelp-add-rc [RC-FILE]"
    echo -e "Usage: opstkhelp-add-rc [OPTIONS]\n"
    echo -e "Add new RC-File to the storage\n"
    echo -e "[RC-FILE] - path to target rc-file\n"
    echo -e "[OPTIONS]:"
    echo -e "-h, --help          Get this page"
    exit 0

# One arg and prog can read file (this arg)
elif [ $# -eq 1 ] && [ -r "$1" ]
then
  while [ true ]
  do
    echo "Please enter your OpenStack Password: "
    read -sr RC_PASS

    # Try to use this password
    # check_pass - func in openstack_api_func.sh
    check_rc_pass "$RC_PASS" "${PWD}/${1}"
    # If rc_pass is correct then copy rc-file and add zone in rc-zone storage
    if [ $? -eq 0 ]
    then
      while [ true ]
      do
        echo "Please cpecify name of this RC-zone:"
        read -r RC_ZONE
        check_rc_zone "$RC_ZONE"
        if [ $? -eq 0 ]
        then
          add_rc_zone "$RC_ZONE" "${PWD}/${1}" "$RC_PASS"
          echo "RC-zone '${RC_ZONE}' successfully added"
          exit 0
        else
          echo "This RC-zone has already been added"
          echo "Try entering a different name"
        fi
      done
    fi
  done

# One arg and file (this arg) exists, but prog can't read it
elif [ $# -eq 1 ] && [ -f "$1" ]
then
  echo "The file was found, but the program cannot read it. Check file permissions"
  exit 1

# Usage error
else
  echo -e "Usage error or file '$1' not found. Use:\nopstkhelp-add-rc -h"
  exit 1
fi;