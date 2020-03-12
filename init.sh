### This file adds (source) all the files listed below to all opstkhelp-* (utils)
### 'source init.sh' locate in all opstkhelp-* scripts

# Add some shared vars
source vars.sh
# Add some func for work with Openstack API
source ${SUBFUNCTIONS_PATH}/openstack_api_func.sh
# Add some func for work with local rc-zone storage
source ${SUBFUNCTIONS_PATH}/rc_zone_func.sh

### Check the shared password used to generate the password encryption key from the rc-zone
### Returns nothing
### If necessary, it interacts with the user and terminates the program
### Usage: check_shared_password
get_shared_password(){
  if [ -z "$OPSTKHELP_PASSWORD" ]
  then
    echo -e "Set the environment variable OPSTKHELP_PASSWORD that contains the password. Use:" >&2
    echo -e "export OPSTKHELP_PASSWORD='your_password'" >&2
    exit 1
  fi

  MD5_BINARY_HASH=$(echo "$OPSTKHELP_PASSWORD" | openssl md5 -binary)
  if [ "$MD5_BINARY_HASH" != "$(cat ${SHARED_PASSWORD_HASH_PATH}/shared_password)" ]
  then
    echo -e "The password specified in the variable OPSTKHELP_PASSWORD is incorrect. Use:" >&2
    echo -e "export OPSTKHELP_PASSWORD='your_correct_password'" >&2
    exit 1
  fi
}

### Display error if the zone password (from rc-passwords file) is incorrect
### Returns nothing
### Usage: display_incorrect_password_error [RC_ZONE_NAME]
display_incorrect_password_error(){
  echo "Password of zone '$1' is incorrect" >&2
  echo -e "Try to add this zone again\nUse:" >&2
  echo -e "1) opstkhelp-remove-rc [ZONE-NAME]\n2) opstkhelp-add-rc [RC-FILE]" >&2
  echo "Attention: when deleting, the current rc-file of this zone will be deleted" >&2
}

### Display error if the zone is not found in the rc-zones file
### Returns nothing
### Usage: display_zone_not_find_error [RC_ZONE_NAME]
display_zone_not_find_error(){
  echo -e "Zone '$1' wasn't found in the rc-zones file" >&2
  echo -e "1) To get all added zones names use:\nopstkhelp-get-info" >&2
  echo -e "2) To get help use '--help' flag" >&2
}

### Display error if the server wasn't found in the rc-zone
### Returns nothing
### Usage: display_server_not_find_in_zone_error [RC_ZONE_NAME] [SERVER_NAME]
display_server_not_find_in_zone_error(){
  echo -e "Server named '$2' wasn't found in the zone named '$1'" >&2
  echo -e "1) To get all servers contains in the zone use:\nopstkhelp-get-info [RC_ZONE_NAME]" >&2
  echo -e "2) To get help use '--help' flag" >&2
}

### Search rc_zone in rc-zones file
### Returns nothing
### Usage: check_rc_zone_name_correctness [RC_ZONE_NAME]
### Exit with code '1' if zone name wasn't found
check_rc_zone_name_correctness(){
  find_rc_zone "$1"

  # If this zone wasn't found
  if [ "$?" -eq "0" ]
  then
    display_zone_not_find_error "$1" # Func
    exit 1
  fi
}

### Check rc-zone password correctness
### Returns nothing
### Usage: check_rc_zone_pass_correctness [RC_ZONE_NAME]
### Exit with code '1' if password is incorrect
check_rc_zone_pass_correctness(){
  check_zone_pass "$1"
  # If password is correct

  if [ "$?" -eq "1" ]
  then
    display_incorrect_password_error "$1" # Func
    exit 1
  fi
}

### Check whether the rc-zone contains a server
### Returns nothing
### Usage: check_server_rc_zone_correctness [RC_ZONE_NAME] [SERVER_NAME]
### Exit with code '1' if rc-zone not contains a server
check_server_rc_zone_correctness(){
  check_server_rc_zone "$1" "$2"

  if [ "$?" -eq "1" ]
  then
    display_server_not_find_in_zone_error "$1" "$2"
    exit 1
  fi
}

### When using getopts, the utility does not check
### whether the argument passed to the (: after) flag is correct.
### This function checks that the argument is not another flag.
### Return 1 if arg is incorrect
### Return 0 if arg is correct
### Usage: check_flag_arg [ARG]
check_flag_arg(){
  if [[ "$1" == '-'* ]] || [[ "$1" == "" ]]
  then
    return 1
  fi
}

### Check the password 
get_shared_password