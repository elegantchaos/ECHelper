#!/bin/sh

# tell the system to unload the helper
sudo launchctl unload /Library/LaunchDaemons/com.elegantchaos.helper.helper.plist

# remove helper
sudo rm -f /Library/PrivilegedHelperTools/com.elegantchaos.helper.helper 

# remove launchctl plist
sudo rm -f /Library/LaunchDaemons/com.elegantchaos.helper.helper.plist
