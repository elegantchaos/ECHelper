#!/bin/sh

base=`dirname $0`
source "$base/common.sh"

# tell the system to load the helper
sudo launchctl load /Library/LaunchDaemons/${BUNDLE}.plist

