#!/bin/bash

source vars.sh
export EXPECT_PASS_PATH

# User need help
if [ $# -eq 0 ] || [[ ("$1" == "-h" || "$1" == "--help") && $# -eq 1 ]]
then
    echo "$1"
    exit 0

# One arg and prog can read file (this arg)
elif [ $# -eq 1 ] && [ -r "$1" ]
then
  while [ true ]
  do
    echo "Please enter your OpenStack Password: "
    read -sr OS_PASSWORD
    # Try to use this password
    export OPSTKHELP_RC_FILE=$1
    $EXPECT_PASS_PATH/expect_pass.sh
    STDERR=$(openstack server list > /dev/null 2>&1)
    # If stderr is empty (so there were no errors)
    if [ -z "$STDERR" ]
    then
      echo "Successfully"
      exit 0
    fi
    # If stderr isn't empty (so there were errors)
    echo "Invalid password"
  done

# One arg and file (this arg) exists, but prog can't read it
elif [ $# -eq 1 ] && [ -f "$1" ]
then
  echo "The file was found, but the program cannot read it. Check file permissions."
  exit 1

# Usage error
else
  echo -e "Usage error or file '$1' not found. Use:\nopstkhelp-add-rc -h"
  exit 1
fi;