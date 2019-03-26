#!/bin/bash
#### This script is copyright Tadd Torborg KA2DEW 2014, 2015, 2016
##### Please leave this copyright notice in the document and if changes are made,
##### indicate at the copyright notice as to what the intent of the changes was.
##### Thanks. - Tadd Raleigh NC

##### CHECK PROCESS
##### This looks to see if the specified process is running.
##### returns 0 if not running.  Returns 1 if running
check_process()
{
  #  echo "$ts: checking $1"
  [ "$1" = "" ]  && return 0
  [ `pgrep -n $1` ] && return 1 || return 0
}

###### NO CONFIG WITH NODE RUNNING
###### Outputs a text warning and then exits
noConfigWithNodeRunning()
{
   echo "######"
   echo "######"
   echo "######"
   echo "Config is disabled while node is auto-loading or running."
   echo "                     You should do"
   echo "tarpn service stop       then do"
   echo "tarpn                over and over until it says the node is not running"
   echo "                     When the node is no longer running, do"
   echo "tarpn config     then"
   echo "tarpn test       and then if all is well and when you are done testing"
   echo "tarpn service start"
   exit 1
}

#######  READ FIGURE FROM NODE.INI FILE.
####### Called with the name of a KEY.  This function finds the KEY and reads its matching VALUE into $value.
####### Returns 0 if KEY was found.  Returns 1 if KEY was NOT found.
### NODEWORK points to a temp-file which contains the ini file before this config session.
### TEMPFILE points to a temp-file which is deleted and created in this function.
### the TEMPFILE file is never used outside of this function
ReadFigureFromNodeIniFile()
{
        #echo "readfigure(" $1 ")"
        if grep -q -e "$1" $NODEWORK;
        then
                IFS=:
                rm -f $TEMPFILE
                grep "$1" $NODEWORK > $TEMPFILE
                read key value < $TEMPFILE
                #echo "key " $key
                #echo "value " $value
                return 0;
        else
                return 1;
        fi
}

######## NEW VALUE FOR
######## This prompts the user to keep or replace a value.  This then reads in the value if any.
######## Returns the new value if any, or the old value if no new value was entered.
newValueFor()
{
   TEMP_FILE="/home/pi/newvaluetempfile.tmp"
   value=$2;
   echo -n "$1 = $2 -->"
   read newvalue
   if [ -n "$newvalue" ];
   then
      value=$newvalue;
          rm -f $TEMP_FILE
          echo $newvalue | cut -b1 > $TEMP_FILE;
          if grep -q -e "\." $TEMP_FILE;
          then
            value="not_set"
            echo "First char was period -- Making value = not_set";
          fi
          rm -f $TEMP_FILE
   fi
}



######### GET YES NO
######### This uses 'newValueFor( )' to read in the text YES or NO for a boolean.
######### If the response is "yes", returns _boolean=1
######### If response is "no" returns _boolean=0

getYesNo()
{
  _success=0;
  while [ $_success -eq 0 ];
  do
    newValueFor "$1 yes or no" $2;      __block_text=$value;
        _upper_block_text=${__block_text^^}

    if [ $_upper_block_text == "YES" ];
    then
      _success=1;
      _boolean=1;
     #echo "setting _block_enable to 1.  _block_enabled=" $_block_enabled
    else
      if [ $_upper_block_text == "NO" ];
      then
        _success=1;
        _boolean=0;
        #echo "setting _block_enable to 0.  _block_enabled=" $_block_enabled
      else
        echo "Enter   yes   or enter   no"
      fi
    fi
  done
  #echo "getBlockEnable() return _block_enabled=" $_block_enabled
}

######### GET BLOCK ENABLE
######### This uses 'newValueFor( )' to read in the text ENABLE or DISABLE for a PORT number.
######### If the response is "enable", returns _block_enabled=1
######### If response is "disable" returns _block_enabled=0

getBlockEnable()
{
  _success=0;
  while [ $_success -eq 0 ];
  do
    newValueFor "$1 enable or disable" $2;      __block_text=$value;
        _upper_block_text=${__block_text^^}

    if [ $_upper_block_text == "ENABLE" ];
    then
      _success=1;
      _block_enabled=1;
     #echo "setting _block_enable to 1.  _block_enabled=" $_block_enabled
    else
      if [ $_upper_block_text == "DISABLE" ];
      then
        _success=1;
        _block_enabled=0;
        #echo "setting _block_enable to 0.  _block_enabled=" $_block_enabled
      else
        echo "Enter   enable   or enter   disable"
      fi
    fi
  done
  #echo "getBlockEnable() return _block_enabled=" $_block_enabled
}



