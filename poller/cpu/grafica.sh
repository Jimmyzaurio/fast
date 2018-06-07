#!/bin/bash

raiz='/root/server/poller/cpu'
graph_dir='/root/server/poller/cpu'
log="$raiz/log/sping.log"

function write_log()
{
    echo "`date '+%m/%d %H:%M:%S'` $1" >> $log
}

    write_log 'generando grafica uso del CPU'

    for file in $raiz/rrd/*.rrd
    do
        host=${file#$raiz/rrd/}
        host=${host%.rrd}

        rrdtool graph $graph_dir/$host.png \
        -w 785 -h 120 -a PNG \
        --slope-mode \
        --start -14400 --end now \
        --font DEFAULT:8: \
        --title "Memoria disponible en el router $host" \
        --vertical-label "Latencia (MS)" \
        --lower-limit 0 \
        --alt-y-grid --rigid \
        DEF:cpu_usado=$file:cpu_usado:MAX \
		COMMENT:"Actualizado `date '+%m/%d %H\:%M'`   " \
        LINE1:cpu_usado#03bd10:"CPU"

        retval=$?

        if [ $retval -gt 0 ]
        then
            write_log "error generando graficada para $host error: $retval"
        fi
    done

    write_log 'grafica generada exitosamente'

