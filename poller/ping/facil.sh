#!/bin/bash

base_dir='/home/cyberbae/Documents/server/poller/ping'
graph_dir='/home/cyberbae/Documents/server/poller/ping'
log="$base_dir/log/sping.log"

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
    salida_ping=`ping -c 20 -i .2 -W 1 -q $IP`
    retval=$?

    if [ $retval -eq 0 ] # obtuvimos algunas respuestas
    then
        recvd=`echo $salida_ping | grep -o '[0-9]\+ received'`
        recvd=${recvd% received}
        lost=`expr 20 - $recvd`
        stats=(`echo $salida_ping | grep -o '[0-9.]\+/[0-9.]\+/[0-9.]\+' | tr '/' ' '`)
        min=${stats[0]}
        avg=${stats[1]}
        max=${stats[2]}
    elif [ $retval -eq 1 ] # no hubo respuesta
    then
        lost=20
        min='U'
        avg='U'
        max='U'
        swaks -t redes.bolillo@gmail.com -s smtp.gmail.com:587 -tls -a -au redes.bolillo@gmail.com -ap redes.bolillo@gmail.com --header "Subject: Posible falla en router $IP" --body "Hubo perdida de paquetes con el ping poller, revisar estado del router $IP"
    elif [ $retval -eq 2 ] # el host no se encontró 
    then
        escribe_log "host desconocido $IP"
        swaks -t redes.bolillo@gmail.com -s smtp.gmail.com:587 -tls -a -au redes.bolillo@gmail.com -ap redes.bolillo@gmail.com --header "Subject: Router $IP desconectado" --body "Revisar estado del router $IP ya que no responde"
        exit $retval
    else # otros
        escribe_log "error pinging $IP error : $retval"
        exit $retval
    fi

#  packet_loss=$(sudo ping -c 1 -q $IP | grep -oP '\d+(?=% packet loss)')
#  echo "$IP % de perdida: $packet_loss"
#
#  # SWAKS to admin mail 
#  if [ "$packet_loss" -ge 40 ]; then
#    swaks -t redes.bolillo@gmail.com -s smtp.gmail.com:587 -tls -a -au redes.bolillo@gmail.com -ap redes.bolillo@gmail.com
#    echo -e "\tEnviando email de ALERTA"
#  fi

    if [ ! -f $base_dir/rrd/$IP.rrd ] # crear rrd si no existe
    then
        rrdtool create $base_dir/rrd/$IP.rrd \
        --step 60 \
        DS:lost:GAUGE:120:0:20 \
        DS:min:GAUGE:120:0:1000 \
        DS:avg:GAUGE:120:0:1000 \
        DS:max:GAUGE:120:0:1000 \
        RRA:MAX:0.5:1:525600

        retval=$?

        if [ $retval -gt 0 ]
        then
            escribe_log "no se pudo crear el archivo rrd para la ip $IP, error: $retval"
            exit 200
        fi
    fi

    timestamp=`date +"%s"`
    rrdtool update $base_dir/rrd/$IP.rrd $timestamp:$lost:$min:$avg:$max

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



