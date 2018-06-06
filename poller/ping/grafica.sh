#!/bin/bash

base_dir='/home/cyberbae/Documents/server/poller/ping'
graph_dir='/home/cyberbae/Documents/server/poller/ping'
log="$base_dir/log/sping.log"

function write_log()
{
    echo "`date '+%m/%d %H:%M:%S'` $1" >> $log
}

    write_log 'pings complete'
    write_log 'generating graphs'

    for file in $base_dir/rrd/*.rrd
    do
        host=${file#$base_dir/rrd/}
        host=${host%.rrd}

        rrdtool graph $graph_dir/$host.png \
        -w 785 -h 120 -a PNG \
        --slope-mode \
        --start -14400 --end now \
        --font DEFAULT:8: \
        --title "Ping RTT to $host" \
        --vertical-label "Latency (MS)" \
        --lower-limit 0 \
        --alt-y-grid --rigid \
        DEF:min=$file:min:MAX \
        DEF:avg=$file:avg:MAX \
        DEF:max=$file:max:MAX \
		COMMENT:"Updated `date '+%m/%d %H\:%M'`   " \
        LINE1:min#03bd10:"Min" \
        LINE1:avg#0223ca:"Avg" \
        LINE1:max#e11110:"Max"

        retval=$?

        if [ $retval -gt 0 ]
        then
            write_log "error generating graph for $host retval $retval"
        fi
    done

    write_log 'graph generation complete'

