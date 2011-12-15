#!/bin/sh

# remove helper
sudo rm -f /Library/PrivilegedHelperTools/com.elegantchaos.helper.helper 

# remove launchctl plist
sudo rm -f /Library/LaunchDaemons/com.elegantchaos.helper.helper.plist
