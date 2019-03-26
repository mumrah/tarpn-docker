#!/bin/bash
#### This script is copyright Tadd Torborg KA2DEW 2014, 2015, 2016
##### Please leave this copyright notice in the document and if changes are made,
##### indicate at the copyright notice as to what the intent of the changes was
##### and send a copy to tadd@mac.com. 
##### Thanks. - Tadd Raleigh NC>  

##### This script is run from the command "tarpn test" or from the OS as an init service called by root.
##### This script depends on a source_url.txt file specifying where on the Internet
##### the boilerplate and scripts are found.  source_url.txt must exist even though
##### the Internet might be broken. If the Internet doesn't work, then we use 
##### the bpq32.cfg file created last time this script run.

##### If there is Internet, and source_url.txt is found, and node.ini is found, then
##### this script will attempt to download make_local_cfg.sh and boilderplate.cfg files 
##### from the URL specified in source_url.txt.  
##### If that fails, then just use the bpq32.cfg created previously.
##### If it successeds, then copy node.ini to the ~/bpq directory, and run the new make_local_cfg.sh
##### to create bpq32.cfg.

SCRIPTLOGFILE="/home/pi/scriptrun.log";
cd /home/pi/bpq;
echo "------"                 >> $SCRIPTLOGFILE;
echo "start of runbpq script" >> $SCRIPTLOGFILE;

### TARPN HOME shouldn't be running right now.  Stop it right now.  
check_process "python"
if [ $? -ge 1 ]; then
    sudo rm -rf /usr/local/sbin/home_web_app/remove_me_to_stop_server.txt
    sleep 5
fi
check_process "python"
if [ $? -ge 1 ]; then
    sudo killall python
    sleep 5
fi

#### VERSION NUMBER
echo "#### =RUNBPQ vJ005 =" #  --VERSION--#########
echo "###  RUNBPQ  vJ005"      >> $SCRIPTLOGFILE;

#### Version 42   -- add killall piminicom at start
#### Version 43   -- 2014-11-29  up until now, this script copied pilinbpq to linbpq and
####                 did the chmod+x and then ran linbpq.  Stop doing that.  Install should
####                 have taken care of all of that. 
#### Version 44   -- 2015-02-26 Add comments to designate when the boilerplate processing takes place.
#### Version 45   -- 2015-04-22 Fix error message which mentions node.ini to also mention tarpn config 
#### Version 46   -- 2015-05-27 Remove call for linbpq chat kludge for tadd node.   
#### Version J001 -- 2015-10-15 fix search for node.ini file
#### Version J002 -- 2015-10-15 fix where wget was deleting the script run logfile.
#### Version J003 -- 2016-01-16 Add an error message to the screen if couldn't construct bpq32.cfg.  Also move script log to home directory from bpq directory. 
#### Version J004 -  2019-01-13 STop TARPN-HOME on entry, just to make sure. 
#### Version J005 -- 2019-02-11 Don't delete the tarpn-home delete-me file if it is already deleted
###

### Grab the path saved in SOURCE URL for acquiring updated materials
if [ -f /usr/local/sbin/source_url.txt ];
then
    echo -n;
else
   echo "### ERROR0: source URL file not found."
   echo "### ERROR0: source URL file not found." >> $SCRIPTLOGFILE;

   echo "### ERROR0:" 
   echo "### ERROR0: Aborting"
   echo -en "\n\n\n\n###### RUNBPQ: bottom of script @ "     >> $SCRIPTLOGFILE;
   date >> $SCRIPTLOGFILE;
   echo -e "\n\n\n\n\n\n\n"     >> $SCRIPTLOGFILE;
   sleep 90;
   exit 1
fi

_source_url=$( cat /usr/local/sbin/source_url.txt );
echo "### Source URL=" $_source_url >> $SCRIPTLOGFILE;

sleep 2;                                                                                                                                                                                                                                                                                 
echo -n "### datetime="           >> $SCRIPTLOGFILE;
date  >> $SCRIPTLOGFILE;
echo "### hostname="$HOSTNAME     >> $SCRIPTLOGFILE;

