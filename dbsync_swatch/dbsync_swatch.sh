#!/bin/bash
###----------------------------------------------------------------------------
### Script Name:    dbsync_swatch.sh
### Author:         Daniel D. Jones
### Date:           04/24/2014
### Description:    Monitors DBSync Apply and Extract logs and emails upon error
###----------------------------------------------------------------------------

ScriptDir=/usr/local/scripts/dbsync_swatch
DBSyncDir=/u01/DBSync/DBSync.linux.x86_64
ConfDir=$ScriptDir/conf
PIDDir=$ScriptDir/run
TmpDir=$ScriptDir/tmp
DBSyncLogs="apply_odbc.log apply_odbc_mssql.log extract.log extract_mssql.log"
 
swatch_start()
{
    for log in $(echo $DBSyncLogs)
    do
        /usr/bin/swatch --config-file=$ConfDir/$log.conf --script-dir=$TmpDir --tail-file=$DBSyncDir/$log --pid-file=$PIDDir/$log.pid --daemon > /dev/null >&1
    done
}
 
swatch_stop()
{
    for i in $(echo $DBSyncLogs)
    do
        PID=$(cat $PIDDir/$i.pid)
        kill -9 $PID
        rm $PIDDir/$i.pid
        kill -9 $(ps aux | grep 'swatch' | awk '{print $2}')
    done
    rm -R $TmpDir/.swatch_script*
}
 
case $1 in
    start)
        swatch_start
        exit 0
        ;;
    stop)
        swatch_stop
        exit 0
        ;;
    restart)
        swatch_stop
        swatch_start
        exit 0
        ;;
    *)
        echo "Usage: $0 [start|stop|restart]"
        exit 1
        ;;
esac
