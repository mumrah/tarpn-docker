#!/bin/bash
#### This script is copyright Tadd Torborg KA2DEW 2014, 2015, 2016, 2017, 2018
##### Please leave this copyright notice in the document and if changes are made,
##### indicate at the copyright notice as to what the intent of the changes was.
##### Thanks. - Tadd Raleigh NC


##### SCRIPT to use local configuration and import boilerplate global config to generate bpq32.cfg
##### Created by Tadd Torborg KA2DEW  Feb 15, 2014
##### See tarpn.net and http://www.cantab.net/users/john.wiseman/Documents
#### This script is copyright Tadd Torborg KA2DEW 2014, 2015, 2016, 2017
##### Please leave this copyright notice in the document and if changes are made,
##### indicate at the copyright notice as to what the intent of the changes was.
##### Thanks. - Tadd Raleigh NC>

#### version 38 -- changed number of tokens from 53 to 60 to allow for multiple infomessage lines.
#### version 39 -- started working on making single quotes a non-problem.
#### version 40 -- got rid of extra blank lines in INFO text.
#### version 41 -- Add support for tokens related to mobile node and mobile ports
#### version 42 -- remove mobile node features
#### version 43 -- fix bug with processing of TNC-PI 5
#### version 44 -- CROWD is applied to ka2dew-2 instead of to tadd
#### version 45 -- CROWD is applied to ab4oz-2 as well
#### version 46 -- Fix bug where more than one single quote in a line would cause failure.
#### version 47 -- CROWD is applied to W4DNA, KA2DEW and W4VU.  Remove AB4OZ
#### version 48 -- CROWD is applied to kc3ibn-1
#### version 49 -- Allow open and close parenthsis in the info text etc..
#### version 50 -- add support for BBS
#### version 51 -- add support for BBS # of tokens
#### version 52 -- Set BBS=1 or BBS=0 as appropriate
#### version 53a -- CROWD node moved from ka2dew-1 to ka2dew-5
#### version 53b -- if linmail.cfg exists, take action to set the # of streams to 10 and the application number to 3.
#### version 54 -- fix some more default values for the linmail.cfg file.
#### version 55 -- fix some more default values for the linmail.cfg file.
#### version 56 -- CROWD node is on kc3ibn-7.
#### version 57 -- Minor fixes to BBS prompts
#### version 58c -- fix bug where NewUserPrompt was renamed by accident.
#### version 59 -- CROWD node is on wb2lhp-7
#### version 60 -- CROWD node is on nc4fg-12
#### version 61 -- fix error where diagnostic prints were using wrong port numbers for ports 7 through 12. 
#### version 62 -- add support for crowd switch in node.ini
#### version 63b -- debugging crowd switch
#### version 64 -- now require that the chat callsign be set.  Change name from crowd to chat.
#### version 65 -- create a copy of the bpq32.cfg file, sans passwords, and put it in the Files folder
#### version 66 -- July 26 2018 -- make an attempt to fix the ChatCall spec in case it was "crowdcall" 
#### version 68 -- July 27 2018 -- create a custom zdew02 type node name for everybody
#### version 69 -- October 14, 2018 --   get rid of the debug file foo.foo.  Just commented out. 
#### version 70 -- November 22, 2018 --  Change Welcome message and ExpertWelcomeMsg to have "unread=%X   " in support of the bbsstatus check
#### version 71 -- November 23, 2018 -- welcome messages are unread=%x  
#### version 72 -- January 10, 2019 -- fix unread notification in Expert sign-in with TARPN-HOME specific text.  
#### version 75 -- January 10, 2019 -- debugging linmail.cfg sed edits.  
#### version 77 -- January 11, 2019 -- use "new-msgs" for bbs checker in the welcome message,
#### version 78 -- January 25, 2019 -- change the Expert welcome to use unread>>>> instead of unread--->    

echo "#### =MAKE LOCAL v078" #  --VERSION--#########
sleep 1

bpqdirectory="/home/pi/bpq"
mailConfigFile="/home/pi/bpq/linmail.cfg"
filesFolderForBbs="/home/pi/bpq/Files"
bpqConfigForFilesFolder="bpq32.txt"
bpqConfigImageInFilesFolder=$filesFolderForBbs/$bpqConfigForFilesFolder

########### Now get read to read and process the node.ini file and boilerplate.cfg into bpq32.cfg
filetoread="/home/pi/node.ini"
boilerplatefile="/home/pi/bpq/boilerplate.cfg"
outputfile="bpq32.cfg"
templocalfile="/home/pi/bpq/temp___local_node_ini"


