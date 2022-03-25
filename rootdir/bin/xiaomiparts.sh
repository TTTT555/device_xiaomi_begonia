#!/bin/sh

# initial service variables with value more than available
sprofileold=10
tcprofileold=10
vsyncdisold=10
latch_unsignaled_old=10
codecs_old=10
hw_overlays_old=10
force64_old=10
wifi80_old=10

pq_old=10

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
  1)# bbr
  /system/bin/echo -n bbr > /proc/sys/net/ipv4/tcp_congestion_control
  ;;
  2)# westwood
  /system/bin/echo -n westwood > /proc/sys/net/ipv4/tcp_congestion_control
  ;;
  3)# veno
  /system/bin/echo -n veno > /proc/sys/net/ipv4/tcp_congestion_control
  ;;
  4)# bic
  /system/bin/echo -n bic > /proc/sys/net/ipv4/tcp_congestion_control
  ;;
  5)# illinois
  /system/bin/echo -n illinois > /proc/sys/net/ipv4/tcp_congestion_control
  ;;
  6)# htcp
  /system/bin/echo -n htcp > /proc/sys/net/ipv4/tcp_congestion_control
  ;;
  *)# First boot params (cubic)
  /system/bin/echo -n cubic > /proc/sys/net/ipv4/tcp_congestion_control
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

## PQ
pq="$(getprop persist.xp.pq)"
if [ "$pq_old" != "$pq" ]; then
  case $pq in
  0)# Off
  setprop ro.vendor.mtk_pq_support 0
  ;;
  1)# On
  setprop ro.vendor.mtk_pq_support 1
  ;;
  *)# First boot params
  setprop ro.vendor.mtk_pq_support 0
  ;;
  esac
	pq_old=$pq
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

## HW overlays
hw_overlays="$(getprop persist.xp.hw_overlays)"
if [ "$hw_overlays_old" != "$hw_overlays" ]; then
  case $hw_overlays in
  0)# On
  /system/bin/service call SurfaceFlinger 1008 i32 0
  ;;
  1)# Off
  /system/bin/service call SurfaceFlinger 1008 i32 1
  ;;
  *)# First boot params
  /system/bin/service call SurfaceFlinger 1008 i32 0
  ;;
  esac
	hw_overlays_old=$hw_overlays
fi

## Force 64 Mp
force64="$(getprop persist.xp.force64)"
if [ "$force64_old" != "$force64" ]; then
  case $force64 in
  0)# Off
  stop camerahalserver
  umount /vendor/lib64/libcam.hal3a.v3.lscMgr.so
  umount /vendor/lib64/libcam.halsensor.so
  umount /vendor/lib64/libmtkcam.logicalmodule.so
  umount /vendor/lib64/libmtkcam_metastore.so
  umount /vendor/lib64/libmtkcam_pipelinepolicy.so
  start camerahalserver
  ;;
  1)# On
  stop camerahalserver
  mount --bind /vendor/lib64/2libcam.hal3a.v3.lscMgr.so /vendor/lib64/libcam.hal3a.v3.lscMgr.so
  mount --bind /vendor/lib64/2libcam.halsensor.so /vendor/lib64/libcam.halsensor.so
  mount --bind /vendor/lib64/2libmtkcam.logicalmodule.so /vendor/lib64/libmtkcam.logicalmodule.so
  mount --bind /vendor/lib64/2libmtkcam_metastore.so /vendor/lib64/libmtkcam_metastore.so
  mount --bind /vendor/lib64/2libmtkcam_pipelinepolicy.so /vendor/lib64/libmtkcam_pipelinepolicy.so
  start camerahalserver
  ;;
  *)# First boot params
  stop camerahalserver
  umount /vendor/lib64/libcam.hal3a.v3.lscMgr.so
  umount /vendor/lib64/libcam.halsensor.so
  umount /vendor/lib64/libmtkcam.logicalmodule.so
  umount /vendor/lib64/libmtkcam_metastore.so
  umount /vendor/lib64/libmtkcam_pipelinepolicy.so
  start camerahalserver
  ;;
  esac
	force64_old=$force64
fi

## Force WiFi 80 Mhz
wifi80="$(getprop persist.xp.wifi80)"
if [ "$wifi80_old" != "$wifi80" ]; then
  case $wifi80 in
  0)# Default
  svc wifi disable
  umount /vendor/firmware/wifi.cfg
  svc wifi enable
  ;;
  1)# Only 2G
  svc wifi disable
  umount /vendor/firmware/wifi.cfg
  mount --bind /vendor/firmware/wifi_sta2.cfg /vendor/firmware/wifi.cfg
  svc wifi enable
  ;;
  2)# Only 5G
  svc wifi disable
  umount /vendor/firmware/wifi.cfg
  mount --bind /vendor/firmware/wifi_sta5.cfg /vendor/firmware/wifi.cfg
  svc wifi enable
  ;;
  3)# 2G + 5G
  svc wifi disable
  umount /vendor/firmware/wifi.cfg
  mount --bind /vendor/firmware/wifi_sta25.cfg /vendor/firmware/wifi.cfg
  svc wifi enable
  ;;
  *)# First boot params
  svc wifi disable
  umount /vendor/firmware/wifi.cfg
  svc wifi enable
  ;;
  esac
	wifi80_old=$wifi80
fi

sleep 2

done
