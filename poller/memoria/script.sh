#!/bin/bash

get=`snmpget -v 2c -c public 192.168.205.15 hrStorageUsed.1`

ans=`echo $get | grep -o 'INTEGER: [0-9]\+'`
arr=($ans)
echo ${arr[1]}