##### If the BBS has created a config file, then set the Streams and BBS-Appl-Num correctly.
if [ -f $mailConfigFile ];
then
   sudo sed -i 's/ExpertPrompt = ".*"/ExpertPrompt = "$x unread--->"/g' $mailConfigFile
   sudo sed -i 's/ExpertWelcomeMsg = ".*";/ExpertWelcomeMsg = "$x unread>>>>  new-msgs=$x   Hello Boss\\r\\n";/g' $mailConfigFile
   if grep -q "Streams = 0;" $mailConfigFile;
   then
      sudo sed -i 's/Streams = 0;/Streams = 10;/g' $mailConfigFile
      sudo sed -i 's/BBSApplNum = 0;/BBSApplNum = 3;/g' $mailConfigFile
      sudo sed -i 's/WelcomeMsg = .*$Z/WelcomeMsg = "unread=$x     Greetings/g' $mailConfigFile
      sudo sed -i 's/NewUserWelcomeMsg = .*$Z/NewUserWelcomeMsg = "$x unread messages for $U, Latest $L, Last listed is $Z/g' $mailConfigFile
      sudo sed -i 's/ Prompt = "de .*>\\r\\n";/ Prompt = "$x unread  $N msgs >\\r\\n";/g' $mailConfigFile
      sudo sed -i 's/NewUserPrompt = "de .*>\\r\\n";/NewUserPrompt = "$x unread  $N msgs >\\r\\n";/g' $mailConfigFile
      sudo sed -i 's/DontHoldNewUsers = 0;/DontHoldNewUsers = 1;/g' $mailConfigFile
      sudo sed -i 's/DontNeedHomeBBS = 0;/DontNeedHomeBBS = 1;/g' $mailConfigFile
   fi
   sudo sed -i 's/SMTPGatewayEnabled = .*;/SMTPGatewayEnabled = 0;/g' $mailConfigFile

fi



#### Check that the filetoread has at least the proper number of lines.
sudo rm -f $templocalfile;
cat $filetoread | grep ":" | wc -l  > $templocalfile;
_count=$( cat $templocalfile );
_value=63
if [ $_value -ne $_count ]; then
    echo "ERROR: Make_Local:"
    echo "       node.ini is wrong length.  Run tarpn update and tarpn config"
    echo "       to update your configuration."
        echo "# of tokens found in node.ini = "$_count;
        echo "Expected # of tokens = " $_value
        exit 1;
        fi



#### Verify that the LOCAL config file and the Boilerplate are present.
#### Verify that the LOCAL config file and the Boilerplate are present.
cd /home/pi
if find "/home/pi/node.ini" >> /dev/null;
then
   echo -n
else
   echo "ERROR: node.ini not found";
   echo " It should be in the /home/pi directory.";
   echo "Please use cat > node.ini to create this file as per the documentation.";
   sleep 1
   exit 1;
fi


if find "$boilerplatefile">> /dev/null;
then
   echo -n;
else
   echo "ERROR: boilerplate not found";
   exit 1;
fi

temp_outwork1file="/home/pi/bpq/tt_out1file.tmp"
sudo rm -f $temp_outwork1file
#temp_out2file="tt_out2file.tmp";
templocalfile="/home/pi/bpq/tt_local.tmp";
sudo rm -f $templocalfile
#temptemplocalfile="tt_localtemp.tmp"

##### Make sure there are no token-like figures in the local config file
if grep -q "~q" $filetoread; then
        echo "ERROR: Reserved char sequence(s) found in input file."
        echo "       Please remove the ~q figure from the local.cfg file"
        grep "~q" $filetoread;
        exit 1;
        fi
if grep -q "q~" $filetoread; then
        echo "ERROR: Reserved char sequence(s) found in input file."
        echo "       Please remove the q~ figure from the local.cfg file"
        grep "q~" $filetoread;
        exit 1;
        fi
if grep -q "~SP~" $filetoread; then
        echo "ERROR: Reserved char sequence(s) found in input file."
        echo "       Please remove the ~SP~ figure from the local.cfg file"
        grep "~SP~" $filetoread;
        exit 1;
        fi
if grep -q "~SINGLEQUOTE~" $filetoread; then
        echo "ERROR: Reserved char sequence(s) found in input file."
        echo "       Please remove the ~SINGLEQUOTE~ figure from the local.cfg file"
        grep "~SINGLEQUOTE~" $filetoread;
        exit 1;
        fi
