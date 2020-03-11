### Source rc-file (command: source (alias - .))
### Returns nothing
### Usage: api_source_rc_file [RC_PASS] [RC_FILE]
api_source_rc_file(){
  source "$2" &>/dev/null <<< "$1"
}

### Check password (first argument) RC-file for correctness
### Return 0 if password is correct
### Return 1 if password is incorrect
### Usage: api_chek_rc_pass [RC_PASS] [RC_FILE]
api_check_rc_pass(){
  api_source_rc_file "$1" "$2"

  STDERR=$(openstack server list --column Name --format value --sort-column Name 2>&1 1> /dev/null)

  if [ -z "$STDERR" ]
  then
    return 0
  else
    return 1
  fi
}

### Get all servers using rc-file
### Return API_GET_ALL_SERVERS var with the following sintax:
### ***
### FIRST_SERVER FIRST_SERVER_STATUS
### SECOND_SERVER SECOND_SERVER_STATUS
### ... (etc.)
### ***
### Usage: api_get_all_servers [RC_PASS] [RC_FILE]
api_get_all_servers(){
  api_source_rc_file "$1" "$2"
  API_GET_ALL_SERVERS=$(openstack server list --column Name --format value --sort-column Name)
}

### Get information about server
### Return API_GET_SERVER_INFO var
### Usage: api_get_server_info [RC_PASS] [RC_FILE] [SERVER_NAME]
api_get_server_info(){
  api_source_rc_file "$1" "$2"
  API_GET_SERVER_INFO=$(openstack server show --format shell ${3})
}