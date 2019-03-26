#!/bin/bash
#### This script is copyright Tadd Torborg KA2DEW 2014, 2015, 2016, 2017, 2018
##### Please leave this copyright notice in the document and if changes are made,
##### indicate at the copyright notice as to what the intent of the changes was.
##### Thanks. - Tadd Raleigh NC

##### This script is supposed to be called in a particular order with other scripts.
##### Start with the recipe on the tarpn web site.  This script is called from
##### tarpn_start1.sh.

sleep 1
echo "###### This is the tarpn_start1dl script"
sleep 1
echo "###### version number is:"
sleep 1
echo "###### tarpn_start1dl STRETCH 021"

#### 034 11/11/2014  -- move PITNC utilities to /usr/local/sbin
#### 035 11/29/2014  -- move ringfolder to ~/ringfolder instead of ~/bpq/ringFolder
####                    use amixer to set volume all the way up.
#### 036 12/28/2014  -- get wiringPi GPIO tools.
#### 037  2/17/2015  -- setting pitnc* to +x was missing the *.  Why?
#### 038  2/24/2015  -- fix unexpected "fi" after installing GPIO wiringPi tools.
#### 039  3/09/2015  -- fix spelling error in echo to output
#### 040  3/28/2015  -- remove wolfram-engine from the apt-get package manager.
#### 041  4/16/2015  --  add -y option to apt-get in 2 places where it was missing.
#### 042  05/08/2015 --  remove a bunch of packages that we don't need including omxplayer, scratch.
#### 043  06-24-2015 --  Always get the same version of G8BPQ from the _source_url.
#### 044  06-25-2015 --  apt-get libpcap-dev and libcap0.8 in support of later G8BPQ versions
#### 045  07-01-2015 --  fix bug where G8BPQ was downloaded to the home directory instead of to ~/bpq
#### JESSIE 001  10-14-2015 -- fix bug in installing libcap 0.8 where the -y option was misspelled -7
#### JESSIE 002  10-15-2015 -- get piTermTCP from the source-url rather than from BPQ directly.  Install it on the Desktop
#### JESSIE 003  10-15-2015 -- turn on syntax coloring in VIM
#### JESSIE 004  10-15-2015 -- stop installing i2ckiss - stop installing ax25-tools and ax25-apps -- improve echo pretty printing
#### JESSIE 005  10-17-2015 -- call for FSCK at final reboot
#### JESSIE 006  11-08-2015 -- put back install of ax25-tools and ax25-apps.  Needed for i2c tools.
#### JESSIE 007  01-16-2016 -- Add a FLAG at the end of the script to tell TARPN-START-2 that it can run.
#### JESSIE 008  03-04-2016 -- Add install of Direwolf
#### JESSIE 009  03-04-2016 -- remove TRIGGERHAPPY  (note-- this change was in the field under 008 without the version changing!)
#### JESSIE 010  06-10-2016 -- put back WiringPi GPIO-- removed for JESSIE 008 for unknown reasons
#### JESSIE 011  10-10-2016 -- remove LibreOffice
#### JESSIE 012  10-11-2016 -- forgot the -y in apt-get removing libreoffice.
#### JESSIE 013  11-13-2016 -- still forgot the -y.
#### JESSIE 014  11-13-2016 -- Add -y to autoremove.
#### JESSIE 015  11-14-2016 -- Add 'echo' and printed remarks around firmware updates and other updates near the end of the script.
#### JESSIE 016  11-16-2016 -- more pretty-printing.  Stop installing XRDP
#### JESSIE 017   2-12-2017 -- add some prints of "uptime"
#### JESSIE 018   5-07-2017 -- Add TARPN HOME + Tornado and Python stuff.
#### JESSIE 019   5-09-2017 -- Get pitnc utilities from tarpn site.  They are no longer on the tnc-x site.
#### JESSIE 020   6-11-2017 -- use com7 for tarpn host instead of com4.
#### JESSIE 021   6-11-2017 -- get piminicom.zip from tarpn.net instead of from dropbox
#### JESSIE 022   7-29-2017 -- add python configparser.
#### JESSIE 023   7-29-2017 -- test version.. stop removing the extra packages like wolfram and libreoffice
#### JESSIE 024   7-29-2017 -- home_background.sh was not being downloaded.  Fix that.
#### JESSIE 025   7-30-2017 -- Restore removal of extra packages. .
#### STRETCH 001   8-22-2017 -- Remove get of HTML files from dropbox.  Don't have a new source yet.  Change SourceURL to 2017aug
### STRETCH 002    8-23-2017 -- don't display status of the systemctl anymore.  That ends up with a user response required.
### STRETCH 003    8-24-2017 -- Get firmware upgrade before applying it.
### STRETCH 004    9-08-2017 -- get rid of a note about hitting Q during dist-upgrade
### STRETCH 005    9-09-2017 -- add uptime at start and end.
### STRETCH 006    9-18-2017 -- Disable the console GETTY service.
### STRETCH 007    9-20-2017 -- remove Direwolf from the install.  This was taking too long for people with slow Internet.
### STRETCH 008    9-20-2017 -- Turn on the uart in boot/config.txt
### STRETCH 009    9-27-2017 -- update BPQ code downloader from updateapps.sh of today.  BBS-ready
### STRETCH 010   10-02-2017 -- fix typo in downloading bpq
### STRETCH 011   10-03-2017 -- remove conditioning in HOME SERVICE install.  We know it isn't installed already
### STRETCH 012   10-16-2017 -- add some -y options to apt-get
### STRETCH 013    1-22-2017 -- stop doing rpi-update.
### STRETCH 014    4-09-2018 -- if linbpq fails to install, abort the installation.  Fix bug in bpq install where setcap is done in the wrong directory. Stop setting syntax on for VIM editor
### STRETCH 015    4-09-2018 -- Install TELNET client
### STRETCH 016    5-05-2018 -- add check for starttime stamp -- abort, or if not exist, create it with epoch time
### STRETCH 017    5-05-2018 -- fix start time.  had perimissions error. 
### STRETCH 018    5-12-2018 -- download make-local and boilerplate during install time.  This lets the first node commissioning/test be run with no internet?
### STRETCH 020    1-10-2019 -- update for TARPN HOME v2.0
### STRETCH 021    2-27-2019 -- Change web-server download from home.service to home-service.txt

