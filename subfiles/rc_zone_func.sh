### Check 
check_rc_zone_name(){

}

### Check for a buse RC-zone name 
### Return 0 if this zone wasn't added
### Return 1 if this zone was found in local storage
### Usage: check_rc_zone [RC_ZONE_NAME]
### Attention need to use check_rc_zone_name before
check_rc_zone(){
  # check_rc_zone_name $1
}

### Add a new RC-zone 
### Returns nothing
### Usage: add_rc_zone [RC_ZONE_NAME] [RC_FILE] [RC_PASS]
### Attention: need to use check_rc_zone func before
add_rc_zone(){
  # check_rc_zone $1
}