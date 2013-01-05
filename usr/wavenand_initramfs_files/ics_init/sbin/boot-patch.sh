#!/system/xbin/busybox sh


# start logging
# set busybox location
BB="/system/xbin/busybox"

# set fsync
	echo 0 > /data/local/devil/fsync
	echo 0 > /sys/devices/virtual/misc/fsynccontrol/fsync_enabled
# partitions

if $BB [ ! -d /data/local/devil ]; then 
	$BB echo "creating devil folder at /data/local"
	$BB mkdir -p /data/local/devil
	$BB chmod 777 /data/local/devil
fi



$BB echo 200 > /proc/sys/vm/swappiness
