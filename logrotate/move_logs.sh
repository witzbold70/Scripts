#!/bin/bash
###----------------------------------------------------------------------------
### Script Name:    move_logs.sh
### Author:         Daniel D. Jones
### Date:           04/24/2014
### Description:    Moves logs older than defined days to NFS Log Backup share
###----------------------------------------------------------------------------

## Miscellaneous Variables
ScriptName=$(basename "$0")
SysName=$(echo `hostname`|cut -d. -f1)

## Email Related
EmailCmd=$(which mail)
EmailTo='wfs_sysadmins@westlakefinancial.com'
EmailFrom='wfs_alerts@westlakefinancial.com'

# Function to send email
function EmailIt {
   # 1) Email Subject
   # 2) Email Body
   echo "$2"|$EmailCmd -s "$1" $EmailTo -- -r $EmailFrom
}

### Number of days old to move archives
ArchDays=14

### Old files list
OldFileList=/tmp/oldfiles.lst
if [ -f $OldFileList ]
then
    rm $OldFileList
else
    touch $OldFileList
fi

### Moves rotated logs older than 14 days to NFS Log Backup share
LogPath=/u01/DBSync/DBSync.linux.x86_64/logs/backup
if [ ! -d $LogPath ]
then
    EmailIt "$SysName: $ScriptName - FAILURE" "Log path is missing: $LogPath. Please investigate!!!"
    exit
fi

### Check if Archive Logs NFS is mount, if not, mount it
ArchNFS=wfslxvpnfs4:/archives/oradr1/dbsync
ArchNFSMount=/archivelogs
if [ $(mount|grep "$ArchNFS"|wc -l) -ne 1 ]
then
    mount $ArchNFS $ArchNFSMount
    if [ $? -ne 0 ]
    then
        EmailIt "$SysName: $ScriptName - FAILURE" "Unable to mount $ArchNFS to $ArchNFSMount. Please investigate!!!"
        exit
    fi
fi

### Path to archive log files to. Archive path is /logbackup/YYYY/MM
ArchPath=$ArchNFSMount/$(date +"%Y/%m")
if [ ! -d $ArchPath ]
then
    mkdir -p $ArchPath
fi

## Find logs older that $ArchDays days and move them
cd $LogPath
find . -mtime +$ArchDays -exec echo "{}">>$OldFileList \;
for f in $(cat $OldFileList)
do
    mv $f $ArchPath
    if [ $? -ne 0 ]
    then
        EmailIt "$SysName: $ScriptName - FAILURE" "Move of $f to $ArchPath FAILED. Please investigate!!!"
        exit
    fi
done
EmailIt "$SysName: $ScriptName - SUCCESS" "All files successfully moved to $ArchPath"