######## Check to see if we have a node.ini configuration file -- if not, then abort the entire process
if [ -f "/home/pi/node.ini" ];
then
    echo -n;
else
   echo "### ERROR: node.ini not found in /home/pi.  Please do tarpn config"  >> $SCRIPTLOGFILE;
   echo "### ERROR: node.ini not found in /home/pi.  Please do tarpn config"
   date >> $SCRIPTLOGFILE;
   echo -e "\n\n\n\n\n\n\n"     >> $SCRIPTLOGFILE;
   echo "### pause 90"
   sleep 90;
   exit 1
fi;

cd /home/pi/bpq

######## Kill off any host session in progress. 
sudo killall piminicom

#############
#############   Update boilerplate from Internet, and then process NODE.INI key-value-pairs to generate custom TARPN config
#############

TEMP_LOG_FILE="/home/pi/temp_log_xfer_file.txt";
echo "#####  Going to fetch the test file from the web server"  >> $SCRIPTLOGFILE; 
sudo rm -f testfile.txt
rm -f $TEMP_LOG_FILE
sudo -u pi wget -o $TEMP_LOG_FILE $_source_url/testfile.txt;
cat $TEMP_LOG_FILE >> $SCRIPTLOGFILE

##### IF we have access to the Internet, then testfile.txt will have been received.  
if [ -f testfile.txt ];
then
   echo "### test-file retrieved from web server." >> $SCRIPTLOGFILE;
   
   ######### Take node.ini from the home directory and COPY it to bpq.  
   sudo -u pi cp /home/pi/node.ini /home/pi/bpq/node.ini
   sudo rm -f boilerplate.c*;
   sudo rm -f make_local_cfg.s*;

   ##### Download current copies of boilerplate.cfg and make_local_cfg.sh -- get connect results and log it.   
   rm -f $TEMP_LOG_FILE
   sudo -u pi wget -o $TEMP_LOG_FILE $_source_url/boilerplate.cfg;
   cat $TEMP_LOG_FILE >> $SCRIPTLOGFILE
   rm -f $TEMP_LOG_FILE
   sudo -u pi wget -o $TEMP_LOG_FILE $_source_url/make_local_cfg.sh;
   cat $TEMP_LOG_FILE >> $SCRIPTLOGFILE
   rm -f $TEMP_LOG_FILE

   ###### TEST to make sure we got boilerplate.cfg and make_local_cfg.sh
   if [ -f /home/pi/bpq/boilerplate.cfg ];
   then
     echo "### bpq config retrieved from webserver" >> $SCRIPTLOGFILE;
     
     if [ -f /home/pi/bpq/make_local_cfg.sh ];
     then
       echo "### make_local_cfg.sh  retrieved from webserver" >> $SCRIPTLOGFILE;
       sudo chmod +x make_local_cfg.sh;
       
       ######## make backup copies of bpq32.cfg
       sudo rm -f bpq32.o2;
       if [ -f bpq32.o1 ];
       then
          mv bpq32.o1 bpq32.o2;
       fi
       if [ -f bpq32.old ];
       then
          mv bpq32.old bpq32.o1;
       fi
       if [ -f bpq32.cfg ];
       then
          cp bpq32.cfg bpq32.old
       fi
       
       #### Run make_local_cfg.sh to create new bpq32.cfg
       if source /home/pi/bpq/make_local_cfg.sh;
       then
          echo "### make_local_cfg completed ok"  >> $SCRIPTLOGFILE;
       else
          echo "### ERROR: make_local_cfg returned FAIL!"  >> $SCRIPTLOGFILE;
       fi
     else
       echo "### ERROR: make_local.sh not found in /home/pi/bpq"  >> $SCRIPTLOGFILE;
     fi
   else
     echo "### ERROR: boilerplate NOT retrieved from webserver" >> $SCRIPTLOGFILE;
   fi
