#!/bin/bash	
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#	applicationMoveToHiddenFolder.sh -- Move an application to a hidden folder to hide it from users and spotlight.
#	This will make it easy to move it back or use as admin if needed.
#	Typically the library of a local admin account.
#
# SYNOPSIS
#
# 	If the $hiddenFolder parameter is specified (parameter 4), this is the folder that will be 
# 	checked for and if not found created.
#	Example:
#	/Users/yourlocaladminaccount/Library/Applications_Hidden/
#
#	If the $app parameter is specified (parameter 5), this is the application that will be 
# 	checked for and moved if to $hiddebFolder if found.
#
# If no parameter is specified for parameters 4 and 5, the hardcoded value in the script will be used.
#
# DESCRIPTION
#	This script checks for and creates a folder to move apps to that you don't want your users using
#	Like Photos or the App store, what have you. 
#	Spotlight does not typically search in the Library folder so depending on your environment 
#	you can move the apps to a local admin account if you have one.
####################################################################################################
#
# HISTORY
#
#	Version: 1.1
#
#	- Created by Will Pierce on May 12, 2015
#	- Modified 
#
####################################################################################################
#
# HARDCODED VALUES ARE SET HERE
# where do you want to move the app? Full path to a folder
# Example: hiddenFolder="/Users/macroot/Library/Applications_Hidden/"
# Leave blank to set in the script policy
# Example: hiddenFolder=""
#
hiddenFolder="/Users/macroot/Library/Applications_Hidden/"
#
# What app are you wanting to move?
# Example:
# app="Photos.app"
# Leave blank to set in the script policy
# Example app=""
app=""
#
####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################
#
# Check Parameter Values variables from the JSS
# Parameter 4 = path to the folder you want the app to move to.
# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "hiddenFolder"
if [ "$4" != "" ] && [ "$hiddenFolder" == "" ];then
    hiddenFolder=$4
fi

# Parameter 5 = Name of the app you want to move
# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 5 AND, IF SO, ASSIGN TO "app"
if [ "$5" != "" ] && [ "$app" == "" ];then
    app=$5
fi

# check for the the $hiddenFolder
if [ ! -d "$4" ]; then
	echo "$4 NOT found, creating..."

	# make the Applications_Hidden folder
	mkdir $4

	# Test to see that it was created
			if [ -d "$4" ]; then
				echo "$4 created."
					else
						echo "$4 NOT created, something went wrong."
						exit 1
			fi
	else
		echo "$4 found."
fi

# Check to see if $app is installed 
if [ -e /Applications/$5 ]; then
	echo "$5 found moving to $4"

	# Move the $app to Applications_Hidden
	mv /Applications/$5 $4

	# Test that it was moved
	# Make sure Photos.app is gone			Make sure Photos.app is now in /Users/macroot/Library/Applications_Hidden
	if [ ! -e /Applications/$5 ] && [ -e $4/$5 ]; then
		echo "$5 moved from Applications folder to $4 successfully"
		echo "Setting Spotlight to re index"
			# erase the Spotlight index
 			mdutil -E /

 			# turn Spotlight indexing off
 			mdutil -i off /

 			# turn Spotlight indexing back on
 			mdutil -i on /
		else
			echo "something went wrong $5 not in Applications and not in $4"
			exit 1
	fi
else
	echo "$5 NOT found, nothing to move."
fi 

exit 0