sleep 1
echo -e "\n\n\n\n\n\n"
echo "#####"
echo "#####"
echo "##### Verify proper environment for running this script"
echo "#####"
echo "#####"
uptime

########## The caller was supposed to have set up a source-URL for a web repository on the Internet
########## from which we download more scripts and code.  If not, then we're not being called in the right order.
########## We're only supporting a particular startup sequence.

if [ -f /usr/local/sbin/source_url.txt ];
then
    echo -n;
else
        echo "ERROR0: source URL file not found."
        echo "ERROR0: Aborting"
        exit 1
fi
_source_url=$( cat /usr/local/sbin/source_url.txt );



########## This script is supposed to be called tarpn_start1.sh and should be located in the present working directory.
if [ -f tarpn_start1.sh ];
then
    rm -f tarpn_start1.sh;
else
        echo "ERROR0: Incorrect calling sequence.  Please see documentation."
        echo "ERROR0: Aborting"
        exit 1
fi

####### Make sure we are in the home/pi directory
if [ $PWD == "/home/pi" ];
then
    rm -f tarpn_start1.sh;
else
        echo "ERROR0: Incorrect calling sequence.  Please see documentation."
        echo "ERROR0: Aborting"
        exit 1
fi



if [ -f tarpn_start1dl.sh ];
then
   echo
else
   echo "ERROR:  Help.  I don't know where I am.  Is this tarpn_start1dl.sh  ?"
   echo "ERROR: Aborting"
   exit 1;
fi


###########  Get UNIX EPOCH TIME and write it to the card.  
if [ -f /usr/local/sbin/tarpn_start1dl_starttime.txt ];
then
   echo "##### Please start from NOOBs-lite"
   date +%s
   exit 1;
fi
date +%s > /home/pi/datetemp.txt
sudo mv /home/pi/datetemp.txt /usr/local/sbin/tarpn_start1dl_starttime.txt
echo -n "This SD card is "
cat /usr/local/sbin/tarpn_start1dl_starttime.txt


################ Download the next script.  If we can't get it, then don't proceed with the install.
sleep 1
echo -e "\n\n\n\n\n\n"
echo "##### get TARPN install script #2 to use at next reboot"
sleep 1
rm -f tarpn_start2.*
wget -o /dev/null $_source_url/tarpn_start2.sh
if [ -f tarpn_start2.sh ];
then
   echo "##### script 2 downloaded successfully"
   chmod +x tarpn_start2.sh;
   sudo mv tarpn_start2.sh /usr/local/sbin/tarpn_start2.sh;
else
   echo "ERROR:  Failure retrieving script #2.  Something is wrong"
   echo "ERROR: Aborting"
   exit 1;
fi


uptime


#### Disable the console GETTY service
sudo systemctl stop serial-getty@ttyAMA0.service
sudo systemctl disable serial-getty@ttyAMA0.service
sudo sed -i "s^enable_uart=0^enable_uart=1^" /boot/config.txt


#### Create a BPQ directory below /home/pi
echo "##### create bpq folder below /home/pi"

cd ~
rm -rf bpq
mkdir bpq
cd bpq