## Version 24 -- support blank lines and single quotes in INFO text.
## Version 25  11/12/2014   Added echo comments about DECIMAL i2c addresses
## Version 26  12/14/2014   add getYesNo( )   start asking if Mobile Node
## Version 27  12/14/2014   Create config for each port for facing mobile node.
## Version 28  2/21/2015    Grab yes/no code from mobile-node project.
## Version 29  2/21/2015    Remove mobile node code.
## Version 30  6/24/2015    Tune the text around INFO text.
## Version 31  6/30/2015    Fix missing quote
## Version 32  8/10/2017    Remove the check for INITTAB.  It isn't needed anymore
## Version 33  9/25/2017    Add support for BBSCALL and BBSNODE
## Version 34  9/28/2017    Fix prompt text.  BBS Callsign   BBS Nodename
## Version 35  10/03/2017    Fix prompt text.  BBS Nodename is 6 characters, not 4
## Version 36  10/12/2017    Fix the node-is-running error message
## Version 37  5/12/2018     Add Chat Node option
## Version 38  7/03/2018     stop prompting for BBS node name
## Version 39  7/26/2018     Chat Callsign is required.
## Version 40  8/17/2018     Change prompt for neighbor node to specific that it is a callsign we want. 
## Version 41 10/07/2018     Prompt for lat/lon or grid-square, instead of just grid-square. 
## Versopm 42 10/20/2018     Add notes about quotes and ampersands.  Stop mentioning grid-square.
## Version 43 2/11/2018      Add elements for multiple Raspberry PIs per node site 

############################################################
############################################################
############################################################
############################################################
############################################################
############################################################
echo "####"                                         ########
echo "####"                                         ########
echo "#### =CONFIGURE_NODE.SH v042 =" #  --VERSION--########
echo "####"                                         ########
echo "####"                                         ########
############################################################
############################################################
############################################################
############################################################
############################################################
############################################################
sleep 1


######### Refuse to operate if we can't write and read-back in the /home/pi directory.

cd /home/pi
rm -f testfile.txt
if [ -f testfile.txt ];
then
        echo "##### ERROR1: unable to write to /home/pi.  This needs to be run as user pi."
        exit 1;
else
    #### There is no testfile.txt in the pi home directory.  This is good.  Now see if we can create one.
    echo "test" > testfile.txt
    if [ -f testfile.txt ];
    then
       ### there wasn't a testfile.  There is now.  This is good.  Delete it and move on
           rm -f testfile.txt
        else
           #### There wasn't a testfile.  There still isn't.  This is a problem.
           echo "##### ERROR2: Unable to write to /home/pi.  This needs to be run as user PI."
           exit 1
        fi
fi

### Don't run if the source_url.txt file is not set.
if [ -f /usr/local/sbin/source_url.txt ];
then
    echo -n;
else
   echo "ERROR0: source URL file not found."

   echo "ERROR0:"
   echo "ERROR0: Aborting"
   exit 1
fi
_source_url=$( cat /usr/local/sbin/source_url.txt );

check_process "linbpq"
if [ $? -ge 1 ]; then
   echo "#####  BPQ node is running."
   noConfigWithNodeRunning;
fi

###### Set up default values for a node.ini file

nodecall="n0tset"
nodename="notset"
bbscall="not_set"
bbsnode="BBS"
chatcall="not_set"
maidenheadlocator="not_set"
infomessage1="not_set"
infomessage2="not_set"
infomessage3="not_set"
infomessage4="not_set"
infomessage5="not_set"
infomessage6="not_set"
infomessage7="not_set"
infomessage8="not_set"
ctext="not_set"
local_op_callsign="none"
sysop_password="not_set"

tncpi_port01="DISABLE"
port01i2caddress=98
neighbor01="not_set"

tncpi_port02="DISABLE"
port02i2caddress=98
neighbor02="not_set"

tncpi_port03="DISABLE"
port03i2caddress=98
neighbor03="not_set"

tncpi_port04="DISABLE"
port04i2caddress=98
neighbor04="not_set"

tncpi_port05="DISABLE"
port05i2caddress=98
neighbor05="not_set"

tncpi_port06="DISABLE"
port06i2caddress=99
neighbor06="not_set"

usb_port07="DISABLE"
speed07=19200
txdelay07=1000
neighbor07="not_set"

usb_port08="DISABLE"
speed08=19200
txdelay08=1000
neighbor08="not_set"

usb_port09="DISABLE"
speed09=19200
txdelay09=1000
neighbor09="not_set"

usb_port10="DISABLE"
speed10=19200
txdelay10=1000
neighbor10="not_set"

usb_port11="DISABLE"
speed11=19200
txdelay11=1000
portdev11=ttyUSB5
frack11=4000
neighbor11="not_set"

