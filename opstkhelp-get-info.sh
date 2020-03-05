#!/bin/bash

### This prog need to get info about rc-zones added earlier
### Functionality:
### 1) Print help : opstkhelp-get-info -h, --help
### 2) Display the names of all RC-zones: opstkhelp-get-info
### 3) Display the names of all the servers that are located in this RC-zone: opstkhelp-get-info RC_ZONE_NAME
### Other usage should return an error

# Add shared for all prog from package (for all opstkhelp-*)
source init.sh

