#!/bin/sh

while [ "$(getprop sys.boot_completed | tr -d '\r')" != "1" ]; do sleep 1; done
sleep 10

# initial service variables and check first boot
sprofileold=10
tcprofileold=10
vsyncdisold=10

latch_unsignaled_old="$(getprop persist.xp.latch_unsignaled)"
if [ "$latch_unsignaled_old" == 0 ]; then
  # Off
  setprop vendor.debug.sf.latch_unsignaled 0
  setprop debug.sf.latch_unsignaled 0
elif [ "$latch_unsignaled_old" == 1 ]; then
  # On
  setprop vendor.debug.sf.latch_unsignaled 1
  setprop debug.sf.latch_unsignaled 1
else
  # First boot params
  setprop vendor.debug.sf.latch_unsignaled 0
  setprop debug.sf.latch_unsignaled 0
fi

codecs_old=10
hw_overlays_old=10

wifi80_old="$(getprop persist.xp.wifi80)"
if [[ "$wifi80_old" == 1 || "$wifi80_old" == 2 || "$wifi80_old" == 3 ]]; then
  case $wifi80_old in
  1)# Only 2G
  umount /vendor/firmware/wifi.cfg
  mount --bind /vendor/firmware/wifi_sta2.cfg /vendor/firmware/wifi.cfg
  ;;
  2)# Only 5G
  umount /vendor/firmware/wifi.cfg
  mount --bind /vendor/firmware/wifi_sta5.cfg /vendor/firmware/wifi.cfg
  ;;
  3)# 2G + 5G
  umount /vendor/firmware/wifi.cfg
  mount --bind /vendor/firmware/wifi_sta25.cfg /vendor/firmware/wifi.cfg
  ;;
  esac
else
  umount /vendor/firmware/wifi.cfg
fi

pq_old=10
usb_old=10
governor_old=10
thermal_old=10

viper_old="$(getprop persist.xp.viper)"
if [[ "$viper_old" != 0 && "$viper_old" != 1 ]]; then
  pm disable com.pittvandewitt.viperfx
fi

james_old="$(getprop persist.xp.james)"
if [[ "$james_old" != 0 && "$james_old" != 1 ]]; then
  pm disable james.dsp && am force-stop james.dsp
fi

dlb_old="$(getprop persist.xp.dlb)"
if [[ "$dlb_old" != 0 && "$dlb_old" != 1 ]]; then
  pm disable com.dolby && pm disable com.dolby.ds1appUI
fi

cam_old=10

gms_old=10

# loop, run every 3 seconds
while true
do

## Spectrum performance profiles
# EAS governors params
sprofile="$(getprop persist.spectrum.profile)"
if [ "$sprofileold" != "$sprofile" ]; then
  case $sprofile in
  0)# Battery
  /system/bin/echo -n 1000 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/up_rate_limit_us
  /system/bin/echo -n 1000 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/down_rate_limit_us
  ;;
  1)# Balance
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/up_rate_limit_us
  /system/bin/echo -n 3000 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/down_rate_limit_us
  ;;
  2)# Smooth
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/up_rate_limit_us
  /system/bin/echo -n 100000 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/down_rate_limit_us
  ;;
  3)# Game
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/up_rate_limit_us
  /system/bin/echo -n 200000 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/down_rate_limit_us
  ;;
  4)# Powerful
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/up_rate_limit_us
  /system/bin/echo -n 1000000 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/down_rate_limit_us
  ;;
  5)# Super Powerful
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/up_rate_limit_us
  /system/bin/echo -n 10000000 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/down_rate_limit_us
  ;;
  *)# First boot params (Battery)
  /system/bin/echo -n 1000 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/up_rate_limit_us
  /system/bin/echo -n 1000 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/down_rate_limit_us
  ;;
  esac
	sprofileold=$sprofile
fi