usb_port12="DISABLE"
speed12=19200
txdelay12=1000
portdev12=ttyUSB6
frack12=4000
neighbor12="not_set"


########### If there is already a node.ini file, read it in, overwriting the default values

if [ -f /home/pi/node.ini ];
then
        echo "node.ini exists"
        echo
        echo "NOTE:  You can control-C out of this process at any time if you"
        echo "       decide you don't really want to change your config or if you"
        echo "       see that you have made a mistake and want to make it go away."
        echo
        cp node.ini /home/pi/bpq/node_process
        NODEWORK="/home/pi/bpq/node_process"
        TEMPFILE="/home/pi/tempfile"

        ReadFigureFromNodeIniFile "nodecall";           if [ $? -eq 0 ]; then nodecall=$value; fi
        ReadFigureFromNodeIniFile "nodename";           if [ $? -eq 0 ]; then nodename=$value; fi
        ReadFigureFromNodeIniFile "bbscall";            if [ $? -eq 0 ]; then bbscall=$value; fi
        ReadFigureFromNodeIniFile "chatcall";           if [ $? -eq 0 ]; then chatcall=$value; fi
        ReadFigureFromNodeIniFile "maidenheadlocator";  if [ $? -eq 0 ]; then maidenheadlocator=$value; fi
        ReadFigureFromNodeIniFile "infomessage1";       if [ $? -eq 0 ]; then infomessage1=$value; fi
        ReadFigureFromNodeIniFile "infomessage2";       if [ $? -eq 0 ]; then infomessage2=$value; fi
        ReadFigureFromNodeIniFile "infomessage3";       if [ $? -eq 0 ]; then infomessage3=$value; fi
        ReadFigureFromNodeIniFile "infomessage4";       if [ $? -eq 0 ]; then infomessage4=$value; fi
        ReadFigureFromNodeIniFile "infomessage5";       if [ $? -eq 0 ]; then infomessage5=$value; fi
        ReadFigureFromNodeIniFile "infomessage6";       if [ $? -eq 0 ]; then infomessage6=$value; fi
        ReadFigureFromNodeIniFile "infomessage7";       if [ $? -eq 0 ]; then infomessage7=$value; fi
        ReadFigureFromNodeIniFile "infomessage8";       if [ $? -eq 0 ]; then infomessage8=$value; fi
        ReadFigureFromNodeIniFile "ctext";              if [ $? -eq 0 ]; then ctext=$value; fi
        ReadFigureFromNodeIniFile "local-op-callsign";  if [ $? -eq 0 ]; then local_op_callsign=$value; fi
        ReadFigureFromNodeIniFile "sysop-password";     if [ $? -eq 0 ]; then sysop_password=$value; fi



        ReadFigureFromNodeIniFile "tncpi-port01";       if [ $? -eq 0 ]; then tncpi_port01=$value; fi
        ReadFigureFromNodeIniFile "port01i2caddress";   if [ $? -eq 0 ]; then port01i2caddress=$value; fi
        ReadFigureFromNodeIniFile "neighbor01";         if [ $? -eq 0 ]; then neighbor01=$value; fi

        ReadFigureFromNodeIniFile "tncpi-port02";       if [ $? -eq 0 ]; then tncpi_port02=$value; fi
        ReadFigureFromNodeIniFile "port02i2caddress";   if [ $? -eq 0 ]; then port02i2caddress=$value; fi
        ReadFigureFromNodeIniFile "neighbor02";         if [ $? -eq 0 ]; then neighbor02=$value; fi

        ReadFigureFromNodeIniFile "tncpi-port03";       if [ $? -eq 0 ]; then tncpi_port03=$value; fi
        ReadFigureFromNodeIniFile "port03i2caddress";   if [ $? -eq 0 ]; then port03i2caddress=$value; fi
        ReadFigureFromNodeIniFile "neighbor03";         if [ $? -eq 0 ]; then neighbor03=$value; fi

        ReadFigureFromNodeIniFile "tncpi-port04";       if [ $? -eq 0 ]; then tncpi_port04=$value; fi
        ReadFigureFromNodeIniFile "port04i2caddress";   if [ $? -eq 0 ]; then port04i2caddress=$value; fi
        ReadFigureFromNodeIniFile "neighbor04";         if [ $? -eq 0 ]; then neighbor04=$value; fi

        ReadFigureFromNodeIniFile "tncpi-port05";       if [ $? -eq 0 ]; then tncpi_port05=$value; fi
        ReadFigureFromNodeIniFile "port05i2caddress";   if [ $? -eq 0 ]; then port05i2caddress=$value; fi
        ReadFigureFromNodeIniFile "neighbor05";         if [ $? -eq 0 ]; then neighbor05=$value; fi

        ReadFigureFromNodeIniFile "tncpi-port06";       if [ $? -eq 0 ]; then tncpi_port06=$value; fi
        ReadFigureFromNodeIniFile "port06i2caddress";   if [ $? -eq 0 ]; then port06i2caddress=$value; fi
        ReadFigureFromNodeIniFile "neighbor06";         if [ $? -eq 0 ]; then neighbor06=$value; fi

        ReadFigureFromNodeIniFile "usb-port07";         if [ $? -eq 0 ]; then usb_port07=$value; fi
        ReadFigureFromNodeIniFile "speed07";            if [ $? -eq 0 ]; then speed07=$value; fi
        ReadFigureFromNodeIniFile "txdelay07";          if [ $? -eq 0 ]; then txdelay07=$value; fi
        ReadFigureFromNodeIniFile "neighbor07";         if [ $? -eq 0 ]; then neighbor07=$value; fi

        ReadFigureFromNodeIniFile "usb-port08";         if [ $? -eq 0 ]; then usb_port08=$value; fi
        ReadFigureFromNodeIniFile "speed08";            if [ $? -eq 0 ]; then speed08=$value; fi
        ReadFigureFromNodeIniFile "txdelay08";          if [ $? -eq 0 ]; then txdelay08=$value; fi
        ReadFigureFromNodeIniFile "neighbor08";         if [ $? -eq 0 ]; then neighbor08=$value; fi

        ReadFigureFromNodeIniFile "usb-port09";         if [ $? -eq 0 ]; then usb_port09=$value; fi
        ReadFigureFromNodeIniFile "speed09";            if [ $? -eq 0 ]; then speed09=$value; fi
        ReadFigureFromNodeIniFile "txdelay09";          if [ $? -eq 0 ]; then txdelay09=$value; fi
        ReadFigureFromNodeIniFile "neighbor09";         if [ $? -eq 0 ]; then neighbor09=$value; fi

        ReadFigureFromNodeIniFile "usb-port10";         if [ $? -eq 0 ]; then usb_port10=$value; fi
        ReadFigureFromNodeIniFile "speed10";            if [ $? -eq 0 ]; then speed10=$value; fi
        ReadFigureFromNodeIniFile "txdelay10";          if [ $? -eq 0 ]; then txdelay10=$value; fi
        ReadFigureFromNodeIniFile "neighbor10";         if [ $? -eq 0 ]; then neighbor10=$value; fi

        ReadFigureFromNodeIniFile "usb-port11";         if [ $? -eq 0 ]; then usb_port11=$value; fi
        ReadFigureFromNodeIniFile "speed11";            if [ $? -eq 0 ]; then speed11=$value; fi
        ReadFigureFromNodeIniFile "txdelay11";          if [ $? -eq 0 ]; then txdelay11=$value; fi
        ReadFigureFromNodeIniFile "portdev11";          if [ $? -eq 0 ]; then portdev11=$value; fi
        ReadFigureFromNodeIniFile "frack11";            if [ $? -eq 0 ]; then frack11=$value; fi
        ReadFigureFromNodeIniFile "neighbor11";         if [ $? -eq 0 ]; then neighbor11=$value; fi

        ReadFigureFromNodeIniFile "usb-port12";         if [ $? -eq 0 ]; then usb_port12=$value; fi
        ReadFigureFromNodeIniFile "speed12";            if [ $? -eq 0 ]; then speed12=$value; fi
        ReadFigureFromNodeIniFile "txdelay12";          if [ $? -eq 0 ]; then txdelay12=$value; fi
        ReadFigureFromNodeIniFile "portdev12";          if [ $? -eq 0 ]; then portdev12=$value; fi
        ReadFigureFromNodeIniFile "frack12";            if [ $? -eq 0 ]; then frack12=$value; fi
        ReadFigureFromNodeIniFile "neighbor12";         if [ $? -eq 0 ]; then neighbor12=$value; fi



