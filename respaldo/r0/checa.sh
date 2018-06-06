#!/bin/bash 

uno="startup-config"
dos="aux"

if ! cmp "$uno" "$dos"
then
# MANDAR CORREO DE AVISO AL ADMIN
#
    swaks -t jspsaucedo@gmail.com -tls -s smtp.gmail.com:587 -a -au redes.bolillo@gmail.com -ap redes.bolillo --header "Subject: Configuracion router ${ROUTER_IP[$1]}" --body "Verificar la configuracion del router ${ROUTER_IP[$1]}"

fi
