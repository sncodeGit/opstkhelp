### Source rc-file (command: source (alias - .))
### Returns nothing
### Usage: source_rc_file [RC_PASS] [RC_FILE]
source_rc_file(){
  echo "$1" > /tmp/opstkhelp_pass
  source "$2" &> /dev/null < /tmp/opstkhelp_pass
  rm /tmp/opstkhelp_pass
}

### Check password (first argument) RC-file for correctness
### Return 0 if password is correct
### Return 1 if password is incorrect
### Usage: chek_rc_pass [RC_PASS] [RC_FILE]
check_rc_pass(){
  source_rc_file "$1" "$2"
  STDERR=$(openstack server list 2>&1 1> /dev/null)
  if [ -z "$STDERR" ]
  then
    return 0
  else
    return 1
  fi
}

### Get all servers using rc-file
### Return GET_ALL_SERVERS var with the following sintax:
### ***
### FIRST_SERVER FIRST_SERVER_STATUS
### SECOND_SERVER SECOND_SERVER_STATUS
### ... (etc.)
### ***
### Usage: get_all_servers [RC_PASS] [RC_FILE]
get_all_servers(){
  source_rc_file "$1" "$2"
  GET_ALL_SERVERS=$(openstack server list --column Name --column Status --format value --sort-column Name)
}