else
   echo "### testfile not found via Internet.  Run with local files only." >> $SCRIPTLOGFILE;
   if [ -f /home/pi/bpq/boilerplate.cfg ];
   then
     echo "### boilerplate config is available" >> $SCRIPTLOGFILE;
     
     if [ -f /home/pi/bpq/make_local_cfg.sh ];
     then
       echo "### /home/pi/bpq/make_local_cfg.sh  is available" >> $SCRIPTLOGFILE;
       sudo chmod +x make_local_cfg.sh;

       ######## make backup copies of bpq32.cfg
       sudo rm -f bpq32.o2;
       if [ -f bpq32.o1 ];
       then
          mv bpq32.o1 bpq32.o2;
       fi
       if [ -f bpq32.old ];
       then
          mv bpq32.old bpq32.o1;
       fi
       if [ -f bpq32.cfg ];
       then
          cp bpq32.cfg bpq32.old
       fi
       
       #### Run make_local_cfg.sh to create new bpq32.cfg
       if source /home/pi/bpq/make_local_cfg.sh;
       then
          echo "### make_local_cfg completed ok"  >> $SCRIPTLOGFILE;
       else
          echo "### ERROR: make_local_cfg returned FAIL!"  >> $SCRIPTLOGFILE;
          echo "### ERROR: Can't run.  See script-log"
       fi
     else
       echo "### ERROR: make_local.sh not found in /home/pi/bpq"  >> $SCRIPTLOGFILE;
       echo "### ERROR: Can't run.  See script-log"
     fi
   else
     echo "### ERROR: boilerplate NOT found" >> $SCRIPTLOGFILE;
     echo "### ERROR: Can't run.  See script-log"
   fi
fi
  
#############
#############   End of Custom TARPN config generation.  
#############


sudo rm -f /home/pi/bpq/temp*;
sudo rm -f /home/pi/bpq/node.ini;
sudo rm -f /home/pi/temp*
sudo rm -f /home/pi/bpq/tt*.tmp
sudo rm -f /home/pi/bpq/testfile.txt
sudo chmod 666 bpq32.cfg;
pwd >> $SCRIPTLOGFILE;
ls -lrat >> $SCRIPTLOGFILE;
sleep 1;

if [ -f bpq32.cfg ];
then
   echo "### launching bpq"      >> $SCRIPTLOGFILE;
   sudo setcap "CAP_NET_RAW=ep CAP_NET_BIND_SERVICE=ep" linbpq
   echo "#####"
   echo "#####  Launching G8BPQ node software.  Note, this script does not end"
   echo "#####  until the node is STOPPED/control-C etc.. "
   echo "#####"

   ###### run G8BPQ node -- this does not return until it is killed or quits
   ###### Run as user pi, even if we are called by the OS in the background
   sudo -u pi ./linbpq
   echo "##### G8BPQ LINBPQ has stopped running.  Back to runbpq.sh"
else
   echo "#### ERROR: Can't run.  See script-log"
   echo "#### ERROR: Incomplete configuration.  Is this the first run?"    >> $SCRIPTLOGFILE;
   echo "####        BPQ32.CFG does not exist.  It should by this time."   >> $SCRIPTLOGFILE; 
fi

### TARPN HOME shouldn't be running right now.  Stop it right now.  
if [ -f /usr/local/sbin/home_web_app/remove_me_to_stop_server.txt ];
then
   sudo rm -rf /usr/local/sbin/home_web_app/remove_me_to_stop_server.txt
fi
check_process "python"
if [ $? -ge 1 ]; then
    sleep 5
fi
check_process "python"
if [ $? -ge 1 ]; then
    sleep 5
fi
check_process "python"
if [ $? -ge 1 ]; then
    sleep 5
fi
check_process "python"
if [ $? -ge 1 ]; then
    sudo killall python
    sleep 1
fi

echo -en "\n\n\n\n###### RUNBPQ: bottom of script @ "     >> $SCRIPTLOGFILE;
date >> $SCRIPTLOGFILE;
echo -e "\n\n\n\n\n\n\n"     >> $SCRIPTLOGFILE;
