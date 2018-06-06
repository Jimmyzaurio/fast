#!/bin/bash

raiz='/home/cyberbae/Documents/server/poller/memoria'
graph_dir='/home/cyberbae/Documents/server/poller/memoria'
log="$raiz/log/sping.log"

function escribe_log()
{
    echo "`date '+%m/%d %H:%M:%S'` $IP" >> $log
}

DIREC[0]="localhost"
DIREC[1]="192.168.1.84"

#DIREC[0]="192.168.232."
#DIREC[1]="192.168.232."
#DIREC[2]="192.168.232."

for IP in "${DIREC[@]}"
do
    salida_get=`snmpget -v 2c -c public $IP hrStorageUsed.1`
    retval=$?

    if [ $retval -eq 0 ] # obtuvimos algunas respuestas
    then
        ans=`echo $get | grep -o 'INTEGER: [0-9]\+'`
        arr=($ans)
        mem_usada=${arr[1]}

        recvd=`echo $salida_ping | grep -o '[0-9]\+ received'`
        recvd=${recvd% received}
        lost=`expr 20 - $recvd`
    elif [ $retval -eq 1 ] # no hubo respuesta
    then
        mem_usada='U'
    elif [ $retval -eq 2 ] # el host no se encontró 
    then
        escribe_log "host desconocido $IP"
        exit $retval
    else # otros
        escribe_log "error pinging $IP error : $retval"
        exit $retval
    fi

    if [ ! -f $raiz/rrd/$IP.rrd ] # crear rrd si no existe
    then
        rrdtool create $raiz/rrd/$IP.rrd \
        --step 60 \
        DS:memoria_usada:COUNTER:120:0:20 \
        RRA:MAX:0.5:1:525600

        retval=$?

        if [ $retval -gt 0 ]
        then
            escribe_log "no se pudo crear el archivo rrd para la ip $IP, error: $retval"
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


  #sudo ping $IP -c 1
  packet_loss=$(sudo ping -c 1 -q $IP | grep -oP '\d+(?=% packet loss)')
  echo "$IP % de perdida: $packet_loss"

  # SWAKS to admin mail 
  if [ "$packet_loss" -ge 40 ]; then
    swaks -f jsp.saucedo@gmail.com -t jsp.saucedo@gmail.com
    echo -e "\tEnviando email de ALERTA"
  fi

done