if grep -q "~OPENPAREN~" $filetoread; then
        echo "ERROR: Reserved char sequence(s) found in input file."
        echo "       Please remove the ~OPENPAREN~ figure from the local.cfg file"
        grep "~OPENPAREN~" $filetoread;
        exit 1;
        fi
if grep -q "~CLOSEPAREN~" $filetoread; then
        echo "ERROR: Reserved char sequence(s) found in input file."
        echo "       Please remove the ~CLOSEPAREN~ figure from the local.cfg file"
        grep "~CLOSEPAREN~" $filetoread;
        exit 1;
        fi



cd $bpqdirectory
### Start converting the boilerplate file into the output result.
cp $boilerplatefile $temp_outwork1file

#### The process of reading through the local config file is destructive.  Use a temp copy
cp $filetoread $templocalfile



## delete any blank lines
sed -i '/^$/d' $templocalfile
#sed 's=~$=qq~~qq:qq~~qq=' < $templocalfile > $temptemplocalfile
#mv $temptemplocalfile $templocalfile






## Hide any spaces in the local data by converting them to SPACE tokens.
sed -i 's= =~SP~=g' $templocalfile


sed -i 's/~SP~$//g'  $templocalfile
sed -i 's/~SP~$//g'  $templocalfile
#sed -i 's/~SP~$//g'  $templocalfile

sed -i 's=(=~OPENPAREN~=g' $templocalfile
sed -i 's=)=~CLOSEPAREN~=g' $templocalfile
sed -i 's=(=~OPENPAREN~=g' $templocalfile
sed -i 's=)=~CLOSEPAREN~=g' $templocalfile
sed -i 's=(=~OPENPAREN~=g' $templocalfile
sed -i 's=)=~CLOSEPAREN~=g' $templocalfile

if grep -q "(" $templocalfile; then
   echo "ERROR";
   echo "ERROR: node.ini  --  a ( appears in the node.ini file";
   exit 1;
   fi

if grep -q ")" $templocalfile; then
   echo "ERROR";
   echo "ERROR: node.ini  --  a ) appears in the node.ini file";
   exit 1;
   fi


## removing trailing spaces in the local config
#sed 's=([^ \t\r\n])[ \t]+$==g' < $templocalfile > $temptemplocalfile
#echo -n "5"
#sed -i 's/[ \t]*$//' $templocalfile
#echo -n "A"
#exit 0;
#echo -n "B"



#### Until I can figure out how to get rid of trailing spaces automatically,
#### Announce that there is a problem and tell the user about it.
if grep "~SP~$" $templocalfile; then
   echo "ERROR: trailing spaces in node.ini -- please delete trailing spaces";
   exit 1;
   fi

### Hide any single quotes in the local data by converting them to ~SINGLEQUOTE~ tokens
sed -i "s='=~SINGLEQUOTE~=" $templocalfile
sed -i "s='=~SINGLEQUOTE~=" $templocalfile
sed -i "s='=~SINGLEQUOTE~=" $templocalfile
sed -i "s='=~SINGLEQUOTE~=" $templocalfile
cp $templocalfile  /home/pi/taddquotetest.txt

if grep -q "'" $templocalfile; then
   echo "ERROR";
   echo "ERROR: node.ini  --  a ' appears in the node.ini file";
   exit 1;
   fi


##### Replace infomessage not-set occurrences with a specific not-set token for infomessage so we can find it later
sed -i "s=infomessage1:not_set=infomessage1:BLANKLINE=" $templocalfile
sed -i "s=infomessage2:not_set=infomessage2:BLANKLINE=" $templocalfile
sed -i "s=infomessage3:not_set=infomessage3:BLANKLINE=" $templocalfile
sed -i "s=infomessage4:not_set=infomessage4:BLANKLINE=" $templocalfile
sed -i "s=infomessage5:not_set=infomessage5:BLANKLINE=" $templocalfile
sed -i "s=infomessage6:not_set=infomessage6:BLANKLINE=" $templocalfile
sed -i "s=infomessage7:not_set=infomessage7:BLANKLINE=" $templocalfile
sed -i "s=infomessage8:not_set=infomessage8:BLANKLINE=" $templocalfile



##### Look through local file for port enables.
##### We should have 6.  If we do not, then there is a problem.
if grep -q -e "tncpi-port01:ENABLE" -e "tncpi-port01:DISABLE" $templocalfile; then
      echo -n; #"found port1 enable-disable spec OK";
   else
      echo "ERROR: node.ini has no, or malformed, tncpi-port01 enable-disable spec!"
      exit 1;
   fi
