#!/bin/bash
#### This script is copyright Tadd Torborg KA2DEW 2014, 2015, 2016, 2017, 2018
##### Please leave this copyright notice in the document and if changes are made,
##### indicate at the copyright notice as to what the intent of the changes was.
##### Thanks. - Tadd Raleigh NC

cd ~
echo "######"
sleep 0.5
echo "######"
sleep 0.5
echo "###### =TARPN START 2 STRETCH 008" #  --VERSION--#########
sleep 0.5
echo "######"
sleep 0.5
echo "######"
sleep 0.5
echo "######"
#### 012  fix echo stating the name of the instructions web page.
#### 013  change the final shutdown from shutdown -rF  to shutdown -r.    The F is not supported in Wheezy JESSIE.
#### JESSIE-101  add support for JESSIE.
#### JESSIE-102  call for FSCK at the end when we reboot.
#### JESSIE-103  add debug code for downloading tarpn.service.
#### JESSIE-104  add a check for a flag to make sure tarpn-start-1 completed.
#### JESSIE-105  add a note that you can ignore the NODE INIT error message
#### JESSIE-106  add PI SHUTDOWN service
#### JESSIE-107  Remove some excess copied stuff from PI SHUTDOWN installer
#### JESSIE-108  tarpn.log has moved to /var/log/tarpn.log.  Change where we cat the log from.
#### JESSIE-109  do update and dist-upgrade again, now that the boot firmware has been updated.
#### JESSIE-110  use com7 for tarpn host instead of com4
#### JESSIE-111  Put back com4 link to tty8  sudo ln -s /home/pi/minicom/com4 tty8
#### STRETCH-001  support for STRETCH
#### STRETCH-002  turn off systemctl status because that prompted the user for Q and we don't need it.
#### STRETCH-003  add some -y options to apt-get for updates and upgrades
#### STRETCH-004  add install of statusmonitor.sh and bbs checker application
#### STRETCH-005  install linktest-app and listen-app
#### STRETCH-006  add download of rx_tarpnstat, service, app and shellscript.  Change the name of the service downloads from the web site from .service to -service.txt
#### STRETCH-007  add download of sendroutestocq application.
#### STRETCH-008  Minor changes to fix bug K4RGN ran into around tarpn-service.txt
.  

if [ -f "/usr/local/sbin/tarpn_start1_finished.flag" ];
then
   sleep 1
   echo " --- "
   echo "###### TARPN START 1 completed ok.  We're almost done"
   echo " --- "
   sleep 1
else
   sleep 1
   echo " -- "
   echo " -- "
   echo " -- "
   echo "ERROR:   TARPN START 1 didn't finish.  Please restart the init"
   echo "         process and complain to the author."
   echo " -- "
   exit 1
fi

_source_url=$( cat /usr/local/sbin/source_url.txt );

rm -f ~/tarpn_start1*

sleep 1
echo -e "\n\n\n\n"
echo "#####"
echo "#####"
echo "##### APT-GET-UPDATE"
echo "#####   --- I know we just did this."
echo "#####   --- It won't take long if there is nothing to update."
cd ~
sleep 1
sudo apt-get -y update

sleep 1
echo -e "\n\n\n\n"
echo "#####"
echo "#####"
echo "##### APT-GET DIST-UPGRADE"
echo "#####"
echo "#####"
sleep 1
sudo apt-get -y dist-upgrade


### add "pi" user to the i2c group
echo "#####"
echo "#####"
echo "##### Add PI as a user to the i2c group"
echo "#####"
echo "#####"
sleep 1
sudo adduser pi i2c
sleep 1

echo "#####"
echo "#####"
echo "##### Set up minicom port linkage so minicom can find host port"
echo "#####"
echo "#####"
sleep 1
cd /etc
sudo ln -s /home/pi/minicom/com4 tty8
sleep 1

cd ~
sleep 1
echo
echo "##### Turn up the volume to max.  You can adjust amixer cset numid=1 -- 100%  "
amixer cset numid=1 -- 100%
echo
sleep 1


echo "######"
echo "######"
echo "######"
echo "######"
echo "######  Adding service for tarpn background operations"
echo "######"
sleep 1
echo "###### NOTE!   You will see an error message that says:"
sleep 1
echo "#######        NODE INIT file not found "
sleep 1
echo "#######    and  Aborting in 180 seconds"
sleep 1
echo "#######"
echo "#######     That's OK.  Nothing to see here.  These are not the"
echo "                        error messages you are looking for."
sleep 1
echo "            Move along..."
sleep 1
echo "########"

cd ~

