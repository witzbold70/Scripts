#!/bin/bash
##----------------------------------------------------------------------------
## Script Name:    es_retension.sh
## Author:         Daniel D. Jones
## Date:           11/25/2014
## Description:    Removed indices older than a certain amount and backs up
##                 SnapShots of the same time period.
##----------------------------------------------------------------------------

ScriptDir=/usr/local/scripts/elasticsearch
source $ScriptDir/inc/vars.sh
source $ScriptDir/inc/funcs.sh

###################################
#---------- MAIN SCRIPT ----------#
###################################

## List of Indices split into date only
AllIndices=$(ls $IndiceDir|grep "logstash"|grep -v "int"|cut -d- -f2)

## Start Date
StartDate=$(date -d "$RetDays days ago" +%Y.%m.%d)
Failures=0
Successes=0

## Go through Indice list
for Indice in $(echo $AllIndices)
do
    i=$(echo $Indice|tr -d ".")
    if [ "$(date -d $i +%Y%m%d)" -lt "$(date -d "$RetDays days ago" +%Y%m%d)" ]
    then
        IndiceDelete $Indice
        ### Check if Indice Delete completed successfully.
        if [ $(cat $ESOut|grep '"acknowledged":true'|wc -l) -eq 1 ]
        then
            echo "$(GetNow): SUCCESS - Delete Indice logstash-$Indice" >> $RunLog
            Successes=$((Successes + 1))
        else
            echo "$(GetNow): FAILED - Delete Indice logstash-$Indice" >> $RunLog
            Failures=$((Failures + 1))
        fi
        $CurrArchiveDir=$ArchiveDir/$(date -d $i +%Y)/$(date -d $i +%m)
        if [ ! -d $CurrArchiveDir ]
        then
            mkdir -p $CurrArchiveDir
        fi
        ## Create GZip of SnapShot files and remove after Indice has been successfully removed
        tar -zcvf $CurrArchiveDir/ES_ARCHIVE_${ESEnv}_SNAPSHOT_$(date -d %i +%Y%m%d).tar.gz $RepoDir/metadata-$i.$(echo $ESEnv|tr '[:upper:]' '[:lower:]') $RepoDir/snapshot-$i.$(echo $ESEnv|tr '[:upper:]' '[:lower:]')
        tar -zcvf $CurrArchiveDir/ES_ARCHIVE_${ESEnv}_INDICES_$(date -d %i +%Y%m%d).tar.gz $RepoDir/indices/logstash-$(date -d $i +'%Y.%m.%d')
        rm $ReporDir/metadata-$i.$(echo $ESEnv|tr '[:upper:]' '[:lower:]')
        rm $ReporDir/snapshot-$i.$(echo $ESEnv|tr '[:upper:]' '[:lower:]')
        rm -R $RepoDir/indices/logstash-$(date -d $i +'%Y.%m.%d')
    fi
done

## Optimize the Indices
echo "$(date +%Y-%m-%d): Optimizing Indices" >> $RunLog
IndiceOptimize

if [ $Successes -eq 0 ] && [ $Failures -eq 0 ]
then
    Subject="SUCCESS: ES $ESEnv INDICE DELETE - NO INDICES TO DELETE"
    echo "$(GetNow): $Subject" >> $RunLog
else
    ## Check for any failures and email appropriately
    if [ $Failures -gt 0 ]
    then
        Subject="FAILURE: ES $ESEnv INDICE DELETE - $Failures FAILED"
    else
        Subject="SUCCESS: ES $ESEnv INDICE DELETE - $Successes PROCESSED"
    fi
    echo "" >> $RunLog
    echo "$(GetNow): SUCCESSES - $Successes" >> $RunLog
    echo "$(GetNow): FAILURES - $Failures" >> $RunLog
fi
## Send out completion email
EmailIt "$Subject" "$RunLog"
