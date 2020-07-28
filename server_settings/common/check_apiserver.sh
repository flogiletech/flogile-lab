#!/bin/sh
VIRTUALIP=10.10.85.196
errorExit() {
    echo "*** $*" 1>&2
    exit 1
}

#nc -zv 192.168.1.31 6443 > /dev/null || errorExit "Error GET https://localhost:6444/"
curl --silent --max-time 2 --insecure https://localhost:6444/ -o /dev/null || errorExit "Error GET https://localhost:6444/"
if ip addr | grep -q $VIRTUALIP; then
    curl --silent --max-time 2 --insecure https://$VIRTUALIP:6443/ -o /dev/null || errorExit "Error GET https://$VIRTUALIP:6443/"
fi