##### Get RUNBPQ.SH
echo "##### get RUNBPQ"
cd /home/pi
wget -o /dev/null $_source_url/runbpq.sh
if [ -f runbpq.sh ];
then
   echo "##### runbpq.sh downloaded successfully"
   chmod +x runbpq.sh;
   sudo mv runbpq.sh /usr/local/sbin/runbpq.sh;
   echo "#####"
else
   echo "ERROR: Failure retrieving runbpq.sh.  Something is wrong"
   echo "ERROR: Aborting"
   exit 1;
fi


#### Get CONFIGURE_NODE_INI.SH
echo "##### get CONFIGURE NODE"
cd /home/pi/bpq
wget -o /dev/null $_source_url/configure_node_ini.sh
if [ -f configure_node_ini.sh ];
then
   echo "##### configure_node_ini.sh downloaded successfully"
   chmod +x configure_node_ini.sh;
   echo "#####"
else
   echo "ERROR: Failure retrieving configure_node_ini.sh.  Something is wrong"
   echo "ERROR: Aborting"
   exit 1;
fi


#### Get BOILERPLATE.CFG
echo "##### get BOILERPLATE.CFG"
cd /home/pi/bpq
wget -o /dev/null $_source_url/boilerplate.cfg
if [ -f boilerplate.cfg ];
then
   echo "##### boilerplate.cfg downloaded successfully"
   echo "#####"
else
   echo "ERROR: Failure retrieving boilerplate.cfg.  Something is wrong"
   echo "ERROR: Aborting"
   exit 1;
fi


#### Get MAKE_LOCAL_CFG.SH
echo "##### get MAKE_LOCAL_CFG.SH"
cd /home/pi/bpq
wget -o /dev/null $_source_url/make_local_cfg.sh
if [ -f make_local_cfg.sh ];
then
   echo "##### make_local_cfg.sh downloaded successfully"
   chmod +x make_local_cfg.sh;
   echo "#####"
else
   echo "ERROR: Failure retrieving make_local_cfg.sh.  Something is wrong"
   echo "ERROR: Aborting"
   exit 1;
fi

#### Get CHATCONFIG.CFG
echo "##### get CHATCONFIG.CFG"
cd /home/pi/bpq
wget -o /dev/null $_source_url/chatconfig.cfg
if [ -f chatconfig.cfg ];
then
   echo "##### chatconfig.cfg downloaded successfully"
   echo "#####"
else
   echo "ERROR: Failure retrieving chatconfig.cfg.  Something is wrong"
   echo "ERROR: Aborting"
   exit 1;
fi



##### Get TARPN
echo "##### get TARPN script"
cd /home/pi
wget -o /dev/null $_source_url/tarpn
if [ -f tarpn ];
then
   echo "##### tarpn downloaded successfully"
   chmod +x tarpn;
   sudo mv tarpn /usr/local/sbin/tarpn;
   echo "#####"
else
   echo "ERROR:  Failure retrieving testbpq.  Something is wrong"
   echo "ERROR: Aborting"
   exit 1;
fi


#################################  Record the date and time that we HAVE been run.  This is used
#################################  to verify proper script operation as well as to note when this
#################################  node software package was brought up.
echo -e "\n\n\n\n\n\n"
echo "tarpn_start1dl" > /home/pi/tarpn_start1dl.flag;
echo "install date:" >> /home/pi/tarpn_start1dl.flag;
date >> /home/pi/tarpn_start1dl.flag;
sudo mv /home/pi/tarpn_start1dl.flag /usr/local/sbin/tarpn_start1dl.flag;

#### Now download some packages with the apt-get package manager
sleep 1
echo -e "\n\n\n\n\n\n"
echo "#####"
echo "#####"
uptime
echo "##### APT-GET UPDATE"
echo "#####"
echo "#####"
sleep 1
############## Do Package Update using apt-get package manager
###### apt-get update  retrieves a list showing the packages and versions available
sudo apt-get -y update


############# Delete some of the unnecessary bloatware that comes with the Raspbian install

sleep 1
echo -e "\n\n\n"
uptime
echo "############# Now remove some packages which take time to upgrade. "
echo -e "\n\n\n"
sleep 1
echo -e "\n\n\n"
uptime

echo "############# Remove Triggerhappy. "
echo -e "\n\n\n"
sleep 0.5
sudo apt-get -y remove triggeryhappy
sleep 0.5
echo -e "\n\n\n"
uptime

echo "############# Remove Libreoffice"
echo -e "\n\n\n"
sleep 0.5
sudo apt-get remove -y --purge libreoffice*
sleep 0.5
echo -e "\n\n\n"
uptime

echo "############# APT-GET CLEAN to remove more straggler stuff. "
echo -e "\n\n\n"
sleep 0.5
sudo apt-get clean
sleep 0.5
echo -e "\n\n\n"
uptime

