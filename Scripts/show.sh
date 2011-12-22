#!/bin/sh

base=`dirname $0`
source "$base/common.sh"

echo HelperTools:
ls -l  "/Library/PrivilegedHelperTools/"

echo LaunchDaemons:
ls -l "/Library/LaunchDaemons/"

echo Sockets:
ls -l "/var/tmp/"

echo Plist
more "/Library/LaunchDaemons/${BUNDLE}.plist"

