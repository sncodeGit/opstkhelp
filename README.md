# opstkhelp
CLI utility to simplify working with the OpenStack API

# Short description
opstkhelp allows you to manage servers from different openstack zones (rc-zone).

You add all your rc-zones by passing opstkhelp the password and rc-file of that zone. Then you can manage all zones using a single program password, which is set during the installation of opstkhelp.

Using opstkhelp you can:
- start and stop servers with the same name located in different zones with `opstkhelp-manage-server`
- enter any OpenStack API commands for a specific zone, entering only the name of this zone using `opstkhelp-source-rc`

# Encryption
Zone passwords are encrypted. AES algorithm is used for encryption. For more information see `Documentation/encoding.png`

# Utils
**For more information, use the '--help' flag**
- `opstkhelp-add-rc`- add a new zone to local storage
- `opstkhelp-remove-rc` - remove zone from local storage
- `opstkhelp-get-info` - get a list of all added zones, servers or server information
- `opstkhelp-source-rc` - enter OpenStack API commands for a specific zone interactively
- `opstkhelp-manage-server` - start or stop the server with the entered name (from a specific zone or all servers with the entered name from all added zones)
- `opstkhelp-uninstall` - opstkhelp removal

# Installation
`git clone git@github.com:sncodeGit/opstkhelp.git`

`cd ./opstkhelp && ./install.sh`

`cd .. && rm -rf opstkhelp/`

# Uninstallation
`opstkhelp-uninstall`