fi


#########  PROMPT the user to make changes to any figure.


echo "You will be prompted with the name of a setting and the current"
echo "value of that setting.  Press enter to keep the value, or enter"
echo "a new value and then hit enter."
sleep 0.1
echo
sleep 0.1
echo "NODE CALLSIGN"
echo "The node callsign is probably your callsign dash 2, for instance: w1aw-2"
echo "The software limitations are that it can be -0 through -15 but convention"
echo "has it that you not use -0 or -15.  -2 is sort of a standard around here."
echo

newValueFor "Node Callsign" $nodecall;                                    nodecall=$value;
newValueFor "Node Name, max 6 chars, no spaces or punctuation" $nodename; nodename=$value;

echo
echo
sleep 0.1
echo "BBS Callsign"
echo "Leave set to not_set unless you want to operate a BBS on this Raspberry PI"
echo "Set bbscall to be your callsign -1  "
echo "To switch off the BBS function, set the BBS Callsign to a period ."
echo
newValueFor "BBS Callsign" $bbscall;                                    bbscall=$value;

if [ $maidenheadlocator == "AA00aa" ];  ### if we are not a mobile node, then we can't have this grid square
then
  maidenheadlocator="not_set"
fi

#        chatcall="not_set"

echo
echo
echo "CHAT callsign"
echo "Every G8BPQ node in the network has a CHAT service.  Each nees a unique callsign"
echo "which cannot be the same as any BBS or node in the network."
echo "We recommend using the owner operator callsign with a -9."
echo
newValueFor "CHAT callsign" $chatcall;                                    chatcall=$value;


