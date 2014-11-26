#!/bin/bash
###----------------------------------------------------------------------------
### Script Name:    dbsync_swatch_rotate.sh
### Author:         Daniel D. Jones
### Date:           04/24/2014
### Description:    Stops dbsync_swatch.sh, runs logroate:dbsync, runs 
###                 move_logs.sh, then starts dbsync_swatch.sh
###----------------------------------------------------------------------------
ScriptDir=/usr/local/scripts/dbsync_swatch
$ScriptDir/dbsync_swatch.sh stop
sleep 5
/usr/sbin/logrotate /etc/logrotate.d/dbsync_logs
sleep 5
/usr/local/scripts/logrotate/move_logs.sh
sleep 5
$ScriptDir/dbsync_swatch.sh start
