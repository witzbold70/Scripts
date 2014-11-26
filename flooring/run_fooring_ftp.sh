#!/bin/bash

## Non-Prod
SFTPHost=ftp-acc.us.sword-apak.com
## Production
# SFTPHost='ftp.us.sword-apak.com'
## SFTP User
SFTPUser=westlake

## Email
# Test
EmailTo="shaward@westlakefinancial.com"
# Prod
#EmailTo="sysadmins@westlakefinancial.com"

## Global Variables
ScriptDir=/opt/flooring
DownloadDir=$ScriptDir/download

## Create Processed folder if not exists
ProcessDir=$ScriptDir/processed
if [ ! -d $ProcessDir ]; then
  mkdir $ProcessDir
fi
## SFTP Temp Script
SFTPScript=/tmp/sftp.txt

## Files to retrieve
DONE="DONE_DWH_$(date +%Y-%m-%d -d "yesterday").txt"
FILE1="MASTER_DATA_$(date +%Y-%m-%d -d "yesterday").xml"
FILE2="WST_Checks_$(date +%Y-%m-%d -d "yesterday").xml"  
FILE3="$(date +%Y%m%d -d "yesterday")_????_APAKCLIENT_WESTLAKE_GL.xml"

## Create SFTP batch script file
echo "cd outbox" > $SFTPScript
echo "lcd $ScriptDir" >> $SFTPScript
echo "get $DONE" >> $SFTPScript
echo "get $FILE1" >> $SFTPScript
echo "get $FILE2" >> $SFTPScript
echo "get $FILE3" >> $SFTPScript
echo "bye" >> $SFTPScript

## SFTP Files
sftp -b $SFTPScript -o "IdentityFile=/opt/flooring/ssh/id_rsa" $SFTPUser@$SFTPHost

if [ -f $DONE ]
then
    echo "FTP of $DONE worked"
else
    echo "FTP of $DONE did not work"|mail -s "$(date) FTP $DONE failed!" $EmailTo
    exit -1
fi
if [ -f $FILE1 ]
then
    echo "FTP of $FILE1 worked"
    sh /opt/flooring/run_flooring_dwh.sh        
else
    echo "FTP of $FILE1 did not work"|mail -s "$(date) FTP $FILE1 failed!" $EmailTo
fi

if [ -f $FILE2 ]
then
    echo "FTP of $FILE2 worked"
    sh /opt/flooring/run-flooring-payment.sh
else
    echo "FTP of $FILE2 did not work"| mail -s "$(date) FTP $FILE2 failed!" $EmailTo
fi

if [ -f $FILE3 ]
then
    echo "FTP of $FILE2 worked"
    # run remote kettle job
    ssh 
    mv $FILE3 $ProcessDir
#todo
# when kettle is done FTP result file to Accounting
else
    echo "SFTP of $FILE2 did not work"| mail -s "$(date) FTP $FILE2 failed!" $EmailTo
fi
exit 0
