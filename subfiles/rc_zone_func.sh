### Functions list:
# get_all_zones
# get_zone_pass
# check_rc_zone_name
# find_rc_zone
# check_rc_zone
# check_zone_pass
# update_servers_list
# get_zone_servers
# check_server_rc_zone
# get_server_rc_zones
# get_server_info
# source_rc_zone
# add_rc_zone
# remove_rc_zone


### Get the names of all added rc-zones
### Gets the names from rc-zones file
### Return GET_ALL_ZONES var with the following sintax:
### ***
### FIRST_NAME
### SECOND_NAME
### ... (etc.)
### ***
### Usage: get_all_zones
get_all_zones(){
  # Remove comments and empty strings and strings containing only spaces (' ') from rc-zones file
  GET_ALL_ZONES=$(cat ${RC_ZONE_CONFIG_PATH}/rc-zones | sed -r '/^ *#/d' | sed -r '/^$/d' | sed -r '/^ *$/d')
}

### Get the rc-zone password
### Gets the password from rc-zones file
### Return GET_ZONE_PASS var containing password
### Usage: get_zone_pass [RC_ZONE_NAME]
get_zone_pass(){
  ENCODED_PASS=$(cat ${PASSWORDS_STORAGE_PATH}/${1}-password)
  GET_ZONE_PASS=$(echo -n "$ENCODED_PASS" | openssl enc -d -aes-256-cbc -pbkdf2 -pass "pass:${OPSTKHELP_PASSWORD}")
}

### Check rc-zone name to correctness
### Using rules described in ${RC_ZONE_CONFIG_PATH}/rc_zones file
### Also checks if an empty string was passed
### Return 0 if this name is correct
### Return 1 if this name is incorrect
### Usage: check_rc_zone_name [RC_ZONE_NAME]
check_rc_zone_name(){
  # If RC_ZONE_NAME is empty
  if [[ "$1" == "" ]]
  then
    return 1
  fi
 
  # If there is space (' ') in the RC_ZONE_NAME
  if [[ "$1" == *' '* ]]
  then
    return 1
  fi
  
  # If there is sharp ('#') in the RC_ZONE_NAME
  if [[ "$1" == *'#'* ]]
  then
    return 1
  fi

  return 0
}

### Search for a zone in rc-zones file
### Return 0 if this rc-zone name wasn't found
### Return 1 if this rc-zone name was found
### Usage : find_rc_zone [RC_ZONE_NAME]
find_rc_zone(){
  get_all_zones # Return values in the GET_ALL_ZONES var

  for ZONE_NAME in $GET_ALL_ZONES
  do
    if [ "$ZONE_NAME" = "$1" ]
    then
      return 1
    fi
  done
  return 0
}

### Check for a busy RC-zone name (find_rc_zone)
### Also check rc-zone name to correctness according rc_zones (see check_rc_zone_name func)
### Return 0 if this zone wasn't added earlier and also the name itself is correct
### Return 1 if this zone name is incorrect according check_rc_zone_name func
### Return 2 if this zone was found in local storage earlier
### Usage: check_rc_zone [RC_ZONE_NAME]
check_rc_zone(){
  # Check zone_name to correctness
  check_rc_zone_name "$1"

  # If zone_name is incorrect
  if [ "$?" -eq "1" ]
  then
    return 1
  fi

  # Check zone name for a busy
  find_rc_zone "$1"

  # If zone name was added earlier
  if [ "$?" -eq "1" ]
  then
  return 2
  fi

  return 0
}

### Check password of added rc-zone (according to api_check_rc_pass func)
### Return 0 if password is correct
### Return 1 if password is incorrect
### Usage: check_zone_pass [RC_ZONE_NAME]
check_zone_pass(){
  # Get password of this zone
  get_zone_pass "$1" # Return GET_ZONE_PASS var

  # Check password of this zone
  api_check_rc_pass "$GET_ZONE_PASS" "${RC_FILES_STORAGE_PATH}/${1}.sh"
  
  # If password is correct
  if [ "$?" -eq 0 ]
  then
    return 0
  else
    return 1
  fi
}

### Update servers list (the corresponding file in the directory servers-lists)
### Rewrite target file writing a more recent list of servers
### Returns nothing
### Usage: update_servers_list [RC_ZONE_NAME] [SERVERS_LIST]
### [SERVERS_LIST] format:
### ***
### FIRST_SERVER_NAME
### SECOND_SERVER_NAME
### ...
### ***
update_servers_list(){
  # Rewrite target file
  echo -n "${2}" > ${SERVERS_LISTS_STORAGE_PATH}/${1}-servers
}

### Get all servers from target rc-zone
### Use OpenStack API and update servers list of target rc-zone
### Or use servers-lists files (cache)
### Return GET_ZONE_SERVERS var with the following sintax:
### *** 
### FIRST_SERVER_NAME
### SECOND_SERVER_NAME
### ... (etc.)
### ***
### Usage: get_zone_servers [RC_ZONE_NAME] [USE_CACHE_FLAG]
### If set USE_CACHE_FLAG (== 1) then use servers-lists files (cache)
### Else (USE_CACHE_FLAG != 1) then use the Openstack API
get_zone_servers(){
  # Use cache
  if [ "$2" -eq "1" ]
  then
    GET_ZONE_SERVERS=$(cat ${SERVERS_LISTS_STORAGE_PATH}/${1}-servers)
  # Use OpenStack API
  else
    # Get password of this zone
    get_zone_pass "$1" # Return GET_ZONE_PASS var

    # Get all servers from target rc-zone
    # Return API_GET_ALL_SERVERS var
    api_get_all_servers "$GET_ZONE_PASS" "${RC_FILES_STORAGE_PATH}/${1}.sh"

    # Update servers list for this rc-zone
    update_servers_list "$1" "$API_GET_ALL_SERVERS"

    GET_ZONE_SERVERS="$API_GET_ALL_SERVERS"
  fi
}

