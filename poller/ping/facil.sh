#!/bin/bash

base_dir='/home/cyberbae/Documents/server/poller/ping'
graph_dir='/home/cyberbae/Documents/server/poller/ping'
log="$base_dir/log/sping.log"

function write_log()
{
    echo "`date '+%m/%d %H:%M:%S'` $1" >> $log
}

    output=`ping -c 20 -i .2 -W 1 -q $1`
    retval=$?

    if [ $retval -eq 0 ] # at least some pings were returned
    then
        recvd=`echo $output | grep -o '[0-9]\+ received'`
        recvd=${recvd% received}
        lost=`expr 20 - $recvd`
        stats=(`echo $output | grep -o '[0-9.]\+/[0-9.]\+/[0-9.]\+' | tr '/' ' '`)
        min=${stats[0]}
        avg=${stats[1]}
        max=${stats[2]}
    elif [ $retval -eq 1 ] # no pings were returned
    then
        lost=20
        min='U'
        avg='U'
        max='U'
    elif [ $retval -eq 2 ] # host not found
    then
        write_log "unknown host $1"
        exit $retval
    else # other errors
        write_log "error pinging $1 retval $retval"
        exit $retval
    fi

    if [ ! -f $base_dir/rrd/$1.rrd ] # create rrd if it doesn't exist
    then
        rrdtool create $base_dir/rrd/$1.rrd \
        --step 60 \
        DS:lost:GAUGE:120:0:20 \
        DS:min:GAUGE:120:0:1000 \
        DS:avg:GAUGE:120:0:1000 \
        DS:max:GAUGE:120:0:1000 \
        RRA:MAX:0.5:1:525600

        retval=$?

        if [ $retval -gt 0 ]
        then
            write_log "unable to create rrd for $1 retval $retval"
            exit 200
        fi
    fi

    timestamp=`date +"%s"`
    rrdtool update $base_dir/rrd/$1.rrd $timestamp:$lost:$min:$avg:$max

    retval=$?

    if [ $retval -gt 0 ]
    then
        write_log "rrd update for $1 failed retval $retval"
        exit 201
    fi

