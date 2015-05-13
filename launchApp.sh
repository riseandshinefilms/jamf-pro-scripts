#!/bin/bash
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#	launchApp.sh -- Launch an application as current logged in user.
#
# SYNOPSIS
#
# 	Sudo -u $user open /Applications/$app
#	Example:
#	Sudo -u $user open /Applications/Outlook.app
#	If the $app parameter is specified (parameter 4), this is the application that will be Launched.
#
# If no parameter is specified for parameter 4 the hard coded value in the script will be used.
#
# DESCRIPTION
#	This script checks for the application, then if present launches it.
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#	- Created by Will Pierce on December 16, 2014
#	- Modified May 13, 2015
#
####################################################################################################
#
# HARDCODED VALUES ARE SET HERE
# $4
# What application do you want to launch? Use full name with .app no \ for spaces
# Example: app="OneDrive for Business.app"
# Leave blank to set in the script policy
# Example: app=""
#
app="Push Diagnostics.app"
#
# $5
# What is the name of the applications process? Use full name no \ for spaces
# Example: process="OneDrive for Business"
# Leave blank to set in the script policy
# Example: app=""
process="Push Diagnostics"
#
echo #Just a blank space to pretty up the logs
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################
#
## Get the currently logged in user
user=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`
#
# Check Parameter Values variables from the JSS
# Parameter 4 = Name of app to launch.
# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "app"
if [ "$4" != "" ] && [ "$app" == "" ];then
    app=$4
fi
#
# Parameter 5 = Name of apps process.
# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 5 AND, IF SO, ASSIGN TO "process"
if [ "$5" != "" ] && [ "$app" == "" ];then
    app=$5
fi
# Is this app installed? Check before trying to launch
echo ----
echo Checking for $app
	if [ -e /Applications/"$app" ]; then
			echo "$app found, checking that it is not already running..."
				
				if pgrep "$process" > /dev/null
					then
			    	echo "$app Running no need to launch."
			    	exit 0
				else
			    	echo "$app Not running launching..."
				fi

			## switch to the current logged in user launch app
			sudo -u $user open /Applications/"$app"
			#Test that it was launched
			echo "Checking that $app was launched..."
				if pgrep "$process" > /dev/null 
					then
		    		echo "Confirmed $app is Running"
		    	else 
		    		echo "Something went wrong $app not running."
		    		exit 1
				fi
	else 
		echo "$app not found can not launch."
		exit 1
	fi 
#
echo "$app launched successfully"
#
exit 0