echo
echo "LOCATION: "
echo "This should be latitude, longitude for your node."
echo "Use Google Earth or GPS receiver to obtain this value.  "
echo "Lat/Lon format in the US should be something like 33.451, -83.777"
echo "###"
echo
newValueFor "node location, lat, lon" $maidenheadlocator;              maidenheadlocator=$value;

check_process "linbpq"
if [ $? -ge 1 ]; then
   echo
   echo "##### ERROR!"
   echo "#####        BPQ node is running."
   echo "#####        ... it must have started since you entered config".
   noConfigWithNodeRunning;
fi


echo
echo "INFO TEXT"
echo "This next value is the INFO message text.  This is what the user gets if"
echo "they use the I or INFO command.  This text can be several lines long."
echo "Each line is in a separate field.  infomessage1 is the 1st line."
echo "infomessage8 is the last line.  not_set lines are removed from the INFO response."
echo
echo "This is the current output for the INFO text:"
echo "--------------------------------------------------------------------------------"
echo $infomessage1;
echo $infomessage2;
echo $infomessage3;
echo $infomessage4;
echo $infomessage5;
echo $infomessage6;
echo $infomessage7;
echo $infomessage8;
echo "--------------------------------------------------------------------------------"
echo "Now you can change any lines.  I recommend you copy and paste from a text"
echo "file as you go through this so you can get the result you want."
echo
echo "Any line that is not to be used should be left as    not_set  or may be set to"
echo "have just a period.  Lines with a period in the first character will be replaced"
echo "with not_set and not_set lines will not be included in the INFO response."
echo "Note: No double quotes, no single quotes, no colons, and no ampersands."
echo
newValueFor "INFO line 1" $infomessage1;         infomessage1=$value;
newValueFor "INFO line 2" $infomessage2;         infomessage2=$value;
newValueFor "INFO line 3" $infomessage3;         infomessage3=$value;
newValueFor "INFO line 4" $infomessage4;         infomessage4=$value;
newValueFor "INFO line 5" $infomessage5;         infomessage5=$value;
newValueFor "INFO line 6" $infomessage6;         infomessage6=$value;
newValueFor "INFO line 7" $infomessage7;         infomessage7=$value;
newValueFor "INFO line 8" $infomessage8;         infomessage8=$value;

echo "--------------------------------------------------------------------------------"
echo
echo "The Connect-Text is sent to a station that connects to the node."
echo "keep it short and sweet.  Town name, or neighborhood and town."
echo "Note: No double quotes, no single quotes, no colons, and no ampersands."
echo
newValueFor "Connect-Text" $ctext;               ctext=$value;
echo
echo "local op callsign is used by the node when an operator controls the"
echo "node locally.  This is used as telnet username, and to set up the"
echo "node which will be PIUSER.  Connecting to PI user or using command"
echo "HOST gets a visitor to the local operator."
echo
echo "This should either be set to your legal callsign, with no SSID,"
echo "or to the word 'none'."
echo "If this is set to none, then telnet and host mode are disabled."
echo
newValueFor "local_op_callsign" $local_op_callsign;   local_op_callsign=$value;
echo
echo "SYSOP password is for answering the PASSWORD challenge."
echo "See http://www.cantab.net/users/john.wiseman/Documents/Node%20SYSOP.html"
echo "You should probably leave set this to the group password or discuss it"
echo "with who-ever is managing the L3 and L4 parameters for your node."
echo "Note: No double quotes, no single quotes and no ampersands."
echo
newValueFor "SYSOP password" $sysop_password;      sysop_password=$value;

check_process "linbpq"
if [ $? -ge 1 ]; then
   echo "#####  ERROR!"
   echo "#####         BPQ node is running."
   echo "#####         ... it must have started since you entered config".
   noConfigWithNodeRunning;
