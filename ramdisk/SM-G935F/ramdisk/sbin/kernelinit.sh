#!/system/bin/sh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

BB=/system/xbin/busybox;

# mount root as rw to apply tweaks and settings
if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /;
fi;
if [ "$($BB mount | grep system | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /system;
fi;

# cpu - big
for i in `seq 4 7`;
do
	chmod "644" /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq
	echo "312000" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq
	chmod "444" /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq
	chmod "644" /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
	echo "2600000" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
	chmod "444" /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
	echo "ondemand" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
done

# cpu - little
for i in `seq 0 3`;
do
	chmod "644" /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq
	echo "338000" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq
	chmod "444" /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq
	chmod "644" /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
	echo "1586000" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
	chmod "444" /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq
	echo "ondemand" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
done

# gpu
echo "260" > /sys/devices/14ac0000.mali/min_clock
echo "650" > /sys/devices/14ac0000.mali/max_clock
echo "1" > /sys/devices/14ac0000.mali/dvfs_governor

# minfree
echo "1536,2048,2560,8192,16384,20480" > /sys/module/lowmemorykiller/parameters/minfree

# ksm
echo "1" > /sys/kernel/mm/ksm/run
echo "0" > /sys/kernel/mm/ksm/deferred_timer
echo "35" > /sys/kernel/mm/ksm/sleep_millisecs

# zram
swapoff "/dev/block/zram0/" > dev/null 2>&1
echo "1" /sys/block/zram0/reset
echo "268435456" > sys/block/zram0/disksize
mkswap "/dev/block/zram0/" > dev/null 2>&1
swapon "/dev/block/zram0/" > dev/null 2>&1
echo "lz4" > /sys/block/zram0/comp_algorithm
echo "4" > /sys/block/zram0/max_comp_streams

# vm
echo "0" > /proc/sys/vm/page-cluster

# storage - internal
echo "0" > /sys/block/mmcblk0/queue/iostats
echo "N" > /sys/module/sync/parameters/fsync_enabled
echo "zen" > /sys/block/mmblk0/queue/scheduler
echo "1024" > /sys/block/mmcblk0/queue/read_ahead_kb
echo "0" > /sys/block/mmcblk0/queue/rq_affinity

# storage - external
echo "0" > /sys/block/mmcblk0/queue/iostats
echo "N" > /sys/module/sync/parameters/fsync_enabled
echo "zen" > /sys/block/mmblk0/queue/scheduler
echo "2048" > /sys/block/mmcblk1/queue/read_ahead_kb
echo "0" > /sys/block/mmcblk0/queue/rq_affinity

# entropy
echo "1024" > /proc/sys/kernel/random/read_wakeup_threshold
echo "2048" > /proc/sys/kernel/random/write_wakeup_threshold

# network
sysctl -w net.ipv4.tcp_congestion_control=westwood

if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /;
fi;
if [ "$($BB mount | grep system | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /system;
fi;
