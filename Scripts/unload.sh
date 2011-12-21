#!/bin/sh

base=`dirname $0`
source "$base/common.sh"

# tell the system to unload the helper
sudo launchctl unload /Library/LaunchDaemons/${BUNDLE}.plist

