#!/bin/bash

showContactTarpnMessage() {
   echo "######"
   echo "###### Something bad happened.  Please tell us what!"
   echo "######"
   echo "###### Contact TARPN via the email group. "
   echo "######"
   echo "###### Send the log from when you started the installation."
   echo "###### Thankyou!!!!"
   echo "######"
   return 0;
}

verify() {
   wget -o /dev/null $_source_url/$1
   if [ -f $1 ];
   then
      rm $1
   else
      echo "###### ERROR  $1 not in repository!"
      showContactTarpnMessage
      exit 1
   fi
}


###### This is the Internet URL for the web repository where all the TARPN scripts live.
###### This address is particular to the script major version this TARPN node will be running.
###### This URL gets saved in a secure location on the Raspberry PI's filesystem and is used
###### later during run-time to fetch updates.
SOURCE_URL="http://tarpn.net/2017aug";


#### This script is copyright Tadd Torborg KA2DEW 2014, 2015, 2016, 2017, 2018
##### Please leave this copyright notice in the document and if changes are made,
##### indicate at the copyright notice as to what the intent of the changes was.
##### Thanks. - Tadd Raleigh NC

##### TARPN START 1 --  This script file is downloaded by the human and run to start the
#####                   TARPN install on a brand new Raspberry PI Linux installation.
#####                   This script checks the environment and if everything is good
#####                   it will download the next script, which is large, TARPN START 1dL


echo "######"
echo "######"
echo "###### tarpn start 1 Version STRETCH 007"
echo "######"
echo "######"
echo "######"
#### 2015-02-24  029  Add support for processor Revision a21041  for Raspberry PI 2 B.   Point URL to /feb directory on server.
#### 2015-04-15  030  Add support for a01041 Raspberry PI 2 B v1.1
#### 2015-06-33  031   -- add support for 0013 Raspberry PI B+
#### 2015-10-14  JESSIE 001   -- change the source URL from http://www.torborg.com/feb to http://tarpn.net/2015oct
#### 2015-10-15  JESSIE 002   -- fix debug message when testing Linux version.
#### 2015-10-18  JESSIE 003   -- set the source URL at the top of the file, save it to filesystem, then read it back.
#### 2016-01-10  JESSIE 004   -- add Raspberry PI ZERO support
#### 2016-03-04  JESSIE 005   -- add Raspberry PI 3 B support
#### 2016-03-04  JESSIE 006   -- add Raspberry PI 0 B+ Chinese RED support
#### 2016-03-24  JESSIE 007   -- add support for yet another Raspberry PI 3 B  -- install IPUTILS-PING
#### 2017-08-22  STRETCH 001  -- change the source URL from http://tarpn.net/2015oct  to http://tarpn.net/2017aug
#### 2017-08-22  STRETCH 002  -- Add a verify feature to check for missing items needed for the script.
#### 2017-09-11  STRETCH 003  -- Add a couple of more Raspberry PI models.
#### 2017-10-03  STRETCH 004  -- remove verification of the web-page contents.  Save some time
#### 2018-07-08  STRETCH 005  -- improve error message if attempting install on a fully installed system
#### 2018-07-15  STRETCH 006  -- fix bug where a "fi" was left out -- caused by the error message addition in v005
#### 2018-07-21  STRETCH 007  -- Add support for Raspberry PI B+  _value12

temp_parsing_file="/home/pi/temp_for_tarpn_start.txt";
uptime

######## CHECK TO MAKE SURE WE'RE REALLY RUNNING THE SCRIPT THIS CODE WAS WRITTEN FOR
######## AND ALSO THAT WE'RE BEING RUN IN THE DIRECTORY WHERE THE SCRIPT WAS DOWNLOADED TO.
cd /home/pi
if [ -f tarpn_start1.sh ];
then
   echo
else
   echo "ERROR:  Help.  I don't know where I am.  Is this tarpn_start1.sh?  "
   echo "ERROR:  Please start from the /user/pi directory.  Aborting"
   exit 1;
fi



################# Determine if this Raspberry PI is a supported version
sudo rm -f $temp_parsing_file;
cat /proc/cpuinfo | grep Revision > $temp_parsing_file
_counta=$( cat $temp_parsing_file );
_countb=${_counta:11}

_value0="000d"     #### Red B+ Chinese
_value1="000e"
_value2="000f"
_value3="0010"
_value4="a21041"   ### Raspberry PI 2 B
_value5="a01041"   ### also Raspberry PI 2 B ??  v1.1
_value6="0013"     ### Raspberry PI B + v2
_value7="900092"   #### Raspberry PI Zero
_value8="a02082"   #### Raspberry PI 3 B
_value9="a22082"   #### Bob's Raspberry PI 3 B
_valueA="a22032"  #### Dylan's Raspberry PI 2B
_value10="a22042"  #### 2 Model B (with BCM2837)
_value11="a32082"   #### 3 Model B  Sony Japan
_value12="a020d3"   #### 3 Model B+ England 3-19-2018

_version_ok=0
if [ $_value0 == $_countb ]; then
    _version_ok=1
   fi
if [ $_value1 == $_countb ]; then
    _version_ok=1
   fi
if [ $_value2 == $_countb ]; then
    _version_ok=1
        fi
