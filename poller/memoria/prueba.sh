#!/bin/bash

raiz='/home/cyberbae/Documents/server/poller/memoria'
graph_dir='/home/cyberbae/Documents/server/poller/memoria'
log="$raiz/log/sping.log"

function escribe_log()
{
    echo "`date '+%m/%d %H:%M:%S'` $IP" >> $log
}

DIREC[0]="192.168.205.15"
#DIREC[1]="192.168.1.84"

#DIREC[0]="192.168.232."
#DIREC[1]="192.168.232."
#DIREC[2]="192.168.232."

for IP in "${DIREC[@]}"
do
    salida_get=`snmpget -v 2c -c public $IP hrStorageUsed.1`
    retval=$?

    echo $retval

done


