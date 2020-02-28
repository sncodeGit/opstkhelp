#!/usr/bin/expect -f
spawn $EXPECT_PASS_PATH/source_rc.sh
expect "Please enter your OpenStack Password:"
send '123\r'
