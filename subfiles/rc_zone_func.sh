### Check rc-zone name to correctness
### Using rules described in ${RC_ZONE_CONFIG_PATH}/rc_zones file
### Return 0 if this name is correct
### Return 1 if this name is incorrect
### Usage: check_rc_zone_name [RC_ZONE_NAME]
check_rc_zone_name(){
  if [ " " = *"$1"* ]
  then
    echo "' ' found"
  fi
  return 0
}

### Check for a buse RC-zone name 
### Return 0 if this zone wasn't added
### Return 1 if this zone was found in local storage
### Usage: check_rc_zone [RC_ZONE_NAME]
### Attention need to use check_rc_zone_name before
check_rc_zone(){
  # check_rc_zone_name $1
  return 0
}

### Add a new RC-zone 
### Returns nothing
### Usage: add_rc_zone [RC_ZONE_NAME] [RC_FILE] [RC_PASS]
### Attention: need to use check_rc_zone func before
add_rc_zone(){
  # check_rc_zone $1
  echo rc_zone
}