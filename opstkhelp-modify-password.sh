#!/bin/bash

### This prog need to modify password of one of the rc-file from programm local storage
### Functionality:
### 1) Print help : opstkhelp-modify-password -h, --help
### 2) Modify password one of the RC-zones: opstkhelp-modify-password RC_ZONE_NAME
### Other usage should return an error

# Add shared for all prog from package (for all opstkhelp-*)
source init.sh