#!/usr/bin/env bash

# Get path to this script from users current directory
OWN_PATH=$(echo $0 | sed "s/\/install\.sh//")
if [[ "${OWN_PATH}" == "" ]]
then
  OWN_PATH="."
fi

source ${OWN_PATH}/vars.env

# Installing the required packages
cat ${OWN_PATH}/subfiles/requirements.txt | xargs ${INSTALLATION_COMMAND}

# Get users general password
echo -e "\nThe program uses encryption to store the password for added rc-zones"
echo -e "Encryption uses a password (general password) that must be specified (and remembered) now"
while [ true ]
do
  echo -en "Enter the general password: "
  read -sr OPSTKHELP_GENERAL_PASSWORD
  echo -en "\nRepeate general password: "
  read -sr OPSTKHELP_GENERAL_PASSWORD_SECOND
  echo -en "\n"
  if [[ "$OPSTKHELP_GENERAL_PASSWORD" != "$OPSTKHELP_GENERAL_PASSWORD_SECOND" ]]
  then
    echo "Passwords do not match. Try retyping" >&2
  else
    break
  fi
done

# Create dirs and copy required files

mkdir ${LOCAL_DIR}

cp ${OWN_PATH}/headers/* ${LOCAL_DIR}

cp ${OWN_PATH}/init.sh ${LOCAL_DIR}
cp ${OWN_PATH}/vars.env ${LOCAL_DIR}

# Add users general password
touch ${LOCAL_DIR}/shared_password \
&& echo $OPSTKHELP_GENERAL_PASSWORD | openssl md5 -binary > ${LOCAL_DIR}/shared_password

mkdir ${SUBFUNCTIONS_PATH}
cp ${OWN_PATH}/README/subfunctions ${SUBFUNCTIONS_PATH}/README
cp ${OWN_PATH}/subfiles/*\.sh ${SUBFUNCTIONS_PATH}

mkdir ${RC_FILES_STORAGE_PATH}
cp ${OWN_PATH}/README/rc-files ${RC_FILES_STORAGE_PATH}/README

mkdir ${PASSWORDS_STORAGE_PATH}
cp ${OWN_PATH}/README/rc-passwords ${PASSWORDS_STORAGE_PATH}/README

mkdir ${SERVERS_LISTS_STORAGE_PATH}
cp ${OWN_PATH}/README/servers-lists ${SERVERS_LISTS_STORAGE_PATH}/README

# Copy script files (opstkhelp-*) to local directory containing bin files
if [[ "$BIN_FILES_PATH" == "" ]]
then
  BIN_FILES_PATH=$(echo $PATH | sed 'y/:/\n/' | grep $(whoami) | head -n 1)
fi
find ${OWN_PATH} -name "opstkhelp-*" -exec cp \{\} "${BIN_FILES_PATH}" \;

# Add installation vars to config file
# BIN_FILES_PATH - the directory where they were installed opstkhelp-*
echo -ne "\nBIN_FILES_PATH=\"${BIN_FILES_PATH}\"" >> ${LOCAL_DIR}/vars.env

echo "Succesfully"
exit 0