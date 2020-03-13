#!/bin/bash

source vars.sh

# Installing the required packages
cat ${REQUIREMENTS_PATH}/requirements.txt | xargs sudo apt-get install

# Get users general password
echo -e "\nThe program uses encryption to store the password for added rc-zones"
echo -e "Encryption uses a password that must be specified (and remembered) now"
while [ true ]
do
  echo -en "Enter the general password: "
  read -sr OPSTKHELP_GENERAL_PASSWORD
  echo -en "\nRepeate general password: "
  read -sr OPSTKHELP_GENERAL_PASSWORD_SECOND
  echo -en "\n"
  if [[ "$OPSTKHELP_GENERAL_PASSWORD" != "$OPSTKHELP_GENERAL_PASSWORD_SECOND" ]]
  then
    echo "Passwords do not match. Try retyping:" >&2
  else
    break
  fi
done

mkdir ${LOCAL_DIR}

cp init.sh ${LOCAL_DIR}
cp vars.sh ${LOCAL_DIR}
cp headers/rc-zones ${LOCAL_DIR}
# Add users general password
touch ${LOCAL_DIR}/shared_password \
&& echo $OPSTKHELP_GENERAL_PASSWORD | openssl md5 -binary > ${LOCAL_DIR}/shared_password

mkdir ${SUBFUNCTIONS_PATH}
cp README/subfunctions ${SUBFUNCTIONS_PATH}/README
cp subfiles/*\.sh ${SUBFUNCTIONS_PATH}

mkdir ${RC_FILES_STORAGE_PATH}
cp README/rc-files ${RC_FILES_STORAGE_PATH}/README

mkdir ${PASSWORDS_STORAGE_PATH}
cp README/rc-passwords ${PASSWORDS_STORAGE_PATH}/README

mkdir ${SERVERS_LISTS_STORAGE_PATH}
cp README/servers-lists ${SERVERS_LISTS_STORAGE_PATH}/README

LOCAL_BIN_FILES_PATH=$(echo $PATH | sed 'y/:/\n/' | grep $(whoami) | sed '1d')
find . -name "opstkhelp-*" -exec cp \{\} "${LOCAL_BIN_FILES_PATH}" \;

echo "Succesfully"
exit 0