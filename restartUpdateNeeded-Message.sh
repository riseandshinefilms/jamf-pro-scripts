#!/bin/bash
#### Version 1.2
#### Message users to let them know they have updates waiting to install. Scope to smart group XX.
#### Will Pierce
#### January 14, 2015
#### Updated March 2, 2015
#### Requirements
#### jamfHelper

## Get the start time so we can find the time it takes for this all to run.
begin=$(date +"%s")

## Create a log file for trouble shooting 
LOGFILE="/Library/Logs/restartUpdateNeeded-Message.log"
echo "------------------------------------------------------------" >> $LOGFILE
#Get the date and set it to variable the_date
the_date=`date "+%Y-%m-%d %r"`

# enter the date to the log file
echo "$the_date" >> $LOGFILE

## Var for the last time user restarted and hit yes
UpdatesRunDate=`defaults read /Library/Preferences/com.cm.imaging UpdatesRunDate`
if [[ '$UpdatesRunDate' != "" ]]; then
   echo "Last restart & update was $UpdatesRunDate" >> $LOGFILE
else
   UpdatesRunDate="N/A"
   echo "Last restart & update was not found" >> $LOGFILE

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

## Check for JAMF waiting room, if so create variable for getting the results of waiting room command

if [ -d /Library/Application\ Support/JAMF/Waiting\ Room ];then
JAMF_WaitingRoom=`/bin/ls -1 /Library/Application\ Support/JAMF/Waiting\ Room/ 2> /dev/null | /usr/bin/grep -v ".cache.xml" | awk 1 ORS=' | '`
echo "----- Waiting Room: 
$JAMF_WaitingRoom" >> $LOGFILE
fi
## If nothing in the waiting room create variable for no set it to No updates
if [ "$JAMF_WaitingRoom" == "" ];then
JAMF_WaitingRoom="No 3rd party updates"
echo "Nothing in the waiting room. No 3rd party updates." >> $LOGFILE
## if we have something in the waiting room set variable no to nothing
else
no=""
fi

echo "" >> $LOGFILE


################################################
# Create a JAMF Helper window
jhPath="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

icon_folder="/Library/User Pictures"
logo_K="CM_Square.png"

## PREP MESSAGE

title="Important Action Required. Restart and click yes to finish installing important updates."
#heading="Important Action Required"

###### description
descrip="Available updates:
$JAMF_WaitingRoom
$appleUpdates

Mac OS can’t install updates while the system is running. Today at your convenience, please save your work, quit all applications, click the Apple icon in the top left of your screen & choose Restart, click yes when prompted. 

Your last restart & update was: $UpdatesRunDate. Best practice is to restart and click yes once a week. You will get this message once a day until you do. If you have questions please contact the helpdesk. EXT 6400 or helpdesk@collemcvoy.com
Thank you.
"
button_value="OK"

termin=$(date +"%s")
difftimelps=$(($termin-$begin))
echo "$(($difftimelps / 60)) minutes and $(($difftimelps % 60)) seconds elapsed for Script Execution." >> $LOGFILE

###### end description
## Create the pop up
response=`"$jhPath" -startlaunchd -windowType hud -title "$title" -description "$descrip" -button1 "I Understand" -lockHUD -icon "$icon_folder/$logo_K"`
if [ $response == 0 ];then
echo "User clicked \"I Understand\"" >> $LOGFILE
else
echo "User closed window." >> $LOGFILE
fi

#Script spacer - adds a line of ------ to the end of the log session
echo "------------------------------------------------------------" >> $LOGFILE
echo "" >> $LOGFILE



exit 0