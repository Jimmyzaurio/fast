#!/bin/bash 

USER="rcp"
PASSWD="rcp"

DIR="/root/server/respaldo/r"
FILE="startup-config"

ROUTER_IP="192.168.205.15"

inicial() {

cambia_dir="cd $DIR$1"
$cambia_dir

ftp -n -v ${ROUTER_IP} <<END_SCRIPT
    user $USER $PASSWD
    put $FILE
    bye
END_SCRIPT
}

inicial $1
