#!/bin/bash

#### Use this in self service so users can check on Apple and 3rd party updates
#### 3rd party updates must be cached via JAMFs JSS
#### Will Pierce
#### 140804
#### Updated February 23, 2015
## Get the start time so we can find the time it takes for this all to run.
begin=$(date +"%s")
#### Requirements
#### http://mstratman.github.io/cocoadialog/
CD_APP="/Applications/Utilities/CocoaDialog.app"
CD="$CD_APP/Contents/MacOS/CocoaDialog"

## Create a log file for trouble shooting 
LOGFILE="/Library/Logs/updatesCheckDisplay.log"
echo "------------------------------------------------------------" >> $LOGFILE

#Get the date and set it to variable the_date
the_date=`date "+%Y-%m-%d %r"`

# enter the date to the log file
echo "$the_date" >> $LOGFILE

######--------------------------------------------
# create a named pipe
rm -f /tmp/hpipe
mkfifo /tmp/hpipe
# create a background job which takes its input from the named pipe
$CD progressbar --indeterminate --debug --title "Checking for updates..." --text "Please wait..." --icon info < /tmp/hpipe &
# Send progress through the named pipe
exec 3<> /tmp/hpipe
/usr/sbin/jamf recon 2>&1 | while read line; do
# outPut=$( echo "$line" | sed 's/^[ ]*//g' )
outPut=$( echo "$line" )
if [ "$outPut" != "" ]; then
echo "$thePct $outPut" >&3
else
echo "$thePct Running recon..." >&3
fi
done

exec 3<> /tmp/hpipe
/usr/sbin/jamf policy 2>&1 | while read line; do
outPut=$( echo "$line" | sed 's/^[ ]*//g' )
if [ "$outPut" != "" ]; then
echo "$thePct $outPut" >&3
else
echo "$thePct checking for polices..." >&3
fi
done


# Wait 1 second before shutting off progress bar
sleep 1

# Turn off progress bar by closing file descriptor 3 and removing the named pipe
exec 3>&-
rm -f /tmp/hpipe

## Get current flash version
flash_major_version=`/usr/bin/curl --silent http://fpdownload2.macromedia.com/get/flashplayer/update/current/xml/version_en_mac_pl.xml | awk '/update version/ { print $2 }' | sed 's/.*"\(.*\)".*/\1/' | sed 's/,/./g'`

# get current installed flash version
FlashPluginInstalledVersion=`/usr/bin/defaults read /Library/Internet\ Plug-Ins/Flash\ Player.plugin/Contents/Info CFBundleVersion`

echo "" >> $LOGFILE # Add space to LOGFILE
echo "----- Flash version:" >> $LOGFILE
echo Current flash version $flash_major_version >> $LOGFILE
echo Installed flash version $FlashPluginInstalledVersion >> $LOGFILE

# Compare current flash to installed version of flash
if [ $flash_major_version = $FlashPluginInstalledVersion ]; then
	flashUpdate="Flash is up to date."
	else
		flashUpdate="Flash $flash_major_version update needed."
	fi

## Var for the last time user restarted and hit yes
UpdatesRunDate=`defaults read /Library/Preferences/com.cm.imaging UpdatesRunDate`
if [[ '$UpdatesRunDate' != "" ]]; then
   echo "Updates Run Date has run" >> $LOGFILE
else
   UpdatesRunDate="N/A"
fi

########## Apple Updates
echo "" >> $LOGFILE
echo "----- Apple Updates:" >> $LOGFILE

## Create a variable for Apple update command. 86 the lines we dont need.
appleUpdates=`softwareupdate -l | tail -n+6 |  sed -e 's/^[ \t]*//' | sed '/^*/ d' | sed 's/[[:space:]]//g'`

## If there are no Apple updates then set variable to No apple updates
if [ "$appleUpdates" == "" ];then
appleUpdates="No Apple Updates" 
echo "No Apple Updates" >> $LOGFILE

## If there are Apple updates set variable noau to nothing
else
noau=""
echo "$appleUpdates" >> $LOGFILE
fi
echo "" >> $LOGFILE

########## 3rd Party updates?

## Check for JAMF waiting room, if so create variable for getting the JAMF_WaitingRooms of waiting room command

if [ -d /Library/Application\ Support/JAMF/Waiting\ Room ];then
JAMF_WaitingRoom=`/bin/ls -1 /Library/Application\ Support/JAMF/Waiting\ Room/ 2> /dev/null | /usr/bin/grep -v ".cache.xml"`
echo "----- Waiting Room: 
$JAMF_WaitingRoom" >> $LOGFILE
fi
## If nothing in the waiting room create variable for no set it to No updates
if [ "$JAMF_WaitingRoom" == "" ];then
no="No 3rd party updates"
echo "Nothing in the waiting room. No 3rd party updates." >> $LOGFILE
## if we have something in the waiting room set variable no to nothing
else
no=""
fi

echo "" >> $LOGFILE

echo "----- 3rd party Updates:" >> $LOGFILE
echo "$JAMF_WaitingRoom" >> $LOGFILE

termin=$(date +"%s")
difftimelps=$(($termin-$begin))
echo "$(($difftimelps / 60)) minutes and $(($difftimelps % 60)) seconds elapsed for Script Execution." >> $LOGFILE

## Create a Cocoa Dialog text box window
rv=`$CD textbox --string-output ‑‑float --title "Updates" --informative-text "Checking for updates"  --button1 acknowledged --text "
Your last restart & update was on $UpdatesRunDate
Time to check your updates today was $(($difftimelps / 60)) minutes and $(($difftimelps % 60)) seconds.

3rd Party updates: 
$no$JAMF_WaitingRoom

$flashUpdate 

Apple Updates: 
$noau$appleUpdates

Mac OS can't install updates while the system is running.
If there are updates to install, simply restart and click "Yes".

Best practice is to restart and click yes once a week.

If you have questions please contact the help desk.
EXT 6400 or helpdesk@collemcvoy.com

Thank you.
"`
echo "User pressed the $rv button" >> $LOGFILE
echo "" >> $LOGFILE

exit 0