echo "############# APT-GET AUTOREMOVE to remove more straggler stuff. "
echo -e "\n\n\n"
sleep 0.5
sudo apt-get -y autoremove
sleep 0.5
echo -e "\n\n\n"
uptime

echo "############# Remove Minecraft. "
echo -e "\n\n\n"
sleep 0.5
sudo apt-get -y remove minecraft-pi
sleep 0.5
echo -e "\n\n\n"
uptime

echo "############# Get rid of the wolfram-engine.  It takes forever to maintain it."
echo -e "\n\n\n"
sleep 0.5
sudo apt-get -y remove wolfram-engine
echo -e "\n\n\n\n\n\n"
uptime

echo "############# And SCRATCH and NUSCRATCH while we're at it."
echo -e "\n\n\n"
sleep 0.5
sudo apt-get -y remove nuscratch
sudo apt-get -y remove scratch
sleep 0.5
sleep 0.5
echo -e "\n\n\n"
uptime

echo "############# APT-GET CLEAN"
echo -e "\n\n\n"
sleep 0.5
sleep 0.5
sudo apt-get clean
echo -e "\n\n\n\n\n\n"
uptime

echo "############# AUTOREMOVE extra packages"
echo -e "\n\n\n"
sudo apt-get -y autoremove
sleep 0.5


###### apt-get dist-upgrade figures out what dependencies there are for packages
###### that have changed and adds and removes all packages such that the listed
###### packages are fully upgraded and will run.  -y says don't prompt for permission.
echo -e "\n\n\n\n\n\n"
echo "#####"
echo "#####"
echo "##### APT-GET dist-upgrade -- upgrade the OS and remaining packages"
echo "#####"
uptime
echo "#####"
sleep 0.5
sudo apt-get -y dist-upgrade
sleep 0.5
echo -e "\n\n\n"

echo "###### OK, big one done. "
sleep 1
uptime
sleep 1
echo -e "\n\n\n"
echo "############# Now start installing things we need. "
echo -e "\n\n\n"
sleep 1


echo "#####"
echo "#####"
echo "##### APT-GET install of ax25-tools"
echo "#####"
echo "#####"
sleep 1
sudo apt-get -y install ax25-tools
uptime


echo -e "\n\n\n\n\n\n"
echo "#####"
echo "#####"
echo "##### APT-GET install of ax25-apps"
echo "#####"
echo "#####"
sleep 1
sudo apt-get -y install ax25-apps
uptime

echo -e "\n\n\n\n\n\n"
echo "#####"
echo "#####"
echo "##### APT-GET install of i2c-tools"
echo "#####"
echo "#####"
sleep 1
sudo apt-get -y --force-yes install i2c-tools
uptime


echo -e "\n\n\n\n\n\n"
echo "#####"
echo "#####"
echo "##### APT-GET install of screen"
echo "#####"
echo "#####"
sleep 1
sudo apt-get -y install screen
uptime


echo -e "\n\n\n\n\n\n"
echo "#####"
echo "#####"
echo "##### APT-GET install of libcap2-bin"
echo "#####"
echo "#####"
sleep 1
sudo apt-get -y install libcap2-bin
uptime

echo -e "\n\n\n\n\n\n"
echo "#####"
echo "#####"
echo "##### APT-GET install of libpcap0.8"
echo "#####"
echo "#####"
sleep 1
sudo apt-get -y install libpcap0.8
uptime

echo -e "\n\n\n\n\n\n"
echo "#####"
echo "#####"
echo "##### APT-GET install of libpcap-dev"
echo "#####"
echo "#####"
sleep 1
sudo apt-get -y install libpcap-dev
uptime



echo -e "\n\n\n\n\n\n"
echo "#####"
echo "#####"
echo "##### APT-GET install of Minicom dumb terminal program"
echo "#####"
echo "#####"
sleep 1
sudo apt-get -y install minicom

uptime
echo -e "\n\n\n\n\n\n"
echo "#####"
echo "#####"
sleep 0.5



echo "##### install  G8BPQ's version of Minicom"
sleep 0.5
echo "#####"
echo "#####"
sleep 1
cd /home/pi
rm -Rf minicom
rm -f in*
mkdir minicom
cd minicom
wget -o /dev/null $_source_url/piminicom.zip
unzip piminicom.zip
chmod +x piminicom
wget -o /dev/null $_source_url/minicom.scr
cd /home/pi


uptime
echo -e "\n\n\n\n\n\n"
echo "#####"
echo "#####"
sleep 0.5
echo "##### APT-GET install of conspy"
sleep 0.5
echo "#####"
echo "#####"
sleep 1
sudo apt-get -y install conspy

uptime
echo -e "\n\n\n\n\n\n"
echo "#####"
echo "#####"
echo "##### APT-GET install of Telnet client"
echo "#####"
echo "#####"
sleep 0.5
sudo apt-get -y install telnet