fi


echo "--------------------------------------------------------------------------------"
echo "The next part enables and configures individual enabled ports."
echo "Each TNC-PI has an I2C address.  Use DECIMAL numbers for I2C addresses. "
echo "Note that in some places I2C addresses are shown in HEXIDECIMAL. "
echo "This is tricky so you have to pay attention."
echo
echo "All ports have neighbors."
echo "The neighbor should be the callsign dash SSID of the node faced by"
echo "the port and the radio attached to that port.  Only that callsign"
echo "will be accessed by that port and radio."
echo "Note that other parameters, including TxDelay, are set on the TNC"
echo "itself using the SETPARAMS command.  See the documentation."
echo


getBlockEnable "TNC-PI port 01 " $tncpi_port01;
if [ $_block_enabled -eq 1 ];
then
  tncpi_port01="ENABLE"
  newValueFor "Decimal I2C address for port 01 TNC-PI" $port01i2caddress;   port01i2caddress=$value;
  newValueFor "Callsign for neighbor node faced by port 01" $neighbor01;       neighbor01=$value;
else
  tncpi_port01="DISABLE"
fi

getBlockEnable "TNC-PI port 02 " $tncpi_port02;
if [ $_block_enabled -eq 1 ];
then
  tncpi_port02="ENABLE"
  newValueFor "Decimal I2C address for port 02 TNC-PI" $port02i2caddress;   port02i2caddress=$value;
  newValueFor "Callsign for neighbor node faced by port 02" $neighbor02;       neighbor02=$value;
else
  tncpi_port02="DISABLE"
fi

getBlockEnable "TNC-PI port 03 " $tncpi_port03;
if [ $_block_enabled -eq 1 ];
then
  tncpi_port03="ENABLE"
  newValueFor "Decimal I2C address for port 03 TNC-PI" $port03i2caddress;   port03i2caddress=$value;
  newValueFor "Callsign for neighbor node faced by port 03" $neighbor03;       neighbor03=$value;
else
  tncpi_port03="DISABLE"
fi

getBlockEnable "TNC-PI port 04 " $tncpi_port04;
if [ $_block_enabled -eq 1 ];
then
  tncpi_port04="ENABLE"
  newValueFor "Decimal I2C address for port 04 TNC-PI" $port04i2caddress;   port04i2caddress=$value;
  newValueFor "Callsign for neighbor node faced by port 04" $neighbor04;       neighbor04=$value;
else
  tncpi_port04="DISABLE"
fi

getBlockEnable "TNC-PI port 05 " $tncpi_port05;
if [ $_block_enabled -eq 1 ];
then
  tncpi_port05="ENABLE"
  newValueFor "Decimal I2C address for port 05 TNC-PI" $port05i2caddress;   port05i2caddress=$value;
  newValueFor "Callsign for neighbor node faced by port 05" $neighbor05;       neighbor05=$value;
else
  tncpi_port05="DISABLE"
fi

getBlockEnable "TNC-PI port 06 " $tncpi_port06;
if [ $_block_enabled -eq 1 ];
then
  tncpi_port06="ENABLE"
  newValueFor "Decimal I2C address for port 06  TNC-PI" $port06i2caddress;   port06i2caddress=$value;
  newValueFor "Callsign for neighbor node faced by port 06" $neighbor06;       neighbor06=$value;
else
  tncpi_port06="DISABLE"
fi

echo
echo "Now configure the USB-serial ports."
echo "These ports have TxDelay parameters set in the G8BPQ node as read from"
echo "the value you are setting for each of these enabled ports."
echo

getBlockEnable "USB TNC port 07 /dev/ttyUSB0 " $usb_port07;
if [ $_block_enabled -eq 1 ];
then
  usb_port07="ENABLE"
  newValueFor "TxDelay to be used by USB KISS TNC on port 07" $txdelay07;   txdelay07=$value;
  newValueFor "Serial baud rate for TNC on port 07" $speed07;   speed07=$value;
  newValueFor "Callsign for neighbor node faced by port 07" $neighbor07;       neighbor07=$value;
else
  usb_port07="DISABLE"
fi


getBlockEnable "USB TNC port 08 /dev/ttyUSB1 " $usb_port08;
if [ $_block_enabled -eq 1 ];
then
  usb_port08="ENABLE"
  newValueFor "TxDelay to be used by USB KISS TNC on port 08" $txdelay08;   txdelay08=$value;
  newValueFor "Serial baud rate for TNC on port 08" $speed08;   speed08=$value;
  newValueFor "Callsign for neighbor node faced by port 08" $neighbor08;       neighbor08=$value;
