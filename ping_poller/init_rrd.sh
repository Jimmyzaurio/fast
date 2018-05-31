cd /tools/rrdtool/latencia

rrdtool create latencia.rrd \
--step 60 \
DS:packet_loss:GAUGE:120:0:100 \
DS:tiempo:GAUGE:120:0:1000000000 \
RRD:MAX:0.5:1:1500 \