if [ -f /etc/systemd/system/tarpn.service ];
then
   echo "ERROR!  TARPN SERVICE file already existed in /etc/system.d/system."
   echo "        If you got this message during a clean install, then"
   echo "        please send a missive about this to tarpn@groups.io."
   echo "ERROR: Aborting"
   exit 1;
fi

if [ -f ~/tarpn.service ];
then
   ls -lrats
   echo "ERROR!"
   echo "ERROR!  Premature existence of tarpn.service file in home directory"
   echo "        If you got this message during a clean install, then"
   echo "        please send a missive about this to tarpn@groups.io."
   echo "ERROR: Aborting"
   exit 1;
fi


if [ -f /var/log/tarpn.log ];
then
   echo "ERROR!"
   echo "ERROR!  Premature existence of tarpn.log file"
   echo "        If you got this message during a clean install, then"
   echo "        please send a missive about this to tarpn@groups.io"
   echo "ERROR: Aborting"
   exit 1;
fi

wget -o /dev/null $_source_url/tarpn-service.txt
##### now tarpn-service.txt should exist in the home directory
if [ -f ~/tarpn-service.txt ];
then
   echo " "
else
   ls -lrats
   echo "ERROR!  Failed to obtain TARPN-SERVICE.TXT from the web server."
   echo "        If you got this message during a clean install, then"
   echo "        please send a missive about this to tarpn@groups.io"
   echo "   Note: Outputting debug information to be relayed to debugger."
   pwd
   echo "url"
   echo $_source_url
   echo "ERROR: Aborting"
   exit 1
fi


_source_url=$( cat /usr/local/sbin/source_url.txt );
mv tarpn-service.txt tarpn.service
sudo mv tarpn.service /etc/systemd/system/tarpn.service
if [ -f /etc/systemd/system/tarpn.service ];
then
   echo "tarpn.service moved to system.d"
else
   echo " "
   echo " "
   echo " "
   pwd
   echo "/etc/systemd/system directory contains"
   ls -lrats /etc/systemd/system
   echo "local system /home/pi directory contains"
   ls -lrats 
   echo " "
   echo "ERROR!  TARPN SERVICE file failed to copy to /etc/system.d/system."
   echo "        If you got this message during a clean install, then"  
   echo "        please send a missive about this to tarpn@groups.io"
   echo "ERROR: Aborting"
   exit 1;
fi



### Download files related to automatic operation
wget -o /dev/null $_source_url/tarpn_background.sh
chmod +x tarpn_background.sh
sudo mv tarpn_background.sh /usr/local/sbin


#### Disable background execution of G8BPQ node
sudo rm -f /usr/local/etc/background.ini
sudo rm -f ~/bpq/background.ini
echo "BACKGROUND:OFF" > ~/background.ini
sudo mv ~/background.ini /usr/local/etc/background.ini
sudo chown root /usr/local/etc/background.ini

### Start TARPN service from the OS
echo "##### TARPN SERVICE file installed"
sudo systemctl daemon-reload
sudo systemctl enable tarpn.service
sudo systemctl start tarpn.service
echo "##### starting TARPN service  pause 10 seconds"
sleep 10
##sudo systemctl status tarpn.service
echo "###########################################################"
sleep 1
cat /var/log/tarpn.log
echo "###########################################################"
sleep 2




echo "######"
echo "######"
echo "######"
echo "######   PI SHUTDOWN SERVICE"
echo "######  Adding service for raspberry pi automatic shutdown and UP notification"
echo "######"
sleep 1
echo "########"

cd ~

if [ -f /etc/systemd/system/pi_shutdown-service.txt ];
then
   echo "ERROR!  PI SHUTDOWN SERVICE file already existed in /etc/system.d/system."
   echo "        If you got this message during a clean install, then"
   echo "        please send a missive about this to tarpn@groups.io."
   echo "ERROR: Aborting"
   exit 1;
fi

if [ -f ~/pi_shutdown.service ];
then
   echo "ERROR!"
   echo "ERROR!  Premature existence of pi_shutdown.service file in home directory"
   echo "        If you got this message during a clean install, then"
   echo "        please send a missive about this to tarpn@groups.io."
   echo "ERROR: Aborting"
   exit 1;
fi

wget -o /dev/null $_source_url/pi_shutdown-service.txt
##### now pi_shutdown-service.txt  should exist in the home directory
if [ -f ~/pi_shutdown-service.txt ];
then
   echo "got PI_SHUTDOWN-SERVICE.TXT"
else
   echo "ERROR!  Failed to obtain pi_shutdown.service from the web page."
   echo "        If you got this message during a clean install, then"
   echo "        please send a missive about this to tarpn@groups.io"
   echo "   Note: Outputting debug information to be relayed to debugger."
   ls -lrat
   pwd
   echo "url"
   echo $_source_url
   echo "ERROR: Aborting"
   exit 1