else
  usb_port08="DISABLE"
fi


getBlockEnable "USB TNC port 09 /dev/ttyUSB2 " $usb_port09;
if [ $_block_enabled -eq 1 ];
then
  usb_port09="ENABLE"
  newValueFor "TxDelay to be used by USB KISS TNC on port 09" $txdelay09;   txdelay09=$value;
  newValueFor "Serial baud rate for TNC on port 09" $speed09;   speed09=$value;
  newValueFor "Callsign for neighbor node faced by port 09" $neighbor09;       neighbor09=$value;
else
  usb_port09="DISABLE"
fi


getBlockEnable "USB TNC port 10 /dev/ttyUSB3 " $usb_port10;
if [ $_block_enabled -eq 1 ];
then
  usb_port10="ENABLE"
  newValueFor "TxDelay to be used by USB KISS TNC on port 10" $txdelay10;   txdelay10=$value;
  newValueFor "Serial baud rate for TNC on port 10" $speed10;   speed10=$value;
  newValueFor "Callsign for neighbor node faced by port 10" $neighbor10;       neighbor10=$value;
else
  usb_port10="DISABLE"
fi


echo
echo "Ports 11 and 12 are USB ports but are highly customizable in support of"
echo "non-traditional TNCs."
echo
getBlockEnable "USB TNC port 11  - user specified /dev port " $usb_port11;
if [ $_block_enabled -eq 1 ];
then
  usb_port11="ENABLE"
  newValueFor "/dev name for port 11 -- default is ttyUSB5" $portdev11;     portdev11=$value;
  newValueFor "Serial baud rate for TNC on port 11" $speed11;               speed11=$value;
  newValueFor "TxDelay to be used by USB KISS TNC on port 11" $txdelay11;   txdelay11=$value;
  newValueFor "Frame Acknowledge Max-time in milliseconds" $frack11;        frack11=$value;
  newValueFor "Callsign for neighbor node faced by port 11" $neighbor11;                 neighbor11=$value;
else
  usb_port11="DISABLE"
fi


getBlockEnable "USB TNC port 12  - user specified /dev port " $usb_port12;
if [ $_block_enabled -eq 1 ];
then
  usb_port12="ENABLE"
  newValueFor "/dev name for port 12 -- default is ttyUSB6" $portdev12;     portdev12=$value;
  newValueFor "Serial baud rate for TNC on port 12" $speed12;               speed12=$value;
  newValueFor "TxDelay to be used by USB KISS TNC on port 12" $txdelay12;   txdelay12=$value;
  newValueFor "Frame Acknowledge Max-time in milliseconds" $frack12;        frack12=$value;
  newValueFor "Callsign for neighbor node faced by port 12" $neighbor12;                 neighbor12=$value;
else
  usb_port12="DISABLE"
fi

rm -f node.ini2
check_process "linbpq"
if [ $? -ge 1 ]; then
   echo "#####  ERROR!"
   echo "#####         BPQ node is running."
   echo "#####         ... it must have started since you entered config".
   noConfigWithNodeRunning;
fi

echo "-------------------------------------------------------------------"
echo "#### Done.  Now to overwrite the node.ini file with the new configuration."
sleep 1

###### Copy the internal variables to the node.ini file.

_lowerCaseNodeCall=${nodecall,,}
echo "nodecall:"$_lowerCaseNodeCall          >> node.ini2

_lowerCaseNodeName=${nodename,,}
echo "nodename:"$_lowerCaseNodeName         >> node.ini2

_lowerCaseBbsCall=${bbscall,,}
echo "bbscall:"$_lowerCaseBbsCall           >> node.ini2

_lowerCaseBbsNode=${bbsnode,,}
echo "bbsnode:"$_lowerCaseBbsNode           >> node.ini2

_lowerCaseChatCall=${chatcall,,}
echo "chatcall:"$_lowerCaseChatCall        >> node.ini2

echo "maidenheadlocator:"$maidenheadlocator >> node.ini2
echo "infomessage1:"$infomessage1           >> node.ini2
echo "infomessage2:"$infomessage2           >> node.ini2
echo "infomessage3:"$infomessage3           >> node.ini2
echo "infomessage4:"$infomessage4           >> node.ini2
echo "infomessage5:"$infomessage5           >> node.ini2
echo "infomessage6:"$infomessage6           >> node.ini2
echo "infomessage7:"$infomessage7           >> node.ini2
echo "infomessage8:"$infomessage8           >> node.ini2
echo "ctext:"$ctext                         >> node.ini2

_lowerCaseOpCallsign=${local_op_callsign,,}
echo "local-op-callsign:"$_lowerCaseOpCallsign >> node.ini2

