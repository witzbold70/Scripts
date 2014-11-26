#!/bin/bash
##----------------------------------------------------------------------------
## Script Name:    es_snapshot.sh
## Author:         Daniel D. Jones
## Date:           06/05/2014
## Description:    Creates an ElasticSearch Snapshot
##----------------------------------------------------------------------------

ScriptDir=/usr/local/scripts/elasticsearch
source $ScriptDir/inc/vars.sh
source $ScriptDir/inc/funcs.sh

###################################
#---------- MAIN SCRIPT ----------#
###################################

## Run mount function for ElasticSearch NFS Repository
MountIt $ESRepoNFS $ESRepoMount
RetVal=$?
case $RetVal in
    0) echo "$(GetNow): SUCCESS - ES $ESEnv Snapshot NFS Mount $ESRepoNFS">>$RunLog
       ;;
    1) echo "$(GetNow): SUCCESS - ES $ESEnv Snapshot NFS Mount $ESRepoNFS">>$RunLog
       ;;
    2) echo "$(GetNow): FAILURE - ES $ESEnv Snapshot NFS Mount $ESRepoNFS">>$RunLog
       EmailIt "FAILURE: ES $ESEnv SNAPSHOT" $RunLog
       exit
       ;;
    *) echo "$(GetNow): FAILURE: ES $ESEnv Snapshot NFS Mount $ESRepoNFS">>$RunLog
       EmailIt "FAILURE: ES $ESEnv SNAPSHOT" $RunLog
       exit
       ;;
esac

### Run SnapShot and capture output to log
SnapshotBackup

### Check if Snapshot Backup completed.
if [ $(cat $ESOut|grep 'state: "SUCCESS"'|wc -l) -ne 1 ]
then
    echo "$(GetNow): FAILURE - ES $ESEnv Snapshot create - $SnapName">>$RunLog
    cat $ESOut>>$RunLog
    EmailIt "FAILURE: ES $ESEnv SNAPSHOT CREATE" $RunLog
else
    echo "$(GetNow): SUCCESS - ES $ESEnv Snapshot create - $SnapName">>$RunLog
    cat $ESOut>>$RunLog
    EmailIt "SUCCESS: ES $ESEnv SNAPSHOT CREATE" $RunLog
fi

## Runs ES Retention script to Archive and Remove SnapShots and Indices
$ScriptDir/es_retension.sh &
