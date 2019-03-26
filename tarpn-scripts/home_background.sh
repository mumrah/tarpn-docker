#!/bin/bash

######## HOME BACKGROUND script -- See VERSION # below. 
###### Code written by Tadd Torborg  (callsign KA2DEW)  in February 2016 in support of  
###### NC4FG's TARPN-HOME project.  This runs on a Raspberry PI  

## This script is called from home.service, which is a service control file.  
## home.service controls the registry of this script and specifies that
## this script should be restarted if it ever quits.  
## This script is deployed to /usr/local/sbin and is redeployed by "tarpn update". 
##
## This script makes sure the nc4fg tarpn-home application is always running if the run token file is present. 
PATH_TO_TARPNHOME="/usr/local/sbin/home_web_app"
LOGFILE="/var/log/tarpn_home.log"
MYTOKEN="/usr/local/etc/home.ini"

check_process() {
  #  echo "$ts: checking $1"
  [ "$1" = "" ]  && return 0
  [ `pgrep -n $1` ] && return 1 || return 0
}

waste_time_if_not_running() {
   if grep -q "BACKGROUND:OFF" $MYTOKEN; 
   then
      ### TARPN HOME shouldn't be running right now.  Stop it right now.  
      check_process "python"
      if [ $? -ge 1 ]; then
          sudo rm -rf /usr/local/sbin/home_web_app/remove_me_to_stop_server.txt
          sleep 10
      fi
      check_process "python"
      if [ $? -ge 1 ]; then
          sudo killall python
      fi
      sleep 30;
   fi
}


waste_time_if_node_not_up() {
   check_process "linbpq"
   if [ $? -ge 1 ]; then
      ### node IS running.  waste very little time. 
      sleep 0.1
   else
      ### node is not running.  Waste some time. 
      ### TARPN HOME shouldn't be running right now.  Stop it right now.  
      check_process "python"
      if [ $? -ge 1 ]; then
          sudo rm -rf /usr/local/sbin/home_web_app/remove_me_to_stop_server.txt
          sleep 10
      fi
      check_process "python"
      if [ $? -ge 1 ]; then
          sudo killall python
      fi
      sleep 30;
   fi
}

######################################################################################## VERSION INFO ####################################################################################################
####  2-11-2017 j001  Start from pi_shutdown_background.sh
####  2-12-2017 j002  Check to make sure node is up before launching HOME web-app
####  2-12-2017 j003  Remote the remote-me file if we get back from HOME web-app.  Add > logfile when running HOME python 
####  2-12-2017 j004  run the python program as user PI
####  2-12-2017 j005  run the python program with python!  doh
####  2-12-2017 j006  move the web app to /usr/local/sbin/home_web_app
####  2-12-2017 j007  check to make sure "dateinstalled.txt" exists in the appropriate folder
####  3-26-2017 j008  fix version print so tarpn sysinfo can find it. 
####  1-10-2019 j009  call tarpn_home.pyc instead of server.pyc. 
####  1-13-2019 j010  delete remove-me-to-stop-server all over the place if linbpq isn't running.
####  1-13-2019 j011  do killall python variously when tarpn-home should not be running.
####  1-14-2019 j012  conditionally do the killall and remove remove-me file 
####  1-31-2019 j013  if not scheduled to run, leave it alone instead of doing kills 
####  2-17-2019 j014  put back kills if not scheduled to run, but check if running first and use remove-me file to stop. 
 
####  
echo -ne "\n home_background.sh --VERSION-- j014 - start:" >> $LOGFILE
date >> $LOGFILE
uptime >> $LOGFILE

if [ -f $PATH_TO_TARPNHOME/dateinstalled.txt ];
then
  echo "TARPN-HOME folder exists.  Good.. moving forward" >> $LOGFILE
else
  echo "TARPN-HOME does not exist! Exit/abort/run-for-the-hills! (for 3 minutes)" >> $LOGFILE
  sleep 180
  exit 1
fi

################# LOOP HERE FOREVER
#### Top of loop -- check if we should be calling home or just waiting for a while. 
while [ 1 ];
do
   ### TARPN HOME shouldn't be running right now.  Stop it right now.  
   check_process "python"
   if [ $? -ge 1 ]; then
       sudo rm -rf /usr/local/sbin/home_web_app/remove_me_to_stop_server.txt
       sleep 5
   fi
   check_process "python"
   if [ $? -ge 1 ]; then
       sudo killall python
   fi

   ### See if the file indicated by $MYTOKEN exists at all. 
   if grep -q "BACKGROUND" $MYTOKEN; then
      ### yes.. it exists
      sleep 0.5
   else
      ### it did not exist or it was corrupted
      rm -rf $MYTOKEN
      echo "BACKGROUND:OFF" >> $MYTOKEN
      echo "ERROR!! token file did not exist or did not contain BACKGROUND token" >> $LOGFILE
      echo -ne "        I took action to recreate the token file @" >> $LOGFILE
      date >> $LOGFILE
   fi
       

   if grep -q "BACKGROUND:ON" $MYTOKEN; then
      echo -ne "NC4FG TARPN-HOME is enabled to be run as a service @ " >> $LOGFILE
      date >> $LOGFILE
      #### See if the node is up.  If not, then we need to not launch HOME
      check_process "linbpq"
      if [ $? -ge 1 ]; then
         echo -n "node is running. Launch HOME web-app.  " >> $LOGFILE
	     date >> $LOGFILE
	     cd $PATH_TO_TARPNHOME
         rm -rf remove_me_to_stop_server.txt
         date > remove_me_to_stop_server.txt
         python tarpn_home.pyc >> /var/log/tarpn_home_webapp_copylog.log
         echo -ne "back from NC4FG TARPN-HOME @" >> $LOGFILE
         date >> $LOGFILE
         ls -lrat  >> $LOGFILE
         ### TARPN HOME shouldn't be running right now.  Stop it right now.  
         check_process "python"
         if [ $? -ge 1 ]; then
             sudo rm -rf /usr/local/sbin/home_web_app/remove_me_to_stop_server.txt
             sleep 5
         fi
         check_process "python"
         if [ $? -ge 1 ]; then
             sudo killall python
         fi
         sleep 10
         exit 0;
      else
         echo -ne "Node is not running.  Hold off on running HOME @ " >> $LOGFILE
         date >> $LOGFILE
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
         waste_time_if_node_not_up 0
      fi
   else
      echo -n "NC4FG TARPN-HOME is NOT enabled to be run as a service@" >> $LOGFILE
      date >> $LOGFILE
      check_process "python"
      if [ $? -ge 1 ]; then
           echo "but PYTHON seems to still be running.  Remove the remove-me file" >> $LOGFILE
      ###     sudo rm -rf /usr/local/sbin/home_web_app/remove_me_to_stop_server.txt
           date >> $LOGFILE
      ###     sleep 5
      fi
      ### check_process "python"
      ### if [ $? -ge 1 ]; then
      ###     echo "but PYTHON is yet again still running.  killall python" >> $LOGFILE
      ###     sudo killall python
      ###     date >> $LOGFILE
      ### fi
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