# Governor
governor="$(getprop persist.xp.governor)"
if [ "$governor_old" != "$governor" ]; then
  case $governor in
  0)# pwrutilx
  /system/bin/echo -n pwrutilx > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  /system/bin/echo -n pwrutilx > /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
  ;;
  1)# blu_schedutil
  /system/bin/echo -n blu_schedutil > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  /system/bin/echo -n blu_schedutil > /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
  ;;
  2)# pixutil
  /system/bin/echo -n pixutil > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  /system/bin/echo -n pixutil > /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
  ;;
  3)# schedutil
  /system/bin/echo -n schedutil > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  /system/bin/echo -n schedutil > /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
  ;;
  4)# helix_schedutil
  /system/bin/echo -n helix_schedutil > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  /system/bin/echo -n helix_schedutil > /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
  ;;
  5)# darkutil
  /system/bin/echo -n darkutil > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  /system/bin/echo -n darkutil > /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
  ;;
  6)# smurfutil
  /system/bin/echo -n smurfutil > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  /system/bin/echo -n smurfutil > /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
  ;;
  *)# First boot params (pwrutilx)
  /system/bin/echo -n pwrutilx > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  /system/bin/echo -n pwrutilx > /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
  ;;
  esac
  case $sprofileold in
  0)# Battery
  /system/bin/echo -n 1000 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/up_rate_limit_us
  /system/bin/echo -n 1000 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/down_rate_limit_us
  ;;
  1)# Balance
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/up_rate_limit_us
  /system/bin/echo -n 3000 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/down_rate_limit_us
  ;;
  2)# Smooth
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/up_rate_limit_us
  /system/bin/echo -n 100000 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/down_rate_limit_us
  ;;
  3)# Game
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/up_rate_limit_us
  /system/bin/echo -n 200000 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/down_rate_limit_us
  ;;
  4)# Powerful
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/up_rate_limit_us
  /system/bin/echo -n 1000000 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/down_rate_limit_us
  ;;
  5)# Super Powerful
  /system/bin/echo -n 500 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/up_rate_limit_us
  /system/bin/echo -n 10000000 > /sys/devices/system/cpu/cpufreq/$(ls /sys/devices/system/cpu/cpufreq/ | grep -v policy)/down_rate_limit_us
  ;;
  esac
	governor_old=$governor
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
  setprop ctl.restart zygote
  ;;
  1)# On
  setprop vendor.debug.sf.latch_unsignaled 1
  setprop debug.sf.latch_unsignaled 1
  setprop ctl.restart zygote
  ;;
  *)# Other (default)
  setprop vendor.debug.sf.latch_unsignaled 0
  setprop debug.sf.latch_unsignaled 0
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

## USB Charging
usb="$(getprop persist.xp.usb)"
if [ "$usb_old" != "$usb" ]; then
  case $usb in
  0)# Off
  /system/bin/echo -n 0 > /sys/kernel/fast_charge/force_fast_charge
  ;;
  1)# On
  /system/bin/echo -n 1 > /sys/kernel/fast_charge/force_fast_charge
  ;;
  *)# First boot params
  /system/bin/echo -n 0 > /sys/kernel/fast_charge/force_fast_charge
  ;;
  esac
	usb_old=$usb
fi

## Viper
viper="$(getprop persist.xp.viper)"
if [ "$viper_old" != "$viper" ]; then
  case $viper in
  0)# Off
  pm disable com.pittvandewitt.viperfx
  ;;
  1)# On
  pm enable com.pittvandewitt.viperfx
  ;;
  *)# Other (disable)
  pm disable com.pittvandewitt.viperfx
  ;;
  esac
	viper_old=$viper
fi

## James
james="$(getprop persist.xp.james)"
if [ "$james_old" != "$james" ]; then
  case $james in
  0)# Off
  stop audioserver
  pm disable james.dsp && am force-stop james.dsp
  sleep 2
  ;;
  1)# On
  settings put global hidden_api_policy 1
  pm enable james.dsp
  ;;
  *)# Other (disable)
  stop audioserver
  pm disable james.dsp && am force-stop james.dsp
  sleep 2
  ;;
  esac
	james_old=$james
fi

## Dlb
dlb="$(getprop persist.xp.dlb)"
if [ "$dlb_old" != "$dlb" ]; then
  case $dlb in
  0)# Off
  pm disable com.dolby && pm disable com.dolby.ds1appUI
  ;;
  1)# On
  pm enable com.dolby && pm enable com.dolby.ds1appUI
  ;;
  *)# Other (disable)
  pm disable com.dolby && pm disable com.dolby.ds1appUI
  ;;
  esac
	dlb_old=$dlb
