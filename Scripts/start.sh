#!/bin/sh

base=`dirname $0`
source "$base/common.sh"

# start the helper script - in the example it just logs something to the console then quits
sudo launchctl start ${BUNDLE}
