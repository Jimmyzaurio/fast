#!/bin/bash 

USER="rcp"
PASSWD="rcp"

FILE="crea_inventario.sh"

ROUTER_IP[0]="192.168.232.5"
ROUTER_IP[1]="192.168.232.9"
ROUTER_IP[2]="192.168.205.15"

checar() {

ftp -n -v ${ROUTER_IP[$1]} <<END_SCRIPT
    user $USER $PASSWD
    put $FILE
    bye
END_SCRIPT

}

for i in "${!ROUTER_IP[@]}"; do
    checar $i
done

