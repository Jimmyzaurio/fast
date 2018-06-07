#!/bin/bash

raiz='/root/server/poller/memoria'
graph_dir='/root/server/server/poller/memoria'
log="$raiz/log/sping.log"

function escribe_log()
{
    echo "`date '+%m/%d %H:%M:%S'` $IP" >> $log
}

DIREC[0]="192.168.205.15"

for IP in "${DIREC[@]}"
do
    salida_get=`snmpget -v 2c -c public $IP hrStorageUsed.1`
    retval=$?

    if [ $retval -eq 0 ] # se ejecutó correctamente 
    then
        ans=`echo $salida_get | grep -o 'INTEGER: [0-9]\+'`
        arr=($ans)
        mem_usada=${arr[1]}
        #echo $mem_usada
    else # otros
        escribe_log "error pinging $IP error : $retval"
        exit $retval
    fi

    if [ ! -f $raiz/rrd/$IP.rrd ] # crear rrd si no existe
    then
        rrdtool create $raiz/rrd/$IP.rrd \
        --step 60 \
        DS:mem_usada:COUNTER:120:0:20 \
        RRA:MAX:0.5:1:525600

        retval=$?

        if [ $retval -gt 0 ]
        then
            escribe_log "no se pudo crear el archivo rrd para la ip $IP, error: $retval"
            swaks -t redes.bolillo@gmail.com -s smtp.gmail.com:587 -tls -a -au redes.bolillo@gmail.com -ap redes.bolillo@gmail.com --header "Subject: Error snmpget $IP" --body "No se pudo recibir la informacion de snmpget, revisar estado del router $IP"
            exit 200
        fi
    fi

    timestamp=`date +"%s"`
    rrdtool update $raiz/rrd/$IP.rrd $timestamp:$mem_usada

    retval=$?

    if [ $retval -gt 0 ]
    then
        escribe_log "rrd update para $IP falló error : $retval"
        exit 201
    fi

done


