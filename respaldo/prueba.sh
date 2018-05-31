#!/bin/bash

USER="rcp"
PASSWD="rcp"

DIR="~/respaldo/r"
FILE="startup-config"

algo() {
ftp -n -v $1 <<KK
bye
KK
}

algo 0.0.0.0
