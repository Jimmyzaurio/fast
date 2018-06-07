#!/bin/sh
rrdtool create test2.rrd -b now-100d -s 86400 \
    DS:msgs:GAUGE:86400:U:U \
    RRA:AVERAGE:0.5:1:100 \

rrdtool fetch test.rrd AVERAGE -s -100d | awk '/:/ {sub(",",".",$2);cmd="rrdtool update test2.rrd " $1 $2; print cmd; system(cmd);}'

rrdtool graph test2.png \
    --start now-100d --end=now \
    DEF:test2=test2.rrd:msgs:AVERAGE \
    LINE2:test2#FF0000:test2 

