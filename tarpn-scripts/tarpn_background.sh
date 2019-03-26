#!/bin/bash

######## TARPN BACKGROUND script -- See VERSION # below. 
## This script is called from tarpn.service, which is a service control file.  
## tarpn.service controls the registry of this script and specifies that
## this script should be restarted if it ever quits.  
## This script is deployed to /usr/local/sbin and is redeployed by "tarpn update". 
##
## This script checks /usr/local/etc/background.ini for a token.  
## The token can either be BACKGROUND:OFF  or  BACKGROUND:ON
## If off, wait a while, then repeat the test.
## If on, then launch linbpq unless it is already running.  If running, log an error and repeat the token test. 

check_process() {
  #  echo "$ts: checking $1"
  [ "$1" = "" ]  && return 0
  [ `pgrep -n $1` ] && return 1 || return 0
}

waste_time_if_not_running() {
   if grep -q "BACKGROUND:OFF" /usr/local/etc/background.ini; 
   then
      sleep 5
      check_process "python"
      if [ $? -ge 1 ]; then
          echo "not running but PYTHON seems to still be running.  Remove the remove-me file" >> $LOGFILE
          sudo rm -rf /usr/local/sbin/home_web_app/remove_me_to_stop_server.txt
	  date >> $LOGFILE
          sleep 5
      fi
      check_process "python"
      if [ $? -ge 1 ]; then
          echo "but PYTHON is yet again still running.  killall python" >> $LOGFILE
          sudo killall python
	  date >> $LOGFILE
      fi
   fi
}

LOGFILE="/var/log/tarpn.log"
SOURCE_URL="/usr/local/sbin/source_url.txt"
NODE_INIT="/home/pi/node.ini"
######################################################################################## VERSION INFO ####################################################################################################
#### 11-17-2015 j101  Add DATE prints to once each loop after state is checked 
####  2-13-2016 j102  Add comments at the top of the file.  No changes.
####  3-17-2016 j103  Add lots more waste-time-if-not-running( ) calls.
####  6-15-2016 j104  change the path to the log file.
####  2-12-2017 j105  if node is not running, kill off the tarpn-home web-app 
####  2-14-2017 j106  Fix tarpn-home-kill to be proper kill file. if node is not enabled but is running, don't kill off tarpn-home.   
#### 11-04-2018 j107  Add I2C information to the log file each time this kicks off
#### 01-12-2018 s001  Fix call to grep which logged the port info at node-launch. 
#### 01-12-2018 s002  Fix call to grep which logged the port info at node-launch.   Added ports 6 through 12. 
#### 01-14-2018 s003  stop complaing about PYTHON running until we actually check. 
echo -ne "\n =tarpn_background s003= \n start:" >> $LOGFILE
date >> $LOGFILE
uptime >> $LOGFILE


###### Make sure we have a listed URL on the Internet for getting updates and configuration.  If not, wait 3 minutes and then exit
if [ -f $SOURCE_URL ];
then
    echo -n "source URL is " >> $LOGFILE
    cat $SOURCE_URL >> $LOGFILE
else
	echo "ERROR0: source URL file not found." >> $LOGFILE
	echo "ERROR0: Aborting in 180 seconds" >> $LOGFILE
	date >> $LOGFILE
	sleep 180
	exit 1
fi

###### Make sure we have a node.ini config file.  If not, wait 3 minutes and then exit
if [ -f $NODE_INIT ];
then
    echo -n "NODE-INIT file word count= " >> $LOGFILE
    wc $NODE_INIT >> $LOGFILE
else
	echo "ERROR0: NODE INIT file not found." >> $LOGFILE
	echo "ERROR0: Aborting in 180 seconds" >> $LOGFILE
	date >> $LOGFILE
	sleep 180
	exit 1
fi

################# LOOP HERE FOREVER
#### Top of loop -- check if we should be calling linbpq or just waiting for a while. 
while [ 1 ];
do
   if grep -q "BACKGROUND:ON" /usr/local/etc/background.ini; then
      echo "BPQ node is enabled to be run as a service" >> $LOGFILE
      check_process "linbpq"
      if [ $? -ge 1 ]; then
         echo -n "ERROR!! BPQ node is already running.  " >> $LOGFILE
	     date >> $LOGFILE
         sleep 100
         exit 0;
      else
         echo -ne "BPQ node is not already running-- call runbpq @" >> $LOGFILE
         date >> $LOGFILE
         tarpn i2c >> $LOGFILE
         grep -e port01 -e port02 -e port03 -e port04 -e port05 -e port06 -e port07 -e port08 -e port09 -e port10 -e port11 -e port12  /home/pi/node.ini >> $LOGFILE
         /usr/local/sbin/runbpq.sh
         echo -ne "back from runbpq @" >> $LOGFILE
         date >> $LOGFILE
         echo "send kill to the HOME web app" >> $LOGFILE
         check_process "python"
         if [ $? -ge 1 ]; then
             echo "PYTHON seems to still be running.  Remove the remove-me file" >> $LOGFILE
             sudo rm -rf /usr/local/sbin/home_web_app/remove_me_to_stop_server.txt
             date >> $LOGFILE
             sleep 5
         fi
         check_process "python"
         if [ $? -ge 1 ]; then
             echo "but PYTHON is yet again still running.  killall python" >> $LOGFILE
             sudo killall python
             date >> $LOGFILE
         fi
      fi
   else
      echo -n "BPQ node is NOT enabled to be run as a service@" >> $LOGFILE
      date >> $LOGFILE
      check_process "linbpq"
      if [ $? -ge 1 ]; then
         echo "Not enabled as a service, but is running" >> $LOGFILE
      else
         check_process "python"
         if [ $? -ge 1 ]; then
             echo "Not enabled and not running. Python seems to be running.  oops" >> $LOGFILE
             echo "PYTHON seems to still be running.  Remove the remove-me file" >> $LOGFILE
             sudo rm -rf /usr/local/sbin/home_web_app/remove_me_to_stop_server.txt
             date >> $LOGFILE
             sleep 5
         fi
         check_process "python"
         if [ $? -ge 1 ]; then
             echo "Not enabled and not running. Python seems to be running." >> $LOGFILE
             echo "PYTHON is yet again still running.  killall python" >> $LOGFILE
             sudo killall python
             date >> $LOGFILE
         fi
      fi
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
      waste_time_if_not_running 0  
   fi
done


