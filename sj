#!/bin/sh

# File ID: 29dba898-4962-11df-adc3-d5e071bed206

if test "$1" = "space"; then
    while :; do
        df -h . | grep /dev/ | tr -s ' ' | cut -f 4 -d ' ' | tr -d '\n'
        sleep 1
        echo -n ' '
    done
else
    test -d /n900/. && sudo=sudo || unset sudo
    while :; do
        $sudo ping 178.79.142.16
        sleep 1
        echo ============================================
    done
fi