echo "sysop-password:"$sysop_password       >> node.ini2
echo >> node.ini2
echo "tncpi-port01:"$tncpi_port01           >> node.ini2
echo "port01i2caddress:"$port01i2caddress   >> node.ini2
_lowerCaseNeighbor01=${neighbor01,,}
echo "neighbor01:"$_lowerCaseNeighbor01      >> node.ini2
echo >> node.ini2
echo "tncpi-port02:"$tncpi_port02           >> node.ini2
echo "port02i2caddress:"$port02i2caddress   >> node.ini2
_lowerCaseNeighbor02=${neighbor02,,}
echo "neighbor02:"$_lowerCaseNeighbor02      >> node.ini2
echo >> node.ini2
echo "tncpi-port03:"$tncpi_port03                    >> node.ini2
echo "port03i2caddress:"$port03i2caddress            >> node.ini2
_lowerCaseNeighbor03=${neighbor03,,}
echo "neighbor03:"$_lowerCaseNeighbor03      >> node.ini2
echo >> node.ini2
echo "tncpi-port04:"$tncpi_port04                    >> node.ini2
echo "port04i2caddress:"$port04i2caddress             >> node.ini2
_lowerCaseNeighbor04=${neighbor04,,}
echo "neighbor04:"$_lowerCaseNeighbor04      >> node.ini2
echo >> node.ini2
echo "tncpi-port05:"$tncpi_port05                     >> node.ini2
echo "port05i2caddress:"$port05i2caddress             >> node.ini2
_lowerCaseNeighbor05=${neighbor05,,}
echo "neighbor05:"$_lowerCaseNeighbor05      >> node.ini2
echo >> node.ini2
echo "tncpi-port06:"$tncpi_port06                     >> node.ini2
echo "port06i2caddress:"$port06i2caddress             >> node.ini2
_lowerCaseNeighbor06=${neighbor06,,}
echo "neighbor06:"$_lowerCaseNeighbor06      >> node.ini2
echo >> node.ini2
echo "usb-port07:"$usb_port07                        >> node.ini2
echo "speed07:"$speed07                              >> node.ini2
echo "txdelay07:"$txdelay07                          >> node.ini2
_lowerCaseNeighbor07=${neighbor07,,}
echo "neighbor07:"$_lowerCaseNeighbor07      >> node.ini2
echo >> node.ini2
echo "usb-port08:"$usb_port08                         >> node.ini2
echo "speed08:"$speed08                               >> node.ini2
echo "txdelay08:"$txdelay08                           >> node.ini2
_lowerCaseNeighbor08=${neighbor08,,}
echo "neighbor08:"$_lowerCaseNeighbor08      >> node.ini2
echo >> node.ini2
echo "usb-port09:"$usb_port09                         >> node.ini2
echo "speed09:"$speed09                               >> node.ini2
echo "txdelay09:"$txdelay09                           >> node.ini2
_lowerCaseNeighbor09=${neighbor09,,}
echo "neighbor09:"$_lowerCaseNeighbor09      >> node.ini2
echo >> node.ini2
echo "usb-port10:"$usb_port10                         >> node.ini2
echo "speed10:"$speed10                              >> node.ini2
echo "txdelay10:"$txdelay10                           >> node.ini2
_lowerCaseNeighbor10=${neighbor10,,}
echo "neighbor10:"$_lowerCaseNeighbor10      >> node.ini2
echo >> node.ini2
echo "usb-port11:"$usb_port11                         >> node.ini2
echo "portdev11:"$portdev11                           >> node.ini2
echo "speed11:"$speed11                               >> node.ini2
echo "txdelay11:"$txdelay11                           >> node.ini2
echo "frack11:"$frack11                               >> node.ini2
_lowerCaseNeighbor11=${neighbor11,,}
echo "neighbor11:"$_lowerCaseNeighbor11      >> node.ini2
echo >> node.ini2
echo "usb-port12:"$usb_port12                         >> node.ini2
echo "portdev12:"$portdev12                           >> node.ini2
echo "speed12:"$speed12                               >> node.ini2
echo "txdelay12:"$txdelay12                           >> node.ini2
echo "frack12:"$frack12                               >> node.ini2
_lowerCaseNeighbor12=${neighbor12,,}
echo "neighbor12:"$_lowerCaseNeighbor12      >> node.ini2
echo >> node.ini2

rm -f node.ini
mv node.ini2 node.ini

#### Clean up
rm -f $NODEWORK
rm -f $TEMPFILE


echo
echo "Make sure you use tarpn test to test the node before making it auto.  The new"
echo "configuration will be used the next time G8BPQ is loaded. "
echo
exit 0;