if grep -q -e "tncpi-port02:ENABLE" -e "tncpi-port02:DISABLE" $templocalfile; then
      echo -n; #"found port2 enable-disable spec OK";
   else
      echo "ERROR: node.ini has no, or malformed, tncpi-port02 enable-disable spec!"
      exit 1;
   fi
if grep -q -e "tncpi-port03:ENABLE" -e "tncpi-port03:DISABLE" $templocalfile; then
      echo -n; #"found port3 enable-disable spec OK";
   else
      echo "ERROR: node.ini has no, or malformed, tncpi-port03 enable-disable spec!"
      exit 1;
   fi
if grep -q -e "tncpi-port04:ENABLE" -e "tncpi-port04:DISABLE" $templocalfile; then
      echo -n; #"found port4 enable-disable spec OK";
   else
      echo "ERROR: node.ini has no, or malformed, tncpi-port04 enable-disable spec!"
      exit 1;
   fi
if grep -q -e "tncpi-port05:ENABLE" -e "tncpi-port05:DISABLE" $templocalfile; then
      echo -n; #echo "found port5 enable-disable spec OK";
   else
      echo "ERROR: node.ini has no, or malformed, tncpi-port05 enable-disable spec!"
      exit 1;
   fi
if grep -q -e "tncpi-port06:ENABLE" -e "tncpi-port06:DISABLE" $templocalfile; then
      echo -n; #echo "found port6 enable-disable spec OK";
   else
      echo "ERROR: node.ini has no, or malformed, tncpi-port06 enable-disable spec!"
      exit 1;
   fi

if grep -q -e "usb-port07:ENABLE" -e "usb-port07:DISABLE" $templocalfile; then
      echo -n; #"found port7 enable-disable spec OK";
   else
      echo "ERROR: node.ini has no, or malformed, tncpi-port07 enable-disable spec!"
      exit 1;
   fi
if grep -q -e "usb-port08:ENABLE" -e "usb-port08:DISABLE" $templocalfile; then
      echo -n; #"found port8 enable-disable spec OK";
   else
      echo "ERROR: node.ini has no, or malformed, usb-port08 enable-disable spec!"
      exit 1;
   fi
if grep -q -e "usb-port09:ENABLE" -e "usb-port09:DISABLE" $templocalfile; then
      echo -n; #"found port9 enable-disable spec OK";
   else
      echo "ERROR: node.ini has no, or malformed, usb-port09 enable-disable spec!"
      exit 1;
   fi
if grep -q -e "usb-port10:ENABLE" -e "usb-port10:DISABLE" $templocalfile; then
      echo -n; #"found port10 enable-disable spec OK";
   else
      echo "ERROR: node.ini has no, or malformed, tncpi-port10 enable-disable spec!"
      exit 1;
   fi
if grep -q -e "usb-port11:ENABLE" -e "usb-port11:DISABLE" $templocalfile; then
      echo -n; #echo "found port11 enable-disable spec OK";
   else
      echo "ERROR: node.ini has no, or malformed, usb-port11 enable-disable spec!"
      exit 1;
   fi
if grep -q -e "usb-port12:ENABLE" -e "usb-port12:DISABLE" $templocalfile; then
      echo -n; #echo "found port12 enable-disable spec OK";
   else
      echo "ERROR: node.ini has no, or malformed, usb-port12 enable-disable spec!"
      exit 1;
   fi

if grep -q -e "chatcall:"  $templocalfile; then
      echo -n; #echo "found crowdcall spec OK";
   else
      #echo "ERROR: node.ini has no, or malformed, chatcall spec!"
      sudo sed -i 's/crowdcall:/chatcall:/g' $templocalfile
	    if grep -q -e "chatcall:"  $templocalfile; then
           echo -n; #echo "found chatcall spec OK on second look";
       else
           echo "ERROR: node.ini has no, or malformed, chatcall spec! -- run tarpn config"
           exit 1;
       fi
   fi




### Enable and disable the 6 ports.
### This code finds the string port1:ENABLE or port1:DISABLE in the local config file.
### If the string is port1:ENABLE, it goes into the outputfile and s every string
### that is q~port1~q.
### if the string is port1:DISABLE, it goes into the outputfile and turns every q~port1~q into a comment.
### Finally, the port1:ENABLE or port1:DISABLE is d from the local config file and replaced
#### with synbol qq~~qq which means "blank line"

