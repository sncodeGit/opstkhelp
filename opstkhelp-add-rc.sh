#!/bin/bash

### This prog need to add rc-zone in programm local storage
### Functionality:
### 1) Print help : opstkhelp-add-rc -h, --help
### 2) Add rc-zone:  opstkhelp-add-rc RC_FILE
### Other usage should return an error
### Special usage error:
### 1) One argument is a file, but prog can't read it

### [Read pass] -> [Check pass] -> [Read zone name] -> [Check zone name] ->
### [Add zone name to rc-zones] -> [Copy rc-file to local storage]

# Add shared for all prog from package (for all opstkhelp-*) vars and performs general functions
source init.sh

display_help(){
  echo -e "Usage: opstkhelp-add-rc [RC-FILE]"
  echo -e "Usage: opstkhelp-add-rc [OPTIONS]\n"
  echo -e "Add new RC-zone to the local storage\n"
  echo -e "[RC-FILE] - path to target rc-file\n"
  echo -e "[OPTIONS]:"
  echo -e "-h, --help            Get this page"
}

### Usage: display_usage_error [FILE_NAME]
display_usage_error(){
  echo -e "Usage error or file '$1' not found\nUse:\nopstkhelp-add-rc --help" >&2
}

# User need help
# [opstkhelp-add-rc -h] or [opstkhelp-add-rc --help]
if [[ ("$1" == "-h" || "$1" == "--help") && "$#" -eq "1" ]]
then
  display_help # Func
  exit 0
fi

# One arg and prog can read file (this arg)
# [opstkhelp-add-rc file_name]
if [ "$#" -eq "1" ] && [ -r "$1" ]
then
  while [ true ]
  do
    echo "Please enter your OpenStack Password: "
    read -sr RC_PASS

    # Try to use this password
    # check_pass - func in openstack_api_func.sh
    api_check_rc_pass "$RC_PASS" "${PWD}/${1}"

    # If rc_pass is correct then copy rc-file and add zone in the rc-zone storage
    if [ "$?" -eq "0" ]
    then
      echo "Success. Password is correct"
      echo "Important: the RC-zone name must not contain space (' ') and sharp ('#') characters"
      while [ true ]
      do
        echo "Cpecify name of this RC-zone:"
        read -r RC_ZONE_NAME

        # Check rules for writing a name
        # This rules described in ${RC_ZONE_CONFIG_PATH}/rc_zones file
        # Also Сhecking whether a RC_zone with the same name was created earlier
        check_rc_zone "$RC_ZONE_NAME"
        CHECK_RC_ZONE_RET="$?"

        # If rc-zone name is correct RC-zone with the same name wasn't created earlier
        if [ "$CHECK_RC_ZONE_RET" -eq "0" ]
        then
          add_rc_zone "$RC_ZONE_NAME" "${PWD}/${1}" "$RC_PASS"
          echo "RC-zone was '${RC_ZONE_NAME}' successfully added"
          exit 0
        # If name syntax is incorrect
        elif [ "$CHECK_RC_ZONE_RET" -eq "1" ]
        then
          echo "RC-zone name is incorrect"
          echo "The RC-zone name must not contain space (' ') and sharp ('#') characters"
          echo "Try entering a different name"
        # If zone with the same name was found in rc-zones file (return code: 2)
        else
          echo "This RC-zone has already been added"
          echo "Try entering a different name"
        fi
      done
    fi

    # If rc_pass is incorrect (check_rc_pass isn't return 0)
    echo "Password is incorrect. Try entering again"
  done
fi

# One arg and file (this arg) exists, but prog can't read it
# [opstkhelp-add-rc NON_READEBLE]
if [ "$#" -eq "1" ] && [ -f "$1" ]
then
  echo "The file was found, but the program cannot read it. Check file permissions" >&2
  exit 1
fi

# Usage error
# Other [opstkhelp-add-rc *]
display_usage_error "$1" # Func
exit 1