#!/bin/sh
rrdtool create test.rrd \
    -b now-100d -s 86400 \
	DS:msgs:GAUGE:86400:U:U \
    RRA:AVERAGE:0.5:1:100

# -b  -> Begin, indica el inicio de la lectura de archivos. -100d resta 100 días
# -s  -> Step, indice cada cuantos segundos se realizará una lectura. Por default son 5 minutos(300 sec)
# DS  -> Data source
# RRA -> Round Robin Archive, aquí indicamos la forma en que los datos serán procesados, aśi como el máximo y mínimo valor de nuestros datos.

#en la definicion del archivo se dice cuantos se promedian:1 y cuantos valores puede almacenar la base de datos: 10        
         
#rrdtool fetch test.rrd AVERAGE -s -10d | awk '/:/ {cmd="rrdtool update test.rrd " $1 "6"; print cmd; system(cmd);}'

#llenar="awk '/:/ {cmd="rrdtool update test.rrd " $1 q; print cmd; s=.006*q;v=v+1; u=v/600; t=v%8; r=rand();q=500;if(v<500) {q=3+s+v+.5*u+1.3*(t-4)*(t-4)+10*r}; system(cmd);}'"

#rrdtool fetch test.rrd AVERAGE -s -100d | awk '/:/ {
#    cmd="rrdtool update test.rrd " $1 q; 
#    print cmd; 
#    s=.006*q;
#    v=v+1;
#    u=v/600; 
#    t=v%8;
#    r=rand();
#    q=500;
#    if(v<500) {
#        q=3+s+v+.5*u+1.3*(t-4)*(t-4)+10*r
#    };
#    system(cmd);
#}'

rrdtool fetch test.rrd AVERAGE -s -100d | awk '/:/ {cmd="rrdtool update test.rrd " $1 q; print cmd; s=.006*q;v=v+1; u=v/600; t=v%8; r=rand();q=500;if(v<500) {q=3+s+v+.5*u+1.3*(t-4)*(t-4)+10*r}; system(cmd);}'

#rrdtool fetch test.rrd AVERAGE -s -100d 

rrdtool graph test.png \
    --start now-100d \
    --end=now+50days \
    DEF:test=test.rrd:msgs:AVERAGE:start=now-100d \
    LINE2:test#FF0000:test \
    CDEF:otro=test \
    VDEF:D1=otro,LSLSLOPE \
    VDEF:H1=otro,LSLINT \
    CDEF:avg1=otro,POP,D1,COUNT,*,H1,+ \
    CDEF:tope=avg1,150,200,LIMIT \
    VDEF:mintope=tope,FIRST \
    LINE1:avg1#FFBB00:"Prediccion desde hace 100 dias" \
    GPRINT:mintope:"Alcanza el 150 %c":strftime

xdg-open test.png