if grep -q -e "tncpi-port01:ENABLE" $templocalfile; then
      echo  "tncpi-port01 enabled";
      sed -i 's=q~tncpi-port01~q==' $temp_outwork1file
      sed -i 's=tncpi-port01:ENABLE=qq~~qq:qq~~qq=' $templocalfile
   else
      echo  "tncpi-port01 disabled";
      sed -i 's=q~tncpi-port01~q=;=' $temp_outwork1file
      sed -i 's=tncpi-port01:DISABLE=qq~~qq:qq~~qq=' $templocalfile
   fi
if grep -q -e "tncpi-port02:ENABLE" $templocalfile; then
      echo  "tncpi-port02 enabled";
      sed -i 's=q~tncpi-port02~q==' $temp_outwork1file
      sed -i 's=tncpi-port02:ENABLE=qq~~qq:qq~~qq=' $templocalfile
   else
      echo  "tncpi-port02 disabled";
      sed -i 's=q~tncpi-port02~q=;=' $temp_outwork1file
      sed -i 's=tncpi-port02:DISABLE=qq~~qq:qq~~qq=' $templocalfile
   fi
if grep -q -e "tncpi-port03:ENABLE" $templocalfile; then
      echo  "tncpi-port03 enabled";
      sed -i 's=q~tncpi-port03~q==' $temp_outwork1file
      sed -i 's=tncpi-port03:ENABLE=qq~~qq:qq~~qq=' $templocalfile
   else
      echo  "tncpi-port03 disabled";
      sed -i 's=q~tncpi-port03~q=;=' $temp_outwork1file
      sed -i 's=tncpi-port03:DISABLE=qq~~qq:qq~~qq=' $templocalfile
   fi
if grep -q -e "tncpi-port04:ENABLE" $templocalfile; then
      echo  "tncpi-port04 enabled";
      sed -i 's=q~tncpi-port04~q==' $temp_outwork1file
      sed -i 's=tncpi-port04:ENABLE=qq~~qq:qq~~qq=' $templocalfile
   else
      echo  "tncpi-port04 disabled";
      sed -i 's=q~tncpi-port04~q=;=' $temp_outwork1file
      sed -i 's=tncpi-port04:DISABLE=qq~~qq:qq~~qq=' $templocalfile
   fi
if grep -q -e "tncpi-port05:ENABLE" $templocalfile; then
      echo  "tncpi-port05 enabled";
      sed -i 's=q~tncpi-port05~q==' $temp_outwork1file
      sed -i 's=tncpi-port05:ENABLE=qq~~qq:qq~~qq=' $templocalfile
   else
      echo  "tncpi-port05 disabled";
      sed -i 's=q~tncpi-port05~q=;=' $temp_outwork1file
      sed -i 's=tncpi-port05:DISABLE=qq~~qq:qq~~qq=' $templocalfile    #### Fix bug in this line v043
   fi
if grep -q -e "tncpi-port06:ENABLE" $templocalfile; then
      echo  "tncpi-port06 enabled";
      sed -i 's=q~tncpi-port06~q==' $temp_outwork1file
      sed -i 's=tncpi-port06:ENABLE=qq~~qq:qq~~qq=' $templocalfile
   else
      echo  "tncpi-port06 disabled";
      sed -i 's=q~tncpi-port06~q=;=' $temp_outwork1file
      sed -i 's=tncpi-port06:DISABLE=qq~~qq:qq~~qq=' $templocalfile
   fi
######### NOW do USB ports
if grep -q -e "usb-port07:ENABLE" $templocalfile; then
      echo  "usb-port07 enabled";
      sed -i 's=q~usb-port07~q==' $temp_outwork1file
      sed -i 's=usb-port07:ENABLE=qq~~qq:qq~~qq=' $templocalfile
   else
      echo  "usb-port07 disabled";
      sed -i 's=q~usb-port07~q=;=' $temp_outwork1file
      sed -i 's=usb-port07:DISABLE=qq~~qq:qq~~qq=' $templocalfile
   fi

if grep -q -e "usb-port08:ENABLE" $templocalfile; then
      echo  "usb-port08 enabled";
      sed -i 's=q~usb-port08~q==' $temp_outwork1file
      sed -i 's=usb-port08:ENABLE=qq~~qq:qq~~qq=' $templocalfile
   else
      echo  "usb-port08 disabled";
      sed -i 's=q~usb-port08~q=;=' $temp_outwork1file
      sed -i 's=usb-port08:DISABLE=qq~~qq:qq~~qq=' $templocalfile
   fi
