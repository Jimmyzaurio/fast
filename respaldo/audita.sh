#!/bin/bash 

USER="rcp"
PASSWD="rcp"

DIR="/root/server/respaldo/r"
FILE="startup-config"

ROUTER_IP[0]="192.168.232.5"
ROUTER_IP[1]="192.168.232.9"
ROUTER_IP[2]="192.168.205.15"

checar() {

cambia_dir="cd $DIR$1"
$cambia_dir

ftp -n -v ${ROUTER_IP[$1]} <<END_SCRIPT
    user $USER $PASSWD
    get $FILE aux
    bye
END_SCRIPT

uno="startup-config"
dos="aux"

if ! cmp "$uno" "$dos"
then
# MANDAR CORREO DE AVISO AL ADMIN
#
    swaks -t jspsaucedo@gmail.com -tls -s smtp.gmail.com:587 -a -au redes.bolillo@gmail.com -ap redes.bolillo --header "Subject: Configuracion router ${ROUTER_IP[$1]}" --body "Verificar la configuracion del router ${ROUTER_IP[$1]}"

ftp -n -v ${ROUTER_IP[$1]} <<END_SCRIPT
    user $USER $PASSWD
    put $FILE
    bye
END_SCRIPT
fi

}

for i in "${!ROUTER_IP[@]}"; do
    checar $i
done

