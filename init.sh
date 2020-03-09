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

### Check the password 
get_shared_password