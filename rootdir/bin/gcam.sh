#!/bin/sh
while [ "$(getprop sys.boot_completed | tr -d '\r')" != "1" ]; do sleep 1; done
sleep 10

# Gcam copy config

if A=$(find /sdcard/Gcam/configs7/Burial -type f -name '*.xml' | wc -l); [ "$A" = "0" ]
then
mkdir -p /sdcard/Gcam
cp -r /vendor/etc/Gcam/. /sdcard/Gcam/
fi
