#!/bin/bash
##----------------------------------------------------------------------------
## Script Name:    vars.sh
## Author:         Daniel D. Jones
## Date:           11/25/2014
## Description:    Variables for main script
##----------------------------------------------------------------------------

## Miscellaneous Variables
ScriptName=$(basename "$0" .sh)
SysName=$(hostname|cut -d. -f1)
CurlBin=/usr/bin/curl
RetDays=90

## ES Variables
ESServer="wfslxvdsysmgt2"
ESRepo="WFS-ES-BACKUP"
ESEnv="NONPROD"
ESOut="/tmp/es_output.out"
if [ -f $ESOut ]
then
   rm $ESOut
fi
ArchiveDir=/repository/WFS-ES-ARCHIVES
RepoDir=/repository/WFS-ES-BACKUP
IndiceDir=/u01/elasticsearch/data/WFS-$ESEnv-ES/nodes/0/indices

## Actions Temp Log
RunLog=/tmp/${ScriptName}_run.log
if [ -f $RunLog ]
then
   rm $RunLog
fi

## Email Related
export EMAIL='ES Scripts <es_scripts@westlakefinancial.com>'
EmailCmd=/usr/bin/mutt
EmailTo="wfs_sysadmins@westlakefinancial.com"

## ES NFS Repository
ESRepoNFS="wfslxvpnfs4:/archives/elasticsearch/$(echo $ESEnv|tr '[:upper:]' '[:lower:]')"
ESRepoMount="/repository"

## ES SnapShot Vars
SnapName="$(date +"%Y%m%d").$(echo $ESEnv|tr '[:upper:]' '[:lower:]')"
SnapOpts="wait_for_completion=true&format=yaml"