uptime
echo
echo
echo "#####"
echo "#####"
echo "##### APT-GET install of VIM editor"
echo "#####"
echo "#####"
sleep 0.5
sudo apt-get -y install vim
###echo "syntax on" > .vimrc

### this was installed in SVN rev 16    my rev 041
### this was installed in SVN rev 41    my rev 045
### this was installed in SVN rev 125   my rev JESSIE 007
### this was missing in SVN rev 138     my rev JESSIE 008  no comments.  just missing.
echo
echo
echo "#####"
echo "#####"
echo "##### GIT: install GPIO wiringPi tools"
echo "#####"
echo "#####"
    git clone git://git.drogon.net/wiringPi
    cd wiringPi
    ./build

sleep 0.5
uptime

### ---  removed 9-20-2017 -- need to figure out a way to make this faster -- echo
### ---  removed 9-20-2017 -- need to figure out a way to make this faster -- echo
### ---  removed 9-20-2017 -- need to figure out a way to make this faster -- echo "#####"
### ---  removed 9-20-2017 -- need to figure out a way to make this faster -- echo "#####"
### ---  removed 9-20-2017 -- need to figure out a way to make this faster -- echo "##### DIREWOLF"
### ---  removed 9-20-2017 -- need to figure out a way to make this faster -- echo "#####"
### ---  removed 9-20-2017 -- need to figure out a way to make this faster -- echo "#####"
### ---  removed 9-20-2017 -- need to figure out a way to make this faster -- cd ~
### ---  removed 9-20-2017 -- need to figure out a way to make this faster -- wget -o /dev/null $_source_url/direwolf-master-18-03-20-355.zip
### ---  removed 9-20-2017 -- need to figure out a way to make this faster -- if [ -f direwolf-master-18-03-20-355.zip ];
### ---  removed 9-20-2017 -- need to figure out a way to make this faster -- then
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    sudo apt-get install libasound2-dev
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    ###sudo apt-get install socat
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    mkdir direwolf
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    cd direwolf
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    unzip ../direwolf*.zip
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    cd direwolf-master
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    make
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    cp CHANGES.md CHANGES.txt
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    cp doc/User-Guide.pdf .
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    cp doc/Raspberry-Pi-APRS.pdf .
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    cp doc/Raspberry-Pi-APRS-Tracker.pdf .
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    cp doc/APRStt-Implementation-Notes.pdf .
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    cp doc/A-Better-APRS-Packet-Demodulator-Part-1-1200-baud.pdf .
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    cp doc/A-Better-APRS-Packet-Demodulator-Part-2-9600-baud.pdf .
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    cp README.md README.txt
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    sudo make install
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    make install-conf
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    make install-rpi
### ---  removed 9-20-2017 -- need to figure out a way to make this faster -- else
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    echo "#### ERROR!!  DIREWOLF file not found in tarpn repository"
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --    echo "#### ERROR!!  Please notify tarpn@yahoogroups.com"
### ---  removed 9-20-2017 -- need to figure out a way to make this faster -- fi
### ---  removed 9-20-2017 -- need to figure out a way to make this faster --
### ---  removed 9-20-2017 -- need to figure out a way to make this faster -- sleep 0.5
### ---  removed 9-20-2017 -- need to figure out a way to make this faster -- uptime


#echo -e "\n\n\n\n\n\n"
#echo "#####"
#echo "#####"
#echo "##### APT-GET install of Remote Desktop service"
#echo "#####"
#echo "#####"
#sleep 0.5
#sudo apt-get -y install xrdp


#### done with package manager.  Now get some TNC-PI/KISS/I2C/G8BPQ specific programs.
echo -e "\n\n\n\n"
echo "#####"
echo "#####"
echo "##### Get PARAMS.ZIP from TARPN web site"
echo "#####"
echo "#####"
cd ~
wget -o /dev/null $_source_url/params.zip
#### wget -o /dev/null http://www.tnc-x.com/params.zip
unzip params.zip
chmod +x pitnc*
sudo mv pitnc* /usr/local/sbin

echo -e "\n\n\n\n"
echo "#####"
echo "#####"
echo "##### Get PI-LIN-BPQ"
echo "#####"
echo "#####"
sleep 0.5

latest_bpq_zipfile="bpq_6_0_14_12_sep_2017.zip"
latest_bpq_file="pilinbpq.dms"
update_directory="update_bpq_dir"



cd ~/bpq
echo "latest bpq zipfile name is " $latest_bpq_zipfile
echo "latest bpq file name is " $latest_bpq_file
sudo rm -rf $update_directory
echo "### adding a new update directory"
mkdir $update_directory
cd $update_directory
echo "### cd into new update directory"
echo -e "### current working directory is "
pwd
echo "### Now download the newest BPQ version"
echo -e "getting it from" $_source_url
wget -o /dev/null $_source_url/$latest_bpq_zipfile
echo "### ZIPfile supposedly downloaded.  Directory now has:"
ls -lrats

