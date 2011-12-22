#!/bin/sh

base=`dirname $0`
source "$base/common.sh"

# tell the system to unload the injector
sudo launchctl unload "/Library/LaunchDaemons/${BUNDLE}.plist"

# remove injector
sudo rm -f "/Library/PrivilegedHelperTools/${BUNDLE}"

# remove launchctl plist
sudo rm -f "/Library/LaunchDaemons/${BUNDLE}.plist"

# remove the socket
sudo rm -f "/var/tmp/${BUNDLE}"