fi

mv pi_shutdown-service.txt pi_shutdown.service
sudo mv ~/pi_shutdown.service /etc/systemd/system/pi_shutdown.service
if [ -f /etc/systemd/system/pi_shutdown.service ];
then
### Download files related to automatic operation
   wget -o /dev/null $_source_url/pi_shutdown_background.sh
   chmod +x pi_shutdown_background.sh
   sudo mv pi_shutdown_background.sh /usr/local/sbin


### Start SHUTDOWN service from the OS
   echo "##### PI SHUTDOWN SERVICE file installed"
   sudo systemctl daemon-reload
   sudo systemctl enable pi_shutdown.service
   sudo systemctl start pi_shutdown.service
   echo "##### starting PI SHUTDOWN service  pause 10 seconds"
   sleep 10
   ##sudo systemctl status pi_shutdown.service
   echo "###########################################################"
   sleep 1
else
   echo "ERROR!  PI SHUTDOWN SERVICE file failed to copy to /etc/system.d/system."
   echo "        If you got this message during a clean install, then"
   echo "        please send a missive about this to tarpn@groups.io."
   echo "ERROR: Aborting"
   exit 1;
fi




###################################################
### Install listen-app application

########### INSTALL listen application
echo "##### starting install of listen-app"
cd /home/pi
rm -f listen-app*
wget -o /dev/null $_source_url/listen-app
if [ -f listen-app ];
then
    echo "##### received listen-app"
    chmod +x listen-app
    sudo mv listen-app /usr/local/sbin/listen
    echo -e "##### listen app has been installed.\n"
else
    echo "##### ERROR3.1   Did not receive listen-app. "
    echo "ERROR: Aborting"
    exit 1;
fi


###################################################
### Install linktest-app application

########### INSTALL linktest-app 
echo "##### starting install of linktest-app"
cd /home/pi
rm -f linktest-app*
wget -o /dev/null $_source_url/linktest-app
### Check if we have the linktest-app file now.
if [ -f linktest-app ];
then
    echo "##### received linktest-app"
    chmod +x linktest-app
    sudo mv linktest-app /usr/local/sbin/linktest
    echo -e "##### linktest-app has been installed.\n"
else
    echo "##### ERROR3.2   Did not receive linktest-app. "
    echo "ERROR: Aborting"
    exit 1;
fi





###################################################
### Install Status Monitor service, script, and bbs checker application

########### UPDATE sendroutestocq application
rm -f sendroutestocq
sudo killall sendroutestocq
wget -o /dev/null $_source_url/sendroutestocq
if [ -f sendroutestocq ];
then
    echo "##### received sendroutestocq  application"
    chmod +x sendroutestocq
    sudo mv sendroutestocq /usr/local/sbin/sendroutestocq
    echo -e "##### sendroutestocq application has been updated.\n"
else
    echo "##### ERROR44   Did not receive sendroutestocq. "
    echo "ERROR: Aborting"
    exit 1;
fi




########### INSTALL bbs_checker application
cd /home/pi
rm -f bbs_checker*
wget -o /dev/null $_source_url/bbs_checker
if [ -f bbs_checker ];
then
    echo "##### received bbs_checker  command script"
    chmod +x bbs_checker
    sudo mv bbs_checker /usr/local/sbin/bbs_checker
    echo -e "##### bbs_checker script has been installed.\n"
else
    echo "##### ERROR3   Did not receive bbs_checker. "
    echo "ERROR: Aborting"
    exit 1;
fi

###################################################
echo "#### get ring.wav file for bbs checker "
cd /home/pi
wget -o /dev/null $_source_url/ring.wav
sudo mv ring.wav /usr/local/sbin/ring.wav

###################################################
######## INSTALL statusmonitor.sh

### Delete a temporary downloaded copy of the script (may be left-over from failed install)
rm -f statusmonitor.sh*

### Get new copy of the script
wget -o /dev/null $_source_url/statusmonitor.sh
wget -o /dev/null $_source_url/statusmonitor-service.txt

