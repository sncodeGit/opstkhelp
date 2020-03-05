#!/bin/bash

### This prog need to remove rc-zone from programm local storage
### Functionality:
### 1) Print help : opstkhelp-remove-rc -h, --help
### 2) Remove rc-zone:  opstkhelp-remove-rc RC_ZONE_NAME
### Other usage should return an error

# Add shared for all prog from package (for all opstkhelp-*)
source init.sh