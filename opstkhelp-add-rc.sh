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
    # If rc_pass is correct then copy rc-file and add zone in the rc-zone storage
    if [ $? -eq 0 ]
    then
      echo "Success. Password is correct"
      echo "Important: the RC-zone name must not contain space (' '), colon (':') and sharp ('#') characters"
      while [ true ]
      do
        echo "Cpecify name of this RC-zone:"
        read -r RC_ZONE_NAME

        # Check rules for writing a name
        # This rules described in ${RC_ZONE_CONFIG_PATH}/rc_zones file
        check_rc_zone_name "$RC_ZONE_NAME"

        # If name is correct
        if [ $? -eq 0 ]
        then
          # Сhecking whether a RC_zone with the same name was created earlier
          check_rc_zone "$RC_ZONE_NAME"

          # If RC-zone with the same name wasn't created earlier
          if [ $? -eq 0 ]
          then
            add_rc_zone "$RC_ZONE_NAME" "${PWD}/${1}" "$RC_PASS"
            echo "RC-zone '${RC_ZONE_NAME}' successfully added"
            exit 0
          else
            echo "This RC-zone has already been added"
            echo "Try entering a different name"
          fi
        else
          echo "RC-zone name is incorrect"
          echo "The RC-zone name must not contain space (' '), colon (':') and sharp ('#') characters"
          echo "Try entering a different name"
        fi
      done
    fi

    # If rc_pass is incorrect (check_rc_pass isn't return 0)
    echo "Password is incorrect. Try entering again"
  done

# One arg and file (this arg) exists, but prog can't read it
elif [ $# -eq 1 ] && [ -f "$1" ]
then
  echo "The file was found, but the program cannot read it. Check file permissions"
  exit 1

# Usage error
else
  echo -e "Usage error or file '$1' not found. \nUse:\nopstkhelp-add-rc --help"
  exit 1
fi;