if [ -f $latest_bpq_zipfile ];
then
   echo "## Got new version of pilinbpq in update directory ##"
   pwd
   unzip $latest_bpq_zipfile
   ls -lrat
   echo "## Rename to linbpq and make it executable ##"
   cp $latest_bpq_file linbpq
   chmod +x linbpq
   pwd
   ls -lrat *nbpq
else
   echo "### ERROR: we failed to download the required zip file!"
   echo "### Complain to tadd@mac.com! Send this entire log file if you can."
   exit 1;
fi
cd ~/bpq
echo "#### redundantly asking for removal of previous install"
echo "#### error messages expected"

sudo rm -f linbpq
sudo rm *.zip
sudo rm -Rf HTMLPages
sudo rm -Rf HTML
cd $update_directory
mv *.zip ..
mv linbpq ..
mv HTMLPages ~/bpq/HTML
cd ~/bpq
sudo setcap "CAP_NET_RAW=ep CAP_NET_BIND_SERVICE=ep" linbpq
echo "##### linbpq updated"
pwd
ls -lrat *nbpq
echo -n "new version (./linbpq -v): "
./linbpq -v

echo "##### Got pi lin bpq"
sleep 1



############################# Get piTermBPQ  -- node operations console

echo -e "\n\n\n\n"
echo "#####"
echo "#####"
echo "##### Get PiTermBpq"
echo "#####"
echo "#####"
cd ~
wget -o /dev/null $_source_url/piTermTCP.zip
if [ -f piTermTCP.zip ];
then
    unzip piTermTCP.zip
    rm -f piTermTCP.zip
    chmod +x piTermTCP
    mv piTermTCP ~/Desktop
    echo "##### piTermTCP has been installed."
else
        echo "ERROR1    Something is wrong.  I had access to the proper web site but could"
        echo "          not acquire the piTermTCP program from that web site."
        echo "          Abort!  Contact KA2DEW and note this issue. "
        echo
        exit 1;
fi
rm -f piTermTCP.zip
sleep 0.5

################## Get Ring noises folder
echo -e "\n\n\n\n"
echo "#####"
echo "#####"
echo "##### Get ring noises"
echo "#####"
echo "#####"
cd ~
rm -f ringnoises.zip
wget -o /dev/null $_source_url/ringnoises.zip
if [ -f ringnoises.zip ];
then
    rm -rf ringfolder
    mkdir ringfolder
    cd ringfolder
    unzip ../ringnoises.zip
    cd ..
    rm -f ringnoises.zip
    echo "##### RING Noises folder has been downloaded."
else
        echo "ERROR1    Something is wrong.  I had access to the proper web site but could"
        echo "          not acquire the ringnoises folder from that web site."
        echo "          Abort, no changes."
        echo
        exit 1;
fi
rm -f ringnoises.zip
sleep 0.5

##### Set volume to max
amixer set PCM -- -0000



### This should be put back!! ### echo -e "\n\n\n\n"
### This should be put back!! ### echo "#####"
### This should be put back!! ### echo "#####"
### This should be put back!! ### echo "##### Get HTML Config files from DropBox"
### This should be put back!! ### echo "#####"
### This should be put back!! ### echo "#####"
### This should be put back!! ### sleep 0.5
### This should be put back!! ### cd ~/bpq
### This should be put back!! ### mkdir HTML
### This should be put back!! ### cd HTML
### This should be put back!! ### wget -o /dev/null https://dl.dropbox.com/u/31910649/HTMLPages.zip
### This should be put back!! ### unzip H*.zip
echo -e "\n\n\n\n"
uptime
echo "#####"
echo "#####"
echo "##### Get Change Keyboard to US version"
echo "#####"
echo "#####"
cd ~
sudo sed -i 's/XKBLAYOUT="gb"/XKBLAYOUT="us"/' /etc/default/keyboard



#### Install telnet client
sleep 0.5
echo -e "\n\n\n\n"
uptime
echo "##### Install TELNET client"
sleep 0.5

#### In cmdline.txt, stop using tty-async-serial as the console port
### before: dwc_otg.lpm_enable=0 console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p6 rootfstype=ext4 elevator=deadline rootwait
sleep 0.5
echo -e "\n\n\n\n"
uptime
echo "#####"
echo "#####"
echo "##### Remove config for having tty-async-serial as console port from /boot/cmdline.txt"
echo "#####"
echo "#####"
sleep 0.5
sudo sed -i "s~console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 ~~" /boot/cmdline.txt
### after: dwc_otg.lpm_enable=0 console=tty1 root=/dev/mmcblk0p6 rootfstype=ext4 elevator=deadline rootwait


