#!/bin/bash 

USER="rcp"
PASSWD="rcp"

DIR="/root/server/respaldo/r"
FILE="startup-config"

ROUTER_IP[0]="192.168.201.15"
ROUTER_IP[1]="192.168.202.15"
ROUTER_IP[2]="192.168.204.15"

inicial() {

cambia_dir="cd $DIR$1"
$cambia_dir

ftp -n -v ${ROUTER_IP[$1]} <<END_SCRIPT
    user $USER $PASSWD
    put $FILE
    bye
END_SCRIPT
}

for i in "${!ROUTER_IP[@]}"; do
    inicial $i
done

