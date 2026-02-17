#!/bin/bash

AUTO=$1
INUSE=$2
SSID=$3

/usr/bin/eww update wificonfigrev=false
/usr/bin/eww update wificonfigrev=true

if [ "$AUTO" == "false" ]; then
    /usr/bin/eww update wificlass="1"
elif [ "$INUSE" == "false" ]; then
    /usr/bin/eww update wificlass="2"
else
    /usr/bin/eww update wificlass="3"
fi

/usr/bin/eww update wifissidrev="$SSID"