if grep -q -e "usb-port09:ENABLE" $templocalfile; then
      echo  "usb-port09 enabled";
      sed -i 's=q~usb-port09~q==' $temp_outwork1file
      sed -i 's=usb-port09:ENABLE=qq~~qq:qq~~qq=' $templocalfile
   else
      echo  "usb-port09 disabled";
      sed -i 's=q~usb-port09~q=;=' $temp_outwork1file
      sed -i 's=usb-port09:DISABLE=qq~~qq:qq~~qq=' $templocalfile
   fi
if grep -q -e "usb-port10:ENABLE" $templocalfile; then
      echo  "usb-port10 enabled";
      sed -i 's=q~usb-port10~q==' $temp_outwork1file
      sed -i 's=usb-port10:ENABLE=qq~~qq:qq~~qq=' $templocalfile
   else
      echo  "usb-port10 disabled";
      sed -i 's=q~usb-port10~q=;=' $temp_outwork1file
      sed -i 's=usb-port10:DISABLE=qq~~qq:qq~~qq=' $templocalfile
   fi
if grep -q -e "usb-port11:ENABLE" $templocalfile; then
      echo  "usb-port11 enabled";
      sed -i 's=q~usb-port11~q==' $temp_outwork1file
      sed -i 's=usb-port11:ENABLE=qq~~qq:qq~~qq=' $templocalfile
   else
      echo  "usb-port11 disabled";
      sed -i 's=q~usb-port11~q=;=' $temp_outwork1file
      sed -i 's=usb-port11:DISABLE=qq~~qq:qq~~qq=' $templocalfile
   fi
if grep -q -e "usb-port12:ENABLE" $templocalfile; then
      echo  "usb-port12 enabled";
      sed -i 's=q~usb-port12~q==' $temp_outwork1file
      sed -i 's=usb-port12:ENABLE=qq~~qq:qq~~qq=' $templocalfile
   else
      echo  "usb-port12 disabled";
      sed -i 's=q~usb-port12~q=;=' $temp_outwork1file
      sed -i 's=usb-port12:DISABLE=qq~~qq:qq~~qq=' $templocalfile
   fi

##### CHAT CHAT CROWD CHAT CROWD CHAT CROWD CHAT CROWD CHAT CROWD #########
#echo "##### do CROWD node work"
if grep -q -e "chatcall:not_set" $templocalfile; then
      echo "CHAT callsign is missing"
       echo "ERROR: no, or malformed, CHAT callsign spec!"
      exit 1;
else
      echo "apply CHAT option to node";
fi

######## BBS BBS BBS BBS BBS BBS BBS BBS BBS BBS BBS BBS BBS BBS #######
if grep -q -e "bbscall:not_set" $templocalfile; then
      echo "Disable BBS application";
      sed -i 's=q~bbs-enable~q=;;; BBS is Disabled because bbscall is not_set !=' $temp_outwork1file
      sed -i 's=q~bbs-support~q=0=' $temp_outwork1file
else
      echo "Enable BBS application";
      sed -i 's=q~bbs-enable~q==' $temp_outwork1file
      sed -i 's=q~bbs-support~q=1=' $temp_outwork1file
fi




###### Uppercase the node callsign and node name
#### The BOILERPLATE calls for both uppercase AND lowercase versions of the callsign.  
#### The node.ini file has lower case callsigns and nodenames
if grep -q -e "nodecall:" $templocalfile;
then
      _node_callsign=$(grep "nodecall" $templocalfile)
      _upper_node_callsign=${_node_callsign^^}
         echo $_upper_node_callsign >> $templocalfile;
fi
if grep -q -e "nodename:" $templocalfile;
then
      _node_callsign=$(grep "nodename" $templocalfile)
      _upper_node_callsign=${_node_callsign^^}
         echo $_upper_node_callsign >> $templocalfile;
fi


##### DISABLE or ENABLE local HOST mode based on whether local op callsign is "none" or something else.
if grep -q -e "local-op-callsign:none" $templocalfile; then
      echo  "no local op callsign set -- disable HOST mode";
      sed -i 's=q~host-enable~q=;DISABLED -- callsign was none=' $temp_outwork1file
      sed -i 's=q~host-mode-echo~q=NO-HOST-MODE=' $temp_outwork1file
   else
      echo  "local-op-callsign is specified.  Enable HOST mode";
      sed -i 's=q~host-enable~q==' $temp_outwork1file
      sed -i 's=q~host-mode-echo~q=HOST-MODE-ENABLED=' $temp_outwork1file
   fi



