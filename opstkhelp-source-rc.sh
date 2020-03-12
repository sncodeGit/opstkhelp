#!/bin/bash

### This prog need to provide the user with the ability to use all the functionality of Openstack API
### Functionality:
### 1) Print help : opstkhelp-get-info -h, --help
### 2) Switching to the interactive mode: opstkhelp-get-info RC_ZONE_NAME (user enter his command himself)
### Other usage should return an error

# Add shared for all prog from package (for all opstkhelp-*) vars and performs general functions
source init.sh

display_help(){
  echo -e "Usage: opstkhelp-source-rc [RC-ZONE-NAME]"
  echo -e "Usage: opstkhelp-source-rc [OPTIONS]\n"
  echo -e "Source (alias command - '.') rc-file of the selected rc-zone"
  echo -e "After using this command you can work with openstack API for this zone\n"
  echo -e "Important: The program works interactively by launching a new interactive bash shell"
  echo -e "To exit from interactive mode, use: exit\n"
  echo -e "[RC-ZONE-NAME] - name of the target RC-zone\n"
  echo -e "[OPTIONS]:"
  echo -e "-h, --help            Get this page"
}

display_usage_error(){
  echo -e "Usage error\nUse:\nopstkhelp-source-rc --help" >&2
}

# User need help
# [opstkhelp-source-rc -h] or [opstkhelp-source-rc --help]
if [[ ("$1" == "-h" || "$1" == "--help") && "$#" -eq "1" ]]
then
  display_help # Func
  exit 0
fi

# Source rc-file of the zone passed as an argument ($1)
if [ "$#" -eq "1" ]
then
  # Search rc_zone in rc-zones file
  check_rc_zone_name_correctness "$1"

  # Check rc-zone password correctness
  check_rc_zone_pass_correctness "$1"

  # Source (alias - '.') appropriate rc-file
  source_rc_zone "$1"
  # Interactive console for work with openstack API
  echo "Enter 'exit' for exit from interactive mode"
  while [ true ]
  do
    echo -n "[${1}]> "
    read USER_INPUT
    eval "$USER_INPUT"
  done

  exit 0
fi

# Usage error
# Other [opstkhelp-source-rc *]
display_usage_error # Func
exit 1