### Check whether the rc-zone contains a server with this name
### Use OpenStack API and update servers list of target rc-zone (get_zone_servers func)
### Return 0 if this rc-zone contains server
### Return 1 if server wasn't found in this rc-zone
### Usage: check_server_rc_zone [RC_ZONE_NAME] [SERVER_NAME]
check_server_rc_zone(){
  # Don't use cache (servers-list file)
  # Return GET_ZONE_SERVERS var
  get_zone_servers "$1" "0"

  for SERVER_NAME in ${GET_ZONE_SERVERS}
  do
    if [ "$SERVER_NAME" == "$2" ]
    then
      return 0
    fi
  done

  # Server wasn't found
  return 1
}

### Find rc-zones including server named as an arg
### Use servers-lists files (cache) or Openstack API
### Return GET_SERVER_RC_ZONES var with the following sintax:
### ***
### FIRST_ZONE_NAME SECOND_ZONE_NAME ...
### ***
### Usage: get_server_rc_zones [SERVER_NAME] [USE_CACHE_FLAG]
### If set USE_CACHE_FLAG (== 1) then use servers-lists files (get_cached_zone_servers func)
### Else (USE_CACHE_FLAG != 1) then use the Openstack API (get_zone_servers func)
get_server_rc_zones(){
  # Initialization of returned var
  GET_SERVER_RC_ZONES=""

  get_all_zones # Return values in the GET_ALL_ZONES var

  for ZONE_NAME in ${GET_ALL_ZONES}
  do
    get_zone_servers "$1" "$2" # Returns var named as the contents of ${GET_SERVER_VAR}
    for SERVER_NAME in ${GET_ZONE_SERVERS}
    do
      if [ "$SERVER_NAME" == "$1" ]
      then
        GET_SERVER_RC_ZONES="${GET_SERVER_RC_ZONES} ${ZONE_NAME}"
        continue
      fi
    done
  done
}

### Get information about server
### Return GET_SERVER_INFO var with the following sintax:
### ***
### FIRST_FIELD=FIRST_VALUE
### SECOND_FIELD=SECOND_VALUE
### ...
### ***
### Usage: get_server_info [RC_ZONE_NAME] [SERVER_NAME]
get_server_info(){
  # Get password of this zone
  get_zone_pass "$1" # Return GET_ZONE_PASS var

  # Return API_GET_SERVER_INFO var
  api_get_server_info "$GET_ZONE_PASS" "${RC_FILES_STORAGE_PATH}/${1}.sh" "$2"

  GET_SERVER_INFO="$API_GET_SERVER_INFO"
}

### Source (alias command - '.') zone with name passed as arh
### Returns nothing
### Usage: source_rc_zone [RC_ZONE_NAME]
source_rc_zone(){
  # Get password of this zone
  get_zone_pass "$1" # Return GET_ZONE_PASS var

  # Source ('.') rc-file of this rc-file
  api_source_rc_file "$GET_ZONE_PASS" "${RC_FILES_STORAGE_PATH}/${1}.sh"
}

### Add a new RC-zone 
### Update servers-list of adding rc-zone
### Returns nothing
### Usage: add_rc_zone [RC_ZONE_NAME] [RC_FILE] [RC_PASS]
### Attention: don't check rc-zone name (use check_rc_zone func)
add_rc_zone(){
  # Add record to the rc-zones file
  echo -en "\n$1" >> "${RC_ZONE_CONFIG_PATH}/rc-zones"

  # Add file with password of this rc-zone in rc-passwords storage
  touch ${PASSWORDS_STORAGE_PATH}/${1}-password
  ENCODED_PASS=$(echo -n "$3" | openssl enc -aes-256-cbc -salt -pbkdf2 -pass "pass:${OPSTKHELP_PASSWORD}")
  echo -n "$ENCODED_PASS" > ${PASSWORDS_STORAGE_PATH}/${1}-password

  # Add rc-file to the rc-files storage
  cp "$2" "$RC_FILES_STORAGE_PATH/$1.sh"

  # Create new server list file in the servers-lists storage
  touch ${SERVERS_LISTS_STORAGE_PATH}/${1}-servers

  # Initialization server list
  get_zone_servers "$1" "0"
}

### Remove RC-zone from rc-zones file and rc-file from local storage
### Returns nothing
### Usage: remove_rc_zone [RC_ZONE_NAME]
remove_rc_zone(){
  # Remove record from rc-zone file
  sed -ri "/^${1}.*$/d" "${RC_ZONE_CONFIG_PATH}/rc-zones"
  # If you add \n to the end of the line
  # before the line being added, a problem occurs (add_rc_zone func)
  # If you remove the last string from rc-zones file
  # then the line wrap (\n) is not deleted
  # Accordingly an empty string will appear between
  # the next line to be added and the next to last one
  # The following code fixes this
  # [Get last line from rc-zones] -> [Delete last line] ->
  # -> [Write last line excluding special characters (\n)]
  LAST_LINE=$(sed -n '$p' tmp/rc-zones)
  sed -i '$d' tmp/rc-zones
  echo -n ${LAST_LINE} >> tmp/rc-zones

  # Remove file with password of this rc-zone from rc-passwords storage
  rm ${PASSWORDS_STORAGE_PATH}/${1}-password

  # Remove rc-file from rc-files storage
  rm ${RC_FILES_STORAGE_PATH}/${1}.sh

  # Remove server list file from the servers-lists storage
  rm ${SERVERS_LISTS_STORAGE_PATH}/${1}-servers
}