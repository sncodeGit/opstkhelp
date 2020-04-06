# Include opstkhelp vars as a Makefile vars
include vars.env

# Makefile system vars
SHELL := /usr/bin/env bash

install: install_packages set_general_password copy_files_to_local_dir copy_scripts_to_bin_dir
	@ echo "Succesfully"

.PHONY: install install_packages set_general_password copy_files_to_local_dir copy_scripts_to_bin_dir

# Installing the required packages
install_packages: subfiles/requirements.txt
	@ cat subfiles/requirements.txt | xargs $(INSTALLATION_COMMAND)

# Get the general password from the user and create a file with its hash
set_general_password:
	@ echo -e "\nThe program uses encryption to store the password for added rc-zones"; \
	echo -e "Encryption uses a password (general password) that must be specified (and remembered) now"; \
	while [ true ]; \
	do \
	  echo -en "Enter the general password: "; \
	  read -sr OPSTKHELP_GENERAL_PASSWORD; \
	  echo -en "\nRepeate general password: "; \
	  read -sr OPSTKHELP_GENERAL_PASSWORD_SECOND; \
	  echo -en "\n"; \
	  if [[ "$$OPSTKHELP_GENERAL_PASSWORD" != "$$OPSTKHELP_GENERAL_PASSWORD_SECOND" ]]; \
	  then \
	    echo "Passwords do not match. Try retyping" >&2; \
	  else \
	    break; \
	  fi; \
	done; \
	touch shared_password && \
	echo $$OPSTKHELP_GENERAL_PASSWORD | openssl md5 -binary > shared_password

# Create dirs and copy required files to the local prog dir
copy_files_to_local_dir: set_general_password
	@ mkdir $(LOCAL_DIR) && \
	cp headers/* $(LOCAL_DIR) && \
	cp init.sh $(LOCAL_DIR) && \
	cp vars.env $(LOCAL_DIR) && \
	cp shared_password $(LOCAL_DIR) && \
	cp subfiles/uninstall_makefile $(LOCAL_DIR)/Makefile; \
	mkdir $(SUBFUNCTIONS_PATH) && \
	cp README/subfunctions $(SUBFUNCTIONS_PATH)/README && \
	cp subfiles/*\.sh $(SUBFUNCTIONS_PATH); \
	mkdir $(RC_FILES_STORAGE_PATH) && \
	cp README/rc-files $(RC_FILES_STORAGE_PATH)/README; \
	mkdir $(PASSWORDS_STORAGE_PATH) && \
	cp README/rc-passwords $(PASSWORDS_STORAGE_PATH)/README; \
	mkdir $(SERVERS_LISTS_STORAGE_PATH) && \
	cp README/servers-lists $(SERVERS_LISTS_STORAGE_PATH)/README

# Copy script files (opstkhelp-*) to local directory containing bin files
# Also add installation vars to config file 
# BIN_FILES_PATH - the directory where they were installed opstkhelp-*
copy_scripts_to_bin_dir:
	@ if [[ "$(BIN_FILES_PATH)" == "" ]]; \
	then \
	  WHOAMI=`whoami`; \
	  INSTALL_PATH=`echo $${PATH} | sed 'y/:/\n/' | grep $${WHOAMI} | head -n 1`; \
	else \
	  INSTALL_PATH=$(BIN_FILES_PATH); \
	fi; \
	cp opstkhelp-* $${INSTALL_PATH}; \
	echo -ne "\nBIN_FILES_PATH=\"$${INSTALL_PATH}\"" >> $(LOCAL_DIR)/vars.env;