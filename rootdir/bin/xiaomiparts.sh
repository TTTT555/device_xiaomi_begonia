#!/bin/sh

# initial service variables with value more than available
sprofileold=10
tcprofileold=10
vsyncdisold=10
latch_unsignaled_old=10
codecs_old=10

# loop, run every 3 seconds
while true
do

## Spectrum performance profiles
# Schedutil governor params
sprofile="$(getprop persist.spectrum.profile)"
if [ "$sprofileold" != "$sprofile" ]; then
  case $sprofile in
  0)# Battery
  /system/bin/echo -n 1000 > /sys/devices/system/cpu/cpufreq/schedutil/up_rate_limit_us
  /system/bin/echo -n 1000 > /sys/devices/system/cpu/cpufreq/schedutil/down_rate_limit_us
  ;;
  1)# Balance
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/schedutil/up_rate_limit_us
  /system/bin/echo -n 3000 > /sys/devices/system/cpu/cpufreq/schedutil/down_rate_limit_us
  ;;
  2)# Smooth
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/schedutil/up_rate_limit_us
  /system/bin/echo -n 100000 > /sys/devices/system/cpu/cpufreq/schedutil/down_rate_limit_us
  ;;
  3)# Game
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/schedutil/up_rate_limit_us
  /system/bin/echo -n 200000 > /sys/devices/system/cpu/cpufreq/schedutil/down_rate_limit_us
  ;;
  4)# Powerful
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/schedutil/up_rate_limit_us
  /system/bin/echo -n 1000000 > /sys/devices/system/cpu/cpufreq/schedutil/down_rate_limit_us
  ;;
  5)# Super Powerful
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/schedutil/up_rate_limit_us
  /system/bin/echo -n 10000000 > /sys/devices/system/cpu/cpufreq/schedutil/down_rate_limit_us
  ;;
  *)# First boot params (Smooth)
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

## V-Sync Disabler
vsyncdis="$(getprop persist.xp.vsync.disabled)"
if [ "$vsyncdisold" != "$vsyncdis" ]; then
  case $vsyncdis in
  0)# Off
  setprop ro.surface_flinger.running_without_sync_framework 0
  ;;
  1)# On
  setprop ro.surface_flinger.running_without_sync_framework 1
  ;;
  *)# First boot params
  setprop ro.surface_flinger.running_without_sync_framework 0
  ;;
  esac
	vsyncdisold=$vsyncdis
fi

## debug.sf.latch_unsignaled
latch_unsignaled="$(getprop persist.xp.latch_unsignaled)"
if [ "$latch_unsignaled_old" != "$latch_unsignaled" ]; then
  case $latch_unsignaled in
  0)# Off
  setprop vendor.debug.sf.latch_unsignaled 0
  setprop debug.sf.latch_unsignaled 0
  ;;
  1)# On
  setprop vendor.debug.sf.latch_unsignaled 1
  setprop debug.sf.latch_unsignaled 1
  ;;
  *)# First boot params
  setprop vendor.debug.sf.latch_unsignaled 1
  setprop debug.sf.latch_unsignaled 1
  ;;
  esac
	latch_unsignaled_old=$latch_unsignaled
fi

## Codecs priority
codecs="$(getprop persist.xp.hw_codecs)"
if [ "$codecs_old" != "$codecs" ]; then
  case $codecs in
  0)# MTK HW
  setprop debug.stagefright.omx_default_rank 0
  killall mediaserver
  ;;
  1)# Google OMX
  setprop debug.stagefright.omx_default_rank 1000
  killall mediaserver
  ;;
  *)# First boot params
  setprop debug.stagefright.omx_default_rank 0
  ;;
  esac
	codecs_old=$codecs
fi

sleep 3

done