####### Create a ChatNode name from the chatcall
TEMPFILE=/home/pi/tempfileforchatnode.tmp
#echo "readfigure(" $1 ")"
#cp $templocalfile /home/pi/foo.2
#echo "read from " $templocalfile
#rm /home/pi/test.tmp
#grep "chatcall" $templocalfile > /home/pi/test.tmp
#echo "grep chatcall =" 
#cat /home/pi/test.tmp
#echo " "
####if grep -q -e "chatcall" $templocalfile;
if grep -e "chatcall" $templocalfile;
then
        IFS=:
        rm -f $TEMPFILE
        grep "chatcall" $templocalfile > $TEMPFILE
        read key chatcall < $TEMPFILE
        #echo "key " $key
        #echo "value " $chatcall
else
        echo "No chatcall found in node.ini file.  Abort!"
        exit 1;
fi


nodecallandsuffix=$chatcall-
ssid=00$(echo "$nodecallandsuffix" | awk -F '-' '{print $(NF-1)}');
#echo "ssid" $ssid;
#echo "chatcall" $chatcall;


endcallvalue=$(echo "$chatcall" | awk -F '-' '{print $(NF-1)}');
lastthreeofcall=${endcallvalue: -3}
lasttwodigitsofssid=${ssid: -2}
chatnode="z"$lastthreeofcall$lasttwodigitsofssid;
echo "chatnode:"$chatnode >> $templocalfile
#echo "chatnode has been written to " $templocalfile
#grep chatnode $templocalfile

######## OK.  chatnode: has been written to 
#debug ----->cp $templocalfile /home/pi/foo.foo




#echo "##### Read through local copy of config file, create keyname value list"

#### Read through the LOCAL config file, creating a list of KEYNAMES and VALUES.
while IFS=: read key value; do
    declare -A hash[$key]=$value
done < $templocalfile

rm $templocalfile

## Diagnostic Output
#echo " "
#echo "This is a list of the KEYNAMES and the values for those names"
#for key in "${!hash[@]}"
#do
#  echo "'$key':'${hash[$key]}'"
#done

### Diagnostic Output
#echo " "
#echo "This is the BOILERPLATE lines where KEYNAMES were found:"
#for key in "${!hash[@]}"
#do
#  grep "q~$key~q" $boilerplatefile;
#done



####
#### This loop will go through each element of the LOCAL config file, pulling
#### out the KEYNAME (first item on each line) and searching for that KEYNAME
#### in the boilerplate file.  Wherever the KEYNAME is found, it is replaced
#### with the value specified in the LOCAL config file.
#### If any KEYNAME exists that is NOT in the boilerplate file, thi#!/bin/bash

##### Make sure there are no token-like figures in the local config file


if grep -q "~q" $filetoread; then
        echo "ERROR: Reserved character sequence(s) found in node.ini"
        echo "       Please remove the ~q figure from node.ini"
        grep "~q" $filetoread;
        exit 1;
        fi

if grep -q "q~" $filetoread; then
        echo "ERROR: Reserved character sequence(s) found in node.ini"
        echo "       Please remove the q~ figure from the node.ini file"
        grep "q~" $filetoread;
        exit 1;
        fi

if grep -q "~SP~" $filetoread; then
        echo "ERROR: Reserved character sequence(s) found in node.ini"
        echo "       Please remove the ~SP~ figure from the node.ini file"
        grep "~SP~" $filetoread;
        exit 1;
        fi

#### back-up the node.ini file
cp $filetoread $templocalfile
#### Convert spaces in the node.ini file to tokens.
sed -i 's= =~SP~=g' $templocalfile

#### Remove trailing tokens
sed -i 's/~SP~$//g'  $templocalfile
sed -i 's/~SP~$//g'  $templocalfile

#### Verify that node.ini is created.
if grep -q -e "tncpi-port01:ENABLE" -e "tncpi-port01:DISABLE" $templocalfile; then
      echo -n; #"found port1 enable-disable spec OK";
   else
          echo "ERROR: Incorrect specification in node.ini"
      echo "ERROR: no, or malformed, tncpi-port01 enable-disable spec!"
      exit 1;
   fi
if grep -q -e "tncpi-port02:ENABLE" -e "tncpi-port02:DISABLE" $templocalfile; then
      echo -n; #"found port2 enable-disable spec OK";
   else
          echo "ERROR: Incorrect specification in node.ini"
      echo "ERROR: no, or malformed, tncpi-port02 enable-disable spec!"
      exit 1;
   fi
if grep -q -e "tncpi-port03:ENABLE" -e "tncpi-port03:DISABLE" $templocalfile; then
      echo -n ; #"found port3 enable-disable spec OK";
   else
          echo "ERROR: Incorrect specification in node.ini"
      echo "ERROR: no, or malformed, tncpi-port03 enable-disable spec!"
      exit 1;
   fi
