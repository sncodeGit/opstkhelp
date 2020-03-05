### This file adds (source) all the files listed below to all opstkhelp-* (utils)
### 'source init.sh' locate in all opstkhelp-* scripts

# Add some shared vars
source vars.sh
# Add some func for work with Openstack API
source ${SUBFUNCTIONS_PATH}/openstack_api_func.sh
# Add some func for work with local rc-zone storage
source ${SUBFUNCTIONS_PATH}/rc_zone_func.sh