fi

## MI Thermal disabler
thermal="$(getprop persist.xp.thermal)"
if [ "$thermal_old" != "$thermal" ]; then
  case $thermal in
  0)# Enabled
  start mi_thermald
  ;;
  1)# Disabled
  stop mi_thermald
  ;;
  *)# First boot params (Enabled)
  start mi_thermald
  ;;
  esac
	thermal_old=$thermal
fi

## GMS IOS disabler
gms="$(getprop persist.xp.gms)"
if [ "$gms_old" != "$gms" ]; then
  case $gms in
  0)# Off
  pm enable com.google.android.gms/.chimera.GmsIntentOperationService
  ;;
  1)# On
  pm disable com.google.android.gms/.chimera.GmsIntentOperationService
  ;;
  *)# First boot params (Enabled)
  pm enable com.google.android.gms/.chimera.GmsIntentOperationService
  ;;
  esac
	gms_old=$gms
fi

## Codecs priority
codecs="$(getprop persist.xp.hw_codecs)"
if [ "$codecs_old" != "$codecs" ]; then
  case $codecs in
  0)# MTK/C2
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

## Cams
cam="$(getprop persist.xp.cam)"
if [ "$cam_old" != "$cam" ]; then
  case $cam in
  0)# Only ANX
  pm enable com.android.camera
  pm disable org.codeaurora.snapcam
  pm disable com.google.android.GoogleCamera.Urnyx
  umount /vendor/lib64/libcam.hal3a.v3.lscMgr.so
  umount /vendor/lib64/libcam.halsensor.so
  umount /vendor/lib64/libmtkcam.logicalmodule.so
  umount /vendor/lib64/libmtkcam_metastore.so
  umount /vendor/lib64/libmtkcam_pipelinepolicy.so
  ;;
  1)# ANX + G-cam Burial 8
  pm enable com.android.camera
  pm enable org.codeaurora.snapcam
  pm disable com.google.android.GoogleCamera.Urnyx
  umount /vendor/lib64/libcam.hal3a.v3.lscMgr.so
  umount /vendor/lib64/libcam.halsensor.so
  umount /vendor/lib64/libmtkcam.logicalmodule.so
  umount /vendor/lib64/libmtkcam_metastore.so
  umount /vendor/lib64/libmtkcam_pipelinepolicy.so
  ;;
  2)# Only G-cam Burial 8
  pm disable com.android.camera
  pm enable org.codeaurora.snapcam
  pm disable com.google.android.GoogleCamera.Urnyx
  umount /vendor/lib64/libcam.hal3a.v3.lscMgr.so
  umount /vendor/lib64/libcam.halsensor.so
  umount /vendor/lib64/libmtkcam.logicalmodule.so
  umount /vendor/lib64/libmtkcam_metastore.so
  umount /vendor/lib64/libmtkcam_pipelinepolicy.so
  ;;
  3)# Only G-cam 64
  pm disable com.android.camera
  pm disable org.codeaurora.snapcam
  pm enable com.google.android.GoogleCamera.Urnyx
  stop camerahalserver
  mount --bind /vendor/lib64/2libcam.hal3a.v3.lscMgr.so /vendor/lib64/libcam.hal3a.v3.lscMgr.so
  mount --bind /vendor/lib64/2libcam.halsensor.so /vendor/lib64/libcam.halsensor.so
  mount --bind /vendor/lib64/2libmtkcam.logicalmodule.so /vendor/lib64/libmtkcam.logicalmodule.so
  mount --bind /vendor/lib64/2libmtkcam_metastore.so /vendor/lib64/libmtkcam_metastore.so
  mount --bind /vendor/lib64/2libmtkcam_pipelinepolicy.so /vendor/lib64/libmtkcam_pipelinepolicy.so
  start camerahalserver
  ;;
  *)# First boot params (ANX)
  pm disable org.codeaurora.snapcam
  pm disable com.google.android.GoogleCamera.Urnyx
  ;;
  esac
	cam_old=$cam
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
  *)# Other (default)
  umount /vendor/firmware/wifi.cfg
  ;;
  esac
	wifi80_old=$wifi80
fi

sleep 2

done
