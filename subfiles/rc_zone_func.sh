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
  # Remove comments and empty strings from rc-zones file
  # Then read all symbols to first ':' symbol
  GET_ALL_ZONES=$(cat ${RC_ZONE_CONFIG_PATH}/rc-zones | sed -r '/^ *#/d' | sed -r '/^$/d' | cut -d ':' -f 1)
}

### Get the rc-zone password
### Gets the password from rc-zones file
### Return GET_ZONE_PASS var containing password
### Usage: get_zone_pass [RC_ZONE_NAME]
get_zone_pass(){
  GET_ZONE_PASS=$(cat ${RC_ZONE_CONFIG_PATH}/rc-zones | grep "^${1}:" | sed -r "s/^${1}://")
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

  # If there is colon (':') in the RC_ZONE_NAME
  if [[ "$1" == *':'* ]]
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

### Check password of added rc-zone (according to check_rc_pass func)
### Return 0 if password is correct
### Return 1 if password is incorrect
### Usage: check_zone_pass [RC_ZONE_NAME]
check_zone_pass(){
  # Get password of this zone
  get_zone_pass "$1" # Return GET_ZONE_PASS var

  # Check password of this zone
  check_rc_pass "$GET_ZONE_PASS" "${RC_FILES_STORAGE_PATH}/${1}.sh"
  
  # If password is correct
  if [ "$?" -eq 0 ]
  then
    return 0
  else
    return 1
  fi
}

### Get all servers from target rc-zone
### Return GET_ZONE_SERVERS var with the following sintax:
### *** 
### FIRST_SERVER
### SECOND_SERVER
### ... (etc.)
### ***
### Usage: get_zone_servers [RC_ZONE_NAME]
get_zone_servers(){
  # Get password of this zone
  get_zone_pass "$1" # Return GET_ZONE_PASS var

  # Get all servers from target rc-zone
  # Return GET_ALL_SERVERS var
  get_all_servers "$GET_ZONE_PASS" "${RC_FILES_STORAGE_PATH}/${1}.sh"

  GET_ZONE_SERVERS="$GET_ALL_SERVERS"
}

### Source (alias command - '.') zone with name passed as arh
### Returns nothing
### Usage: source_rc_zone [RC_ZONE_NAME]
source_rc_zone(){
  # Get password of this zone
  get_zone_pass "$1" # Return GET_ZONE_PASS var

  # Source ('.') rc-file of this rc-file
  source_rc_file "$GET_ZONE_PASS" "${RC_FILES_STORAGE_PATH}/${1}.sh"
}

### Add a new RC-zone 
### Returns nothing
### Usage: add_rc_zone [RC_ZONE_NAME] [RC_FILE] [RC_PASS]
### Attention: don't check rc-zone name (use check_rc_zone func)
add_rc_zone(){
  echo -en "\n$1:$3" >> "${RC_ZONE_CONFIG_PATH}/rc-zones"
  cp "$2" "$RC_FILES_STORAGE_PATH/$1.sh"
}

### Remove RC-zone from rc-zones file and rc-file from local storage
### Returns nothing
### Usage: remove_rc_zone [RC_ZONE_NAME]
remove_rc_zone(){
  sed -ri "/^${1}:.*$/d" "${RC_ZONE_CONFIG_PATH}/rc-zones"
  rm ${RC_FILES_STORAGE_PATH}/${1}.sh
}