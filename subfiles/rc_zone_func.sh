### Check rc-zone name to correctness
### Using rules described in ${RC_ZONE_CONFIG_PATH}/rc_zones file
### Also checks if an empty string was passed
### Return 0 if this name is correct
### Return 1 if this name is incorrect
### Usage: check_rc_zone_name [RC_ZONE_NAME]
### Attention: not for use external
check_rc_zone_name(){
   # If RC_ZONE_NAME is empty
  if [[ "$1" == "" ]]
  then
    return 1
  fi
 
  # If there is space (' ') in the RC_ZONE_NAME
  if [[ $1 == *' '* ]]
  then
    return 1
  fi

  # If there is colon (':') in the RC_ZONE_NAME
  if [[ $1 == *':'* ]]
  then
    return 1
  fi
  
  # If there is sharp ('#') in the RC_ZONE_NAME
  if [[ $1 == *'#'* ]]
  then
    return 1
  fi
  return 0
}

### Check for a buse RC-zone name
### Also check rc-zone name to correctness according rc_zones (see check_rc_zone_name func)
### Return 0 if this zone wasn't added earlier
### Return 1 if this zone name is incorrect according check_rc_zone_name func
### Return 2 if this zone was found in local storage
### Usage: check_rc_zone [RC_ZONE_NAME]
check_rc_zone(){ 
  check_rc_zone_name "$1"
  if [ $? -eq 1 ]
  then
    return 1
  fi
  # Remove comments and empty strings from rc-zones file
  ZONE_NAMES=$(cat ${RC_ZONE_CONFIG_PATH}/rc-zones | sed -r '/^ *#/d' | sed -r '/^$/d' | cut -d ':' -f 1)
  for ZONE_NAME in $ZONE_NAMES
  do
    if [ "$ZONE_NAME" = "$1" ]
    then
      return 2
    fi
  done
  return 0
}

### Add a new RC-zone 
### Returns nothing
### Usage: add_rc_zone [RC_ZONE_NAME] [RC_FILE] [RC_PASS]
### Attention: don't check rc-zone name (use check_rc_zone func)
add_rc_zone(){
  echo -en "\n$1:$3" >> ${RC_ZONE_CONFIG_PATH}/rc-zones
  cp $2 $RC_FILES_STORAGE_PATH/$1.sh
}

### Remove RC-zone
### Attention: don't check rc-zone name (use check_rc_zone func)
remove_rc_zone(){
  echo
}