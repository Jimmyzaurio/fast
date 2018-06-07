#!/bin/bash 

USER="rcp"
PASSWD="rcp"

DIR="/root/server/poller/inventario/r"
FILE="specs"

ROUTER_IP[0]="192.168.232.5"
ROUTER_IP[1]="192.168.232.9"
ROUTER_IP[2]="192.168.205.15"

checar() {

cambia_dir="cd $DIR$1"
$cambia_dir

ftp -n -v ${ROUTER_IP[$1]} <<END_SCRIPT
    user $USER $PASSWD
    get $FILE
    bye
END_SCRIPT

}

for i in "${!ROUTER_IP[@]}"; do
    checar $i
done