#### raspi-blacklist.conf  remove the i2c blacklisting
sleep 0.5
echo -e "\n\n\n\n"
uptime
echo "#####"
echo "#####"
echo "##### in /etc/modprobe.d/raspi-blacklist.conf, remove blacklisting of i2c"
echo "#####"
echo "#####"
sleep 0.5
sudo sed -i "s~blacklist i2c-bcm2708~~" /etc/modprobe.d/raspi-blacklist.conf

#### Add i2c-dev to the /etc/modules file
sleep 1
echo -e "\n\n\n\n"
uptime
echo "#####"
echo "#####"
echo "##### in /etc/modules, add i2c device"
echo "#####"
echo "#####"
sleep 1
cp /etc/modules modules.work
echo "i2c-bcm2708" >> modules.work
echo "i2c-dev" >> modules.work
sudo mv modules.work /etc/modules
sudo chown root /etc/modules
sudo chgrp root /etc/modules
sudo chmod 644 /etc/modules


#### Remove the getty on tty2.  We're going to use that to output a log file from linbpq
#sleep 1
#echo
#echo
#echo "#####"
#echo "#####"
#echo "##### in /etc/inittab, stop spawning a GETTY on tty2"
#echo "##### so we can use tty2 for log output from LINBPQ"
#echo "#####"
#echo "#####"
#sleep 1
#sudo sed -i "s=2:23:respawn:/sbin/getty 38400 tty2=#2:23:respawn:/sbin/getty 38400 tty2=" /etc/inittab




##### Remove some temporary files.
sleep 1
uptime
echo -e "\n\n\n\n"
echo "#####"
echo "#####"
echo "##### Remove temporary files"
echo "#####"
echo "#####"
sleep 1
rm -f *.zip


##### link /dev/tty8 to the virtual port created by linbpq
sleep 1
echo -e "\n\n\n\n"
uptime
echo "#####"
echo "#####"
echo "##### Link comm ports together for minicom"
echo "#####"
echo "#####"
sleep 1
sudo mv /dev/tty8 /dev/tty8a
sudo ln -s /home/pi/com7 /dev/tty8


####### NC4FG TARPN HOME #######################################################################################
####### NC4FG TARPN HOME #######################################################################################
####### NC4FG TARPN HOME #######################################################################################
sleep 1
echo -e "\n\n\n\n"
uptime
echo "#####"
echo "#####"
echo "##### NC4FG TARPN HOME installation"
echo "#####"
echo "#####"
sleep 1



echo "##### Get new copy of TARPN-HOME and move it into place"

cd /home/pi
sudo rm -rf temporary_home_web_app
mkdir temporary_home_web_app
cd temporary_home_web_app
wget /dev/null $_source_url/tarpn_home_current.zip
if [ -f tarpn_home_current.zip ];
then
  echo "TARPN-HOME has been downloaded"
else
  echo "TARPN-HOME download failed.  Abort install!"
  exit 1
fi
unzip tarpn_home_current.zip
echo -ne "pwd="
pwd
ls -lrat
echo -ne "pwd="
pwd 

sudo rm -f /home/pi/tarpn-home-colors.json
sudo rm -f /home/pi/TARPN_Home.ini
sudo rm -f /home/pi/TARPN_Home.ini
sudo rm -f /home/pi/tarpn-home-colors.json
sudo rm -f /home/pi/TARPN_Home_Chat.log
sudo rm -f /home/pi/TARPN_Home_Chat_Raw.log
sudo rm -f /home/pi/TARPN_Home_Node.log
sudo rm -rf /usr/local/sbin/home_web_app/remove_me_to_stop_server.txt
sudo rm -rf /usr/local/sbin/home_web_app

cd /usr/local/sbin
sudo rm -rf home_web_app
sudo mkdir home_web_app
sudo chmod 777 home_web_app


cd /usr/local/sbin/home_web_app
sudo date > dateinstalled.txt
if [ -f /usr/local/sbin/home_web_app/dateinstalled.txt ];
then
  echo "TARPN-HOME folder is created in /usr/local/sbin"
else
  echo "TARPN-HOME folder create failed.  Abort install!"
  exit 1
fi