if grep -q -e "tncpi-port04:ENABLE" -e "tncpi-port04:DISABLE" $templocalfile; then
      echo -n; #"found port4 enable-disable spec OK";
   else
          echo "ERROR: Incorrect specification in node.ini"
      echo "ERROR: no, or malformed, tncpi-port04 enable-disable spec!"
      exit 1;
   fi
if grep -q -e "tncpi-port05:ENABLE" -e "tncpi-port05:DISABLE" $templocalfile; then
      echo -n; #echo "found port5 enable-disable spec OK";
   else
          echo "ERROR: Incorrect specification in node.ini"
      echo "ERROR: no, or malformed, tncpi-port05 enable-disable spec!"
      exit 1;
   fi
if grep -q -e "tncpi-port06:ENABLE" -e "tncpi-port06:DISABLE" $templocalfile; then
      echo -n; #echo "found port6 enable-disable spec OK";
   else
          echo "ERROR: Incorrect specification in node.ini"
      echo "ERROR: no, or malformed, tncpi-port06 enable-disable spec!"
      exit 1;
   fi



if grep -q -e "nodename:" $templocalfile; then
      echo -n;
   else
          echo -n "ERROR: Incorrect specification in "
          echo $filetoread
      echo "ERROR: Node nodename spec!"
      exit 1;
   fi




#echo "##### Key list - convert Keys to values in work1file"


#### We believe we have a node.ini file
for key in "${!hash[@]}"
  do
    startstring="q~$key~q";
    #echo $startstring;
    if [ $startstring == "q~qq~~qq~q" ]; then
       echo -n
        else
       #echo "##### Looking for -->$startstring<-- to change it to -->${hash[$key]}<--";
       if grep -q "$startstring" $temp_outwork1file; then
         sed -i 's='$startstring'='${hash[$key]}'=g' $temp_outwork1file
         #cat $temp_outwork1file;
       else
         echo -n "ERROR: NO MATCH    "
         echo $key
         echo "ERROR: Unexpected token in node.ini file! -- not found in boilerplate"
         exit 1;
       fi
    fi
 done
#echo "##### done with Key list.  Now replace special symbols"

## Now translate the SPACE tokens for real spaces
#echo "translate SPACE tokens"
sed -i 's=~SP~= =g' $temp_outwork1file

## Now translate the SINGLEQUOTE tokens for real single quotes
#echo "translate SINGLEQUOTE tokens"
sed -i "s=~SINGLEQUOTE~='=g" $temp_outwork1file
sed -i "s=~OPENPAREN~=(=g" $temp_outwork1file
sed -i "s=~CLOSEPAREN~=)=g" $temp_outwork1file

## Remove infotext blanklines
sed -i ':a; /BLANKLINE$/ { N; s/BLANKLINE\n//; ba; }' $temp_outwork1file
##sed -i 's=BLANKLINE\n==' $temp_outwork1file

## Translate the <CR> symbols with carriage returns
#echo "translate CRLF tokens"
sed -i 's=CRLF=\n=g' $temp_outwork1file
#sed ':a;N;$!ba;s/\n/ /g'

#echo "verify that tokens are all d"
##### Now verify that all of the tokens have been replaced in the output file.
if grep -q "~q" $temp_outwork1file; then
        echo "ERROR: Unresolved token(s) for bpq config - look in node.ini?"
        echo "       Please add or fix the spelling of this (these) token in the node.ini file"
        grep "~q" $temp_outwork1file;
        exit 1;
        fi
if grep -q "q~" $temp_outwork1file; then
        echo "ERROR: Unresolved token(s) for bpq config - look in node.ini?"
        echo "       Please add or fix the spelling of this (these) token in the node.ini file"
        grep "q~" $temp_outwork1file;
        exit 1;
        fi

if grep -q -e "op is none" $templocalfile; then
      sed -i 's=op is none=see http://tarpn.net for info=' $temp_outwork1file
   fi

### We are done!
mv $temp_outwork1file $outputfile

#### Create the Files folder if one does not exist
if [ ! -d $filesFolderForBbs ];
then
   mkdir $filesFolderForBbs
fi

grep -v "^PASSWORD=" $outputfile | grep -v "sysop password" | grep -o '^[^;]*' > $temp_outwork1file

awk 'sub("$", "\r")' $temp_outwork1file > $bpqConfigImageInFilesFolder
rm $temp_outwork1file
echo "SUCCESS..."