if [ $_value3 == $_countb ]; then
    _version_ok=1
        fi
if [ $_value4 == $_countb ]; then
    _version_ok=1
        fi
if [ $_value5 == $_countb ]; then
    _version_ok=1
        fi
if [ $_value6 == $_countb ]; then
    _version_ok=1
        fi
if [ $_value8 == $_countb ]; then
    _version_ok=1
        fi
if [ $_value9 == $_countb ]; then
    _version_ok=1
        fi
if [ $_value10 == $_countb ]; then
    _version_ok=1
        fi
if [ $_value11 == $_countb ]; then
    _version_ok=1
        fi
if [ $_value12 == $_countb ]; then
    _version_ok=1
        fi
_good_result=1
if [ $_version_ok -ne $_good_result ]; then
    echo "----------------------------------------------"
        echo "PROC CPUINFO:"
    cat /proc/cpuinfo
    echo "----------------------------------------------"
    sleep 1
    echo "You have an unexpected version of Raspberry PI."
    echo "TARPN is not supported on this version, so far."
    echo "Please contact me, KA2DEW --see QRZ for email addr--,"
    echo "and send me the contents of your"
    echo "/proc/cpuinfo  file printed above."
    echo
    echo
    exit 0
fi

################ CHECK Operating system Version


sudo rm -f $temp_parsing_file
cat /etc/*-release | grep "VERSION" | grep "9 (stretch)" > $temp_parsing_file
if grep -q "VERSION" $temp_parsing_file;
then
   echo -n "Linux ok: "
   cat $temp_parsing_file
else
   echo -e "\n\nERROR!  This script does not support the Linux version reported in /etc"
   echo -e "ERROR!  Quitting now\n\n"
   sleep 1
   cat /etc/*-release
   rm -f $temp_parsing_file
   exit 1
fi
rm -f $temp_parsing_file

echo -e "Your Raspberry PI is running the expected Linux version\n\n\n\n"

###############################################################
#### See if we have already started installing on this box
if [ -f /usr/local/sbin/tarpn_start1dl.flag ];
then
	if [ -f /usr/local/sbin/tarpn_start2.flag ];
	then
	    echo "ERROR! -- you have attempted to start an install on a SDCARD"
	    echo "          that already has a fully installed TARPN node"
	    echo " "
	    echo "          If you want to start from scratch, reformat the card"
	    echo "          and then you NOOBS."  
	    echo "          Ending install now!"
	    exit 1
	else
        echo "ERROR!"
        sleep 1
        echo "ERROR!"
        sleep 1
        echo "ERROR!"
        sleep 1
        echo "ERROR!"
        sleep 1
        echo "##### Error.  Incomplete installation.  Please start installation again by"
        echo "#####         using a freshly formatted SDCARD and NOOBS.  Follow the"
        echo "#####         Set Up raspberry PI to be a TARPN Node--Make SDCARD"
        echo "#####         instructions on the builders page of tarpn.net."
        echo "#####         If this has already failed, please send an email"
        echo "#####         to the TARPN yahoo group.  It is likely that either the"
        echo "#####         script author made a mistake, or the software involved"
        echo "#####         has changed in some way to make the scripts fail.  Thanks."
        sleep 1
        echo "ERROR!"
        sleep 1
        echo "ERROR!"
        sleep 1
        echo "ERROR!"
        exit 1;
     fi
fi





################################################################
##### Save the SOURCE_URL by writing the data set at the top
##### of this script to the designated delete protected file-system location
_success=0


rm -f /home/pi/source_url.txt
echo $SOURCE_URL > /home/pi/source_url.txt
sudo mv /home/pi/source_url.txt /usr/local/sbin/source_url.txt

#### Read back the source URL from the filesystem into a local variable
_source_url=$( cat /usr/local/sbin/source_url.txt );




echo "###### Reinstall IPUTILS-PING"
sudo apt-get install --reinstall iputils-ping

#############################################################################################################################################
### Check to see if the source-URL has some necessary items

###verify tarpn_start2.sh
###verify runbpq.sh
###verify configure_node_ini.sh
###verify tarpn
###verify piminicom.zip
###verify minicom.scr
###verify params.zip
###verify linbpq_6_0_10_16_April_2015.zip
###verify piTermTCP.zip
###verify ringnoises.zip
###verify nc4fg_home1_1.zip
###verify home_background.sh
###verify home.service
###verify home_background.sh
###verify home.service
### verify home.sh

#############################################################################################################################################

echo "###### Proceeding with installation"
echo



echo "###### Download TARPN INSTALL 1dL"
sleep 1


rm -f tarpn_start1dl.sh
wget -o /dev/null $_source_url/tarpn_start1dl.sh
if [ -f tarpn_start1dl.sh ];
then
   echo "##### script 1dL downloaded successfully"
   chmod +x tarpn_start1dl.sh;
   echo "##### Transfer control from TARPN START 1 to TARPN START 1dL"
   ./tarpn_start1dl.sh
else
   echo -e "\n\n\n\n\nERROR:  Failure retrieving script1dl.  Something is wrong"
   echo -e "ERROR: Aborting\n\n\n\n\n"
   exit 1;
fi
exit 0