sudo mv /home/pi/temporary_home_web_app/* .
sudo chown root *
sudo chmod +r *
echo -ne "pwd="
pwd
ls -lrat
echo -ne "pwd="
pwd
cd /usr/local/sbin
sudo chmod 755 home_web_app
cd /home/pi
echo -ne "pwd="
pwd

sudo rm -rf /home/pi/temporary_home_web_app











echo -e "\n\n\n\n\n\n"
echo "##### Install Python-dev, pyserial, and python-serial"

# updates Python. Only needed for dev? IDK.
echo "#####"
echo "#####"
echo "##### APT-GET install of python-dev"
echo "#####"
echo "#####"
sleep 1
sudo apt-get -y install build-essential python-dev


# Installs tornado web server
echo "#####"
echo "#####"
echo "##### PIP install of pyserial, tornado, and multiprocessing"
echo "#####"
echo "#####"
sleep 1
sudo pip install pyserial tornado multiprocessing


echo "#####"
echo "#####"
echo "##### PIP install of singledispatch and backports_abc"
echo "#####"
echo "#####"
sleep 1
sudo python -m pip install singledispatch backports_abc

# Installs serial interface
echo "#####"
echo "#####"
echo "##### APT-GET install of python-serial and python3-serial"
echo "#####"
echo "#####"
sleep 1
sudo apt-get -y install python-serial python3-serial



echo "#####"
echo "#####"
echo "##### APT-GET install of python-configparser"
echo "#####"
echo "#####"
sleep 1
sudo apt-get install -y python-configparser



sleep 1
echo -e "\n\n\n\n\n\n"
echo "##### Install the OS service for the TARPN Home"
cd /home/pi

echo "######"

cd ~

if [ -f /etc/systemd/system/home.service ];
then
   echo "ERROR!  home SERVICE file already existed in /etc/system.d/system."
   echo "        If you got this message during a clean install, then"
   echo "        please send a missive about this to tarpn@tarpn@groups.io"
   echo "ERROR: Aborting"
   exit 1;
fi

if [ -f ~/home.service ];
then
   echo "ERROR!"
   echo "ERROR!  Premature existence of home.service file in home directory"
   echo "        If you got this message during a clean install, then"
   echo "        please send a missive about this to tarpn@groups.io "
   echo "ERROR: Aborting"
   exit 1;
fi


wget -o /dev/null $_source_url/home_background.sh
wget -o /dev/null $_source_url/home-service.txt
##### now home_background.sh should exist in the home directory
if [ -f ~/home_background.sh ];
then
   echo " "
else
   echo "ERROR!  Failed to obtain home_background.sh from the web page."
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
##### now home-service.txt should exist in the home directory
if [ -f ~/home-service.txt ];
then
   echo " "
else
   echo "ERROR!  Failed to obtain home-service.txt from the web page."
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

chmod +x home_background.sh
sudo mv home_background.sh /usr/local/sbin/home_background.sh
mv home-service.txt home.service
sudo mv ~/home.service /etc/systemd/system/home.service
if [ -f /etc/systemd/system/home.service ];
then
### Download files related to automatic operation
   ### wget -o /dev/null $_source_url/home.sh          // take this out aug 22 2017
   chmod +x home_background.sh
   sudo mv home_background.sh /usr/local/sbin

### Start HOME service from the OS
   echo "##### NC4FG's TARPN-HOME SERVICE file installed"
   sudo systemctl daemon-reload
   sudo systemctl enable home.service
   sudo systemctl start home.service
   echo "##### starting home service  pause 10 seconds"
   sleep 10
   ##sudo systemctl status home.service
   echo "###########################################################"
   sleep 1
else
   echo "ERROR!  HOME SERVICE file failed to copy to /etc/system.d/system."
   echo "        If you got this message during a clean install, then"
   echo "        please send a missive about this to tarpn@groups.io"
   echo "ERROR: Aborting"
   exit 1;
fi
rm -f home.service*
rm -f home_background.sh*

####### END OF NC4FG TARPN HOME #######################################################################################
####### END OF NC4FG TARPN HOME #######################################################################################
####### END OF NC4FG TARPN HOME #######################################################################################


echo -e "\n\n\n\n"
uptime
echo "#####"
echo "#####"
echo "##### APT-GET-UPDATE"
echo "#####"
echo "#####"
cd ~
sleep 1
sudo apt-get -y update

sleep 1
echo -e "\n\n\n\n"
uptime
echo "#####"
echo "#####"
echo "##### APT-GET DIST-UPGRADE"
echo "#####"
echo "#####"
sleep 1
sudo apt-get -y dist-upgrade

#### sudo apt-get install -y rpi-update
#### sudo rpi-update

uptime


######## Write a flag to tell  TARPN-START 2 that we finished TARPN-START-1.
######## This keeps somebody from running them out of order or running them at the same time.
sudo touch /usr/local/sbin/tarpn_start1_finished.flag



sleep 1;
echo -e "\n\n\n\n\n\n"
echo "######"
echo "######"
echo "######"
echo "######"
echo "######      Raspberry PI will now reboot.  All is going well so far."
echo "######      When we come back up, reconnect and do the command   tarpn"
echo "######      as per the TARPN node bringup instructions document"
sleep 1;
echo "######"

sleep 1;
###### Touching /FORCEFSCK will cause File System Check to run the next time Linux boots
sudo touch /forcefsck
echo "######"

sleep 1;

uptime

###### Shutdown with automatic restart
sudo shutdown -r now
exit 0
