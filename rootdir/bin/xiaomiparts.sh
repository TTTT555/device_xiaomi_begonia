#!/bin/sh
while [ "$(getprop sys.boot_completed | tr -d '\r')" != "1" ]; do sleep 1; done
sleep 10

# initial service variables with value more than available
sprofileold=10
tcprofileold=10

# loop, run every 3 seconds
while true
do

## Spectrum performance profiles
# Schedutil governor params
sprofile="$(getprop persist.spectrum.profile)"
if [ "$sprofileold" != "$sprofile" ]; then
  case $sprofile in
  0)# Battery1
  /system/bin/echo -n 1000 > /sys/devices/system/cpu/cpufreq/schedutil/up_rate_limit_us
  /system/bin/echo -n 1000 > /sys/devices/system/cpu/cpufreq/schedutil/down_rate_limit_us
  ;;
  1)# Battery2
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/schedutil/up_rate_limit_us
  /system/bin/echo -n 10000 > /sys/devices/system/cpu/cpufreq/schedutil/down_rate_limit_us
  ;;
  2)# Balance
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/schedutil/up_rate_limit_us
  /system/bin/echo -n 100000 > /sys/devices/system/cpu/cpufreq/schedutil/down_rate_limit_us
  ;;
  3)# Gaming
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/schedutil/up_rate_limit_us
  /system/bin/echo -n 200000 > /sys/devices/system/cpu/cpufreq/schedutil/down_rate_limit_us
  ;;
  4)# Performance
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/schedutil/up_rate_limit_us
  /system/bin/echo -n 300000 > /sys/devices/system/cpu/cpufreq/schedutil/down_rate_limit_us
  ;;
  5)# Crazy
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/schedutil/up_rate_limit_us
  /system/bin/echo -n 1000000 > /sys/devices/system/cpu/cpufreq/schedutil/down_rate_limit_us
  ;;
  *)# First boot params (Balance)
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/schedutil/up_rate_limit_us
  /system/bin/echo -n 100000 > /sys/devices/system/cpu/cpufreq/schedutil/down_rate_limit_us
  ;;
  esac
	sprofileold=$sprofile
fi

## TCP congestion Algorithm
tcprofile="$(getprop persist.tcp.profile)"
if [ "$tcprofileold" != "$tcprofile" ]; then
  case $tcprofile in
  0)# cubic
  /system/bin/echo -n cubic > /proc/sys/net/ipv4/tcp_congestion_control
  ;;
  1)# westwood
  /system/bin/echo -n westwood > /proc/sys/net/ipv4/tcp_congestion_control
  ;;
  2)# veno
  /system/bin/echo -n veno > /proc/sys/net/ipv4/tcp_congestion_control
  ;;
  3)# bic
  /system/bin/echo -n bic > /proc/sys/net/ipv4/tcp_congestion_control
  ;;
  4)# illinois
  /system/bin/echo -n illinois > /proc/sys/net/ipv4/tcp_congestion_control
  ;;
  5)# htcp
  /system/bin/echo -n htcp > /proc/sys/net/ipv4/tcp_congestion_control
  ;;
  *)# First boot params (westwood)
  /system/bin/echo -n westwood > /proc/sys/net/ipv4/tcp_congestion_control
  ;;
  esac
	tcprofileold=$tcprofile
fi

sleep 3

done
