#!/bin/bash	

# Move the Photos.app to the Users/macroot/Library/Applications_Hidden folder
# This will prevent users finding Photos in the Applications folder, it will also not show in a spotlight search.
# Will Pierce
# May 11, 2015

# check for the the Applications_Hidden folder
if [ ! -d "/Users/macroot/Library/Applications_Hidden/"]; then
	echo "/Users/macroot/Library/Applications_Hidden/ NOT found, creating..."

	# make the Applications_Hidden folder
	mkdir /Users/macroot/Library/Applications_Hidden/

	# Test to see that it was created
			if [ -d "/Users/macroot/Library/Applications_Hidden/"]; then
				echo "/Users/macroot/Library/Applications_Hidden/ created."
					else
						echo "Users/macroot/Library/Applications_Hidden/ NOT created something went wrong."
			fi
	else
		echo "/Users/macroot/Library/Applications_Hidden/ found."
fi

# Check to see if Photos.app is installed 
if [-e /Applications/Photos.app ]; then
	echo "Photos.app found moving to /Users/macroot/Library/Applications_Hidden"

	# Move the Photos app to Applications_Hidden
	mv /Applications/Photos.app /Users/macroot/Library/Applications_Hidden/

	# Test that it was moved
	# Make sure Photos.app is gone			Make sure Photos.app is now in /Users/macroot/Library/Applications_Hidden
	if [ ! -e /Applications/Photos.app ] && [ -e /Users/macroot/Library/Applications_Hidden/Phots.app ]; then
		echo "Photos.app moved from Applications folder to macroot/Library/Applications_Hidden successfully"
		else
			echo "something went wrong Photos.app not in Applications and not in /Users/macroot/Library/Applications_Hiddens"
	fi
else
	echo "Photos.app NOT found, nothing to move."
fi 

## Reminder: when moving applications they might still show in spotlight.
## Run the Spotlight erase and rebuild index script 
### SpotlightEraseAndRebuildIndexes.sh

exit 0