### Check if we have the script file now.
if [ -f statusmonitor.sh ];
then
   echo "##### received STATUSMONITOR_BACKGROUND script"

   if [ -f /etc/systemd/system/statusmonitor.service ];
   then
      echo "#### ERROR8: statusmonitor service already existed!. "
      echo "##### Aborting"
      exit 1;
   else
      mv statusmonitor-service.txt statusmonitor.service
      sudo mv ~/statusmonitor.service /etc/systemd/system/statusmonitor.service
      if [ -f /etc/systemd/system/statusmonitor.service ];
      then
         echo "##### statusmonitor.service has been installed"
         echo "##### moving new background shell script file into place"
         chmod +x statusmonitor.sh
         sudo mv statusmonitor.sh /usr/local/sbin/statusmonitor.sh
         echo "##### STATUSMONITOR_BACKGROUND script has been installed."
         echo ##### start service
         sudo systemctl daemon-reload
         sudo systemctl enable statusmonitor.service
         sudo systemctl start statusmonitor.service
         echo "##### STATUSMONITOR_BACKGROUND script has been installed and the"
         echo "##### OS has been told to call it."
         echo -e "\n\n\n\n"
      else
         echo "##### ERROR9: statusmonitor.service was not installed"
         echo "##### Aborting"
         exit 1;
      fi
   fi
else
   echo "##### ERROR10   Did not receive STATUSMONITOR_BACKGROUND."
   echo
   echo "##### Aborting"
   exit 1;
fi
rm -f statusmonitor-service*
rm -f statusmonitor.service*
rm -f statusmonitor.sh*




###################################################
######## INSTALL RX_TARPNSTAT

### Delete a temporary downloaded copy of the script (may be left-over from failed install)
rm -f rx_tarpnstat.sh*

### Get new copy of the script
wget -o /dev/null $_source_url/rx_tarpnstat.sh
wget -o /dev/null $_source_url/rx_tarpnstat-service.txt

### Check if we have the script file now.
if [ -f rx_tarpnstat.sh ];
then
   echo "##### received rx_tarpnstat script"

   if [ -f /etc/systemd/system/rx_tarpnstat.service ];
   then
      echo "#### ERROR8b: rx_tarpnstat service already existed!. "
      echo "##### Aborting"
      exit 1;
   else
      mv rx_tarpnstat-service.txt rx_tarpnstat.service
      sudo mv ~/rx_tarpnstat.service /etc/systemd/system/rx_tarpnstat.service
      if [ -f /etc/systemd/system/rx_tarpnstat.service ];
      then
         echo "##### rx_tarpnstat.service has been installed"
         echo "##### moving new background shell script file into place"
         chmod +x rx_tarpnstat.sh
         sudo mv rx_tarpnstat.sh /usr/local/sbin/rx_tarpnstat.sh
         echo "##### STATUSMONITOR_BACKGROUND script has been installed."
         echo ##### start service
         sudo systemctl daemon-reload
         sudo systemctl enable rx_tarpnstat.service
         sudo systemctl start rx_tarpnstat.service
         echo "##### rx_tarpnstat script has been installed and the"
         echo "##### OS has been told to call it."
         echo -e "\n\n\n\n"
      else
         echo "##### ERROR9b: rx_tarpnstat.service was not installed"
         echo "##### Aborting"
         exit 1;
      fi
   fi
else
   echo "##### ERROR10b   Did not receive rx_tarpnstat.sh."
   echo
   echo "##### Aborting"
   exit 1;
fi
rm -f rx_tarpnstat-service*
rm -f rx_tarpnstat.service*
rm -f rx_tarpnstat.sh*


########### INSTALL rx_tarpnstatapp application
cd /home/pi
rm -f rx_tarpnstatapp*
wget -o /dev/null $_source_url/rx_tarpnstatapp
if [ -f rx_tarpnstatapp ];
then
    echo "##### received rx_tarpnstatapp  app"
    chmod +x rx_tarpnstatapp
    sudo mv rx_tarpnstatapp /usr/local/sbin/rx_tarpnstatapp
    echo -e "##### rx_tarpnstatapp app has been installed.\n"
else
    echo "##### ERROR3b   Did not receive rx_tarpnstatapp. "
    echo "ERROR: Aborting"
    exit 1;
fi






sleep 1
echo "#####"
sleep 1
echo "##### Done.  After reboot you will be ready to test and/or "
echo "##### configure your TNC-PI boards and to start BPQ node."
sleep 1
echo "#####"
echo "#####"



sleep 1;
echo "######"
echo "######"
echo "######"
echo "######"
echo "######      Raspberry PI will now reboot.  All is going well so far."
echo "######      When we come back up, reconnect and try the  tarpn  command"
echo "######      as per the   Initialize Raspberry PI for TARPN Node    web page"
sleep 1;
echo "######"
sleep 1;
echo "######"
echo "tarpn_start2" > /home/pi/tarpn_start2.flag;
sudo mv /home/pi/tarpn_start2.flag /usr/local/sbin/tarpn_start2.flag;



###### REBOOT in 4 seconds
sleep 4;
sudo touch /forcefsck
sudo shutdown -r now;
exit 0
