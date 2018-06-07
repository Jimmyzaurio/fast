#!/bin/sh

#rrdtool fetch test.rrd AVERAGE -s -100d
echo "234: 1234" | awk '/:/ {
    cmd="echo rrdtool update test.rrd " $1 q; 
    print cmd; 
    s=.006*q;
    v=v+1;
    u=v/600; 
    t=v%8;
    r=rand();
    q=500;
    if(v<50) {
        q=3+s+v+.5*u+1.3*(t-4)*(t-4)+10*r
    };
    system(cmd);
}'

