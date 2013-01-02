#!/system/xbin/busybox sh


# start logging
# set busybox location
BB="/system/xbin/busybox"

# print file contents <string messagetext><file output>
    cat_msg_sysfile() {
    MSG=$1
    SYSFILE=$2
    echo -n "$MSG"
    $BB cat $SYSFILE
}


# partitions

if $BB [ ! -d /data/local/devil ]; then 
	$BB echo "creating devil folder at /data/local"
	$BB mkdir -p /data/local/devil
	$BB chmod 777 /data/local/devil
fi

#clean init.d from known files
if [ -e "/cache/clean_initd" ]; then
echo; echo "cleaning init.d from known files..."
	./sbin/clean_initd.sh
fi


$BB touch /data/local/devil/zram_size

#use normal swap or zram:
if [ -e "/data/local/devil/swap_use" ]; then
swap_use=`$BB cat /data/local/devil/swap_use`
	if [ "$swap_use" -eq 1 ]; then
	echo; echo "preparing for swap usage"
	# Detect the swap partition
	SWAP_PART=`$BB fdisk -l /dev/block/mmcblk1 | $BB grep swap | $BB sed 's/\(mmcblk1p[0-9]*\).*/\1/'`

		if [ -n "$SWAP_PART" ]; then
    			# If exists a swap partition activate it and create the fstab file
    			echo "Found swap partition at $SWAP_PART"
    			SWAP_RESULT=`swapon $SWAP_PART 2>&1 | $BB grep "not implemented"` 
    			if [ -z "$SWAP_RESULT" ]; then
        			echo "#!/system/bin/sh" > /system/etc/init.d/50swap
        			echo "swapon -a" >> /system/etc/init.d/50swap
        			echo "echo 60 > /proc/sys/vm/swappiness" >> /system/etc/init.d/50swap
        			$BB chmod 777 /system/etc/init.d/50swap
        			echo "$SWAP_PART swap swap" > /system/etc/fstab
        			echo "Swap partition activated successfully!"
    			else
        			echo "Current kernel does not support swap!"
    			fi
		else
    			echo "Swap partition not found!"
		fi

	elif [ "$swap_use" -eq 2 ]; then
	echo; echo "preparing for zram usage"
		if [ -e "/system/etc/fstab" ]; then
		rm /system/etc/fstab
		fi
	if [ -e "/data/local/devil/zram_size" ]; then
	RAMSIZE=`$BB cat /data/local/devil/zram_size`
	else RAMSIZE=75
	echo $RAMSIZE > /data/local/devil/zram_size
	fi

	if $BB [ "$RAMSIZE" -eq 50 ];then echo "Zram: found valid RAMSIZE: <$RAMSIZE mb>" 
	elif $BB [ "$RAMSIZE" -eq 75 ];then echo "Zram: found valid RAMSIZE: <$RAMSIZE mb>" 
	elif $BB [ "$RAMSIZE" -eq 100 ];then echo "Zram: found valid RAMSIZE: <$RAMSIZE mb>" 
	elif $BB [ "$RAMSIZE" -eq 150 ];then echo "Zram: found valid RAMSIZE: <$RAMSIZE mb>" 
	else RAMSIZE=75
	echo "Zram: set RAMSIZE to: <$RAMSIZE mb>" 
	fi
	ZRAMSIZE=$(($RAMSIZE*1024*1024))
	echo "#!/sbin/bb/busybox ash" > /etc/init.d/50swap
	echo "echo 1 > /sys/block/zram0/reset" >> /etc/init.d/50swap
	echo "echo $ZRAMSIZE > /sys/block/zram0/disksize" >> /etc/init.d/50swap
	echo "mkswap /dev/block/zram0" >> /etc/init.d/50swap
	echo "swapon /dev/block/zram0" >> /etc/init.d/50swap
	echo 'echo "500,1000,20000,20000,20000,25000" > /sys/module/lowmemorykiller/parameters/minfree'  >> /etc/init.d/50swap
       	$BB chmod 777 /system/etc/init.d/50swap
	echo 70 > /proc/sys/vm/swappiness
	echo "zram enabled and activated"
	else
	echo "zram and swap not activated"	
	echo 0 > /data/local/devil/swap_use
	fi
else
echo "zram and swap settings not found --> do not activate"	
echo 0 > /data/local/devil/swap_use
fi



# load profile
echo; echo "profile"
	if [ -e "/data/local/devil/profile" ];then
	profile=`$BB cat /data/local/devil/profile`
	echo "profile: found: <$profile>";
		if [ "$profile" -eq 1 ]; then
    			echo "profile: found valid governor profile: <smooth>";
      			echo 1 > /sys/class/misc/devil_tweaks/governors_profile;
		elif [ "$profile" -eq 2 ]; then
    			echo "profile: found valid governor profile: <powersave>";
      			echo 2 > /sys/class/misc/devil_tweaks/governors_profile;
		else
    			echo "profile: setting governor profile: <normal>";
      			echo 0 > /sys/class/misc/devil_tweaks/governors_profile;
    			echo 0 > /data/local/devil/profile;
		fi
	else
    		echo "profile not found: doing nothing";
      		echo 0 > /sys/class/misc/devil_tweaks/governors_profile;
    		echo 0 > /data/local/devil/profile;
	fi

#set cpu max and min freq while screen off
if [ -e "/data/local/devil/user_min_max_enable" ];then
   min_max_enable=`$BB cat /data/local/devil/user_min_max_enable`
   if [ "$min_max_enable" -eq 1 ]; then
	echo $min_max_enable > /sys/class/misc/devil_idle/user_min_max_enable
	#set cpu min freq while screen off
   	if [ -e "/data/local/devil/screen_off_max" ];then
		echo; echo "set cpu max freq while screen off"
		screen_off_max=`$BB cat /data/local/devil/screen_off_max`
		if $BB [ "$screen_off_max" -eq 1400000 ];then echo "CPU: found valid screen_off_max: <$screen_off_max>" 
			elif $BB [ "$screen_off_max" -eq 1300000 ];then echo "CPU: found valid screen_off_max: <$screen_off_max>"
			elif $BB [ "$screen_off_max" -eq 1200000 ];then echo "CPU: found valid screen_off_max: <$screen_off_max>" 
			elif $BB [ "$screen_off_max" -eq 1000000 ];then echo "CPU: found valid screen_off_max: <$screen_off_max>"
			elif $BB [ "$screen_off_max" -eq 800000 ];then echo "CPU: found valid screen_off_max: <$screen_off_max>" 
			elif $BB [ "$screen_off_max" -eq 400000 ];then echo "CPU: found valid screen_off_max: <$screen_off_max>"

   			else
			echo "CPU: did not find valid screen_off_max, setting 1000 Mhz as default"
			screen_off_max=1000000
		fi
		echo $screen_off_max > /sys/class/misc/devil_idle/user_max
    	else
		echo "screen_off_max: did not find any screen_off_max, setting 1000 Mhz as default"
		echo 1000000 > /sys/class/misc/devil_idle/user_max
		echo 1000000 > /data/local/devil/screen_off_max
   	fi

	#set cpu min freq while screen off
	if [ -e "/data/local/devil/screen_off_min" ];then
		echo; echo "set cpu min freq while screen off"
		screen_off_min=`$BB cat /data/local/devil/screen_off_min`
		if $BB [ "$screen_off_min" -eq 100000 ];then echo "CPU: found valid screen_off_min: <$screen_off_min>"  
			elif $BB [ "$screen_off_min" -eq 200000 ];then echo "CPU: found valid screen_off_min: <$screen_off_min>" 
			elif $BB [ "$screen_off_min" -eq 400000 ];then echo "CPU: found valid screen_off_min: <$screen_off_min>" 
			elif $BB [ "$screen_off_min" -eq 800000 ];then echo "CPU: found valid screen_off_min: <$screen_off_min>" 
		else
			echo "CPU: did not find valid screen_off_min, setting 100 Mhz as default"
			screen_off_min=100000
			echo $screen_off_min >/data/local/devil/screen_off_min
		fi
		echo $screen_off_min > /sys/class/misc/devil_idle/user_min
	else
		echo "screen_off_min: did not find any screen_off_min, setting 100 Mhz as default"
		echo 100000 > /sys/class/misc/devil_idle/user_min
		echo 100000 > /data/local/devil/screen_off_min
	fi

   else
	echo "screen_off_user_min_max not enabled...nothing to do"
	echo 0 > /sys/class/misc/devil_idle/user_min_max_enable
   fi
else
echo 0 > /data/local/devil/user_min_max_enable
fi


# set lock_sc_min
echo; echo "lock_sc_min"
if [ -e "/data/local/devil/lock_sc_min" ];then
	lock_sc_min=`$BB cat /data/local/devil/lock_sc_min`
	if [ "$lock_sc_min" -eq 0 ] || [ "$lock_sc_min" -eq 1 ];then
    		echo "lock_sc_min: found valid lock_sc_min mode: <$lock_sc_min>"
    		echo $lock_sc_min > /sys/devices/system/cpu/cpu0/cpufreq/lock_scaling_min
	else
		echo "lock_sc_min: did not find valid lock_sc_min mode: setting default"
		echo 1 > /data/local/devil/lock_sc_min
		echo 1 > /sys/devices/system/cpu/cpu0/cpufreq/lock_scaling_min
	fi
else
	echo "lock_sc_min: did not find valid lock_sc_min mode: setting default"
	echo 0 > /data/local/devil/lock_sc_min
	echo 0 > /sys/devices/system/cpu/cpu0/cpufreq/lock_scaling_min
fi


# set fsync
echo; echo "fsync"
if [ -e "/data/local/devil/fsync" ];then
	fsync=`$BB cat /data/local/devil/fsync`
	if [ "$fsync" -eq 0 ] || [ "$fsync" -eq 1 ];then
    		echo "fsync: found valid fsync mode: <$fsync>"
    		echo $fsync > /sys/devices/virtual/misc/fsynccontrol/fsync_enabled
	else
		echo "fsync: did not find valid fsync mode: setting default"
		echo 0 > /sys/devices/virtual/misc/fsynccontrol/fsync_enabled
	fi
else
	echo "fsync: did not find valid fsync mode: setting default"
	echo 0 > /data/local/devil/fsync
	echo 0 > /sys/devices/virtual/misc/fsynccontrol/fsync_enabled
fi

# set deep_idle
echo; echo "deep_idle"
if [ -e "/data/local/devil/deep_idle" ];then
	deep_idle=`$BB cat /data/local/devil/deep_idle`
	if [ "$deep_idle" -eq 0 ] || [ "$deep_idle" -eq 1 ];then
    		echo "deep_idle: found valid deep_idle mode: <$deep_idle>"
    		echo $deep_idle > /sys/devices/virtual/misc/deepidle/enabled
	else
		echo "deep_idle: did not find valid deep_idle mode: setting disabled"
		echo 0 > /sys/devices/virtual/misc/deepidle/enabled
	fi
else
	echo "deep_idle: did not find valid deep_idle mode: setting disabled"
	deep_idle=0
	echo 0 > /data/local/devil/deep_idle
	echo 0 > /sys/devices/virtual/misc/deepidle/enabled
fi

# set deep_idle_stats
echo; echo "deep_idle_stats"
if [ "$deep_idle" -eq 1 ]; then
   if [ -e "/data/local/devil/deep_idle_stats" ];then
	deep_idle_stats=`$BB cat /data/local/devil/deep_idle_stats`
	if [ "$deep_idle_stats" -eq 0 ] || [ "$deep_idle_stats" -eq 1 ];then
    		echo "deep_idle_stats: found valid deep_idle_stats mode: <$deep_idle_stats>"
    		echo $deep_idle_stats > /sys/devices/virtual/misc/deepidle/stats_enabled
	else
		echo "deep_idle_stats: did not find valid deep_idle_stats mode: setting disabled"
		echo 0 > /sys/devices/virtual/misc/deepidle/stats_enabled
	fi
    else
	echo "deep_idle_stats: did not find valid deep_idle_stats mode: setting disabled"
	echo 0 > /data/local/devil/deep_idle_stats
	echo 0 > /sys/devices/virtual/misc/deepidle/stats_enabled
   fi
fi

# set touchwake
echo; echo "touchwake"
if [ -e "/data/local/devil/touchwake" ];then
	touchwake=`$BB cat /data/local/devil/touchwake`
	if [ "$touchwake" -eq 0 ] || [ "$touchwake" -eq 1 ];then
    		echo "touchwake: found valid touchwake mode: <$touchwake>"
    		echo $touchwake > /sys/devices/virtual/misc/touchwake/enabled
	else
		echo "touchwake: did not find valid touchwake mode: setting disabled"
		echo 0 > /sys/devices/virtual/misc/touchwake/enabled
	fi
else
	echo "touchwake: did not find valid touchwake mode: setting disabled"
	touchwake=0
	echo 0 > /data/local/devil/touchwake
	echo 0 > /sys/devices/virtual/misc/touchwake/enabled
fi

# set touchwake timeout
echo; echo "touchwake_timeout"
if [ "$touchwake" -eq 1 ]; then
   if [ -e "/data/local/devil/touchwake_timeout" ];then
	touchwake_timeout=`$BB cat /data/local/devil/touchwake_timeout`
	if [ "$touchwake_timeout" -le 90000 ] && [ "$touchwake_timeout" -ge 0 ];then
    		echo "touchwake_timeout: found valid touchwake_timeout: <$touchwake_timeout>"
    		echo $touchwake_timeout > /sys/devices/virtual/misc/touchwake/delay
	else
		echo "touchwake_timeout: did not find valid touchwake_timeout: setting 30 sec."
		touchwake_timeout=30000
		echo $touchwake_timeout > /sys/devices/virtual/misc/touchwake/delay
	fi
    else
	echo "touchwake_timeout: did not find valid touchwake_timeout: setting 30 sec."
	touchwake_timeout=30000
	echo $touchwake_timeout > /sys/devices/virtual/misc/touchwake/delay
	echo $touchwake_timeout > /data/local/devil/touchwake_timeout
   fi
fi


# vm tweaks
# just output of default values for now
echo; echo "vm"
echo "2000" > /proc/sys/vm/dirty_writeback_centisecs # Flush after 20sec. (o:500)
echo "2000" > /proc/sys/vm/dirty_expire_centisecs    # Pages expire after 20sec. (o:200)
echo "10" > /proc/sys/vm/dirty_background_ratio      # flush pages later (default 5% active mem)
echo "65" > /proc/sys/vm/dirty_ratio                 # process writes pages later (default 20%)  
echo "3" > /proc/sys/vm/page-cluster
echo "0" > /proc/sys/vm/laptop_mode
echo "0" > /proc/sys/vm/oom_kill_allocating_task
echo "0" > /proc/sys/vm/panic_on_oom
echo "1" > /proc/sys/vm/overcommit_memory
cat_msg_sysfile "dirty_writeback_centisecs: " /proc/sys/vm/dirty_writeback_centisecs
cat_msg_sysfile "dirty_expire_centisecs: " /proc/sys/vm/dirty_expire_centisecs    
cat_msg_sysfile "dirty_background_ratio: " /proc/sys/vm/dirty_background_ratio
cat_msg_sysfile "dirty_ratio: " /proc/sys/vm/dirty_ratio 
cat_msg_sysfile "page-cluster: " /proc/sys/vm/page-cluster
cat_msg_sysfile "laptop_mode: " /proc/sys/vm/laptop_mode
cat_msg_sysfile "oom_kill_allocating_task: " /proc/sys/vm/oom_kill_allocating_task
cat_msg_sysfile "panic_on_oom: " /proc/sys/vm/panic_on_oom
cat_msg_sysfile "overcommit_memory: " /proc/sys/vm/overcommit_memory

# security enhancements
# rp_filter must be reset to 1 if TUN module is used (issues)
echo; echo "sec"
echo 0 > /proc/sys/net/ipv4/ip_forward
echo 0 > /proc/sys/net/ipv4/conf/all/rp_filter
echo 2 > /proc/sys/net/ipv6/conf/all/use_tempaddr
echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route
echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
echo -n "SEC: ip_forward :";$BB cat /proc/sys/net/ipv4/ip_forward
echo -n "SEC: rp_filter :";$BB cat /proc/sys/net/ipv4/conf/all/rp_filter
echo -n "SEC: use_tempaddr :";$BB cat /proc/sys/net/ipv6/conf/all/use_tempaddr
echo -n "SEC: accept_source_route :";$BB cat /proc/sys/net/ipv4/conf/all/accept_source_route
echo -n "SEC: send_redirects :";$BB cat /proc/sys/net/ipv4/conf/all/send_redirects
echo -n "SEC: icmp_echo_ignore_broadcasts :";$BB cat /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts 

# setprop tweaks
echo; echo "prop"
setprop wifi.supplicant_scan_interval 180
echo -n "wifi.supplicant_scan_interval (is this actually used?): "; getprop wifi.supplicant_scan_interval

# kernel tweaks
echo; echo "kernel"
echo "NO_GENTLE_FAIR_SLEEPERS" > /sys/kernel/debug/sched_features
echo 500 512000 64 2048 > /proc/sys/kernel/sem 
echo 3000000 > /proc/sys/kernel/sched_latency_ns
echo 500000 > /proc/sys/kernel/sched_wakeup_granularity_ns
echo 500000 > /proc/sys/kernel/sched_min_granularity_ns
echo 0 > /proc/sys/kernel/panic_on_oops
echo 0 > /proc/sys/kernel/panic
cat_msg_sysfile "sched_features: " /sys/kernel/debug/sched_features
cat_msg_sysfile "sem: " /proc/sys/kernel/sem; 
cat_msg_sysfile "sched_latency_ns: " /proc/sys/kernel/sched_latency_ns
cat_msg_sysfile "sched_wakeup_granularity_ns: " /proc/sys/kernel/sched_wakeup_granularity_ns
cat_msg_sysfile "sched_min_granularity_ns: " /proc/sys/kernel/sched_min_granularity_ns
cat_msg_sysfile "panic_on_oops: " /proc/sys/kernel/panic_on_oops
cat_msg_sysfile "panic: " /proc/sys/kernel/panic

echo; echo "$($BB date) io scheduler"
MTD=`$BB ls -d /sys/block/mtdblock*`
LOOP=`$BB ls -d /sys/block/loop*`
MMC=`$BB ls -d /sys/block/mmc*`

# set IO scheduler
if [ -e "/data/local/devil/iosched" ];then
	iosched=`$BB cat /data/local/devil/iosched`
	if $BB [ "$iosched" == "noop" ] || $BB [ "$iosched" == "deadline" ] || $BB [ "$iosched" == "cfq" ] || $BB [ "$iosched" == "sio" ] || $BB [ "$iosched" == "vr" ] || $BB [ "$iosched" == "bfq" ]  || $BB [ "$iosched" == "fiops" ]; then
    		echo "iosched: found valid io scheduler: <$iosched>";
	else
    		echo "iosched: did not find valid io scheduler: setting sio";
  		iosched=sio
	fi
else
    	echo "iosched: did not find valid io scheduler: setting sio";
      	iosched=sio
    	echo $iosched > /data/local/devil/iosched
fi



# general IO tweaks
for i in $MTD $MMC $LOOP;do
    echo "$iosched" > $i/queue/scheduler
    echo 0 > $i/queue/rotational
    echo 0 > $i/queue/iostats
done
      

# mtd/mmc only tweaks
for i in $MTD $MMC;do
    echo 1024 > $i/queue/nr_requests
done

echo;
for i in $MTD $MMC $LOOP $RAM;do
    cat_msg_sysfile "$i/queue/scheduler: " $i/queue/scheduler
    cat_msg_sysfile "$i/queue/rotational: " $i/queue/rotational
    cat_msg_sysfile "$i/queue/iostats: " $i/queue/iostats
    cat_msg_sysfile "$i/queue/read_ahead_kb: " $i/queue/read_ahead_kb
    cat_msg_sysfile "$i/queue/rq_affinity: " $i/queue/rq_affinity   
    cat_msg_sysfile "$i/queue/nr_requests: " $i/queue/nr_requests
    echo
done

# load bus_limit_settings
echo; echo "bus_limit"
	if [ -e "/data/local/devil/bus_limit" ];then
	bus_limit=`$BB cat /data/local/devil/bus_limit`
	echo "profile: found: <$bus_limit>";
		if [ "$bus_limit" -eq 1 ]; then
    			echo "bus_limit: found valid bus_limit profile: <automatic>";
      			echo 1 > /sys/class/misc/devil_idle/bus_limit;
		elif [ "$bus_limit" -eq 2 ]; then
    			echo "bus_limit: found valid bus_limit profile: <permanent>";
      			echo 2 > /sys/class/misc/devil_idle/bus_limit;
		else
    			echo "bus_limit: setting bus_limit profile: <disabled>";
      			echo 0 > /data/local/devil/bus_limit;
    			echo 0 > /sys/class/misc/devil_idle/bus_limit;
		fi
	else
    		echo "bus_limit not found: setting bus_limit profile: <disabled>";
      		echo 0 > /data/local/devil/bus_limit;
    		echo 0 > /sys/class/misc/devil_idle/bus_limit;
	fi


# set vibrator value
echo; echo "vibrator"
if [ -e "/data/local/devil/vibrator_cm" ];then
	vibrator=`$BB cat /data/local/devil/vibrator_cm`
	if [ "$vibrator" -le 100 ] && [ "$vibrator" -ge 0 ];then
    		echo "vibrator: found valid vibrator intensity: <$vibrator>"
    		echo $vibrator > /sys/class/misc/pwm_duty/pwm_duty
	else
		echo "vibrator: did not find valid vibrator intensity: setting default"
		echo 80 > /sys/class/misc/pwm_duty/pwm_duty
	fi
else
	echo "vibrator: did not find valid vibrator intensity: setting default"
	echo 80 > /data/local/devil/vibrator_cm
	echo 80 > /sys/class/misc/pwm_duty/pwm_duty
fi

# set wifi
echo; echo "wifi"
if [ -e "/data/local/devil/wifi" ];then
	wifi=`$BB cat /data/local/devil/wifi`
	if [ "$wifi" -eq 0 ] || [ "$wifi" -eq 1 ];then
    		echo "wifi: found valid wifi mode: <$wifi>"
    		echo $wifi > /sys/module/bcmdhd/parameters/uiFastWifi
	else
		echo "wifi: did not find valid wifi mode: setting default"
		echo 0 > /sys/module/bcmdhd/parameters/uiFastWifi
	fi
else
	echo "wifi: did not find valid wifi mode: setting default"
	echo 0 > /data/local/devil/wifi
	echo 0 > /sys/module/bcmdhd/parameters/uiFastWifi
fi

# smooth_ui
echo; echo "smooth_ui"
if [ -e "/data/local/devil/smooth_ui" ];then
    smooth_ui=`$BB cat /data/local/devil/smooth_ui`
	if [ "$smooth_ui" -eq 0 ] || [ "$smooth_ui" -eq 1 ];then
    		echo $smooth_ui > /sys/class/misc/devil_tweaks/smooth_ui_enabled
    		echo "smooth_ui: $smooth_ui"
	else
    		echo "did not find valid smooth_ui value: setting default (enabled)"
    		echo 1 > /sys/class/misc/devil_tweaks/smooth_ui_enabled
	fi
else
    	echo "did not find any smooth_ui value: setting default (enabled)"
    	echo 1 > /sys/class/misc/devil_tweaks/smooth_ui_enabled
	echo 1 > /data/local/devil/smooth_ui
fi


# governor
echo; echo "governor"
if [ -e "/data/local/devil/governor" ];then
    governor=`$BB cat /data/local/devil/governor`
	if $BB grep -q $governor /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors ;then
    		echo $governor > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    		echo "governor set to: $governor"
	else
    		echo "did not find valid governor: doing nothing"
    		governor=`$BB cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`
    		echo "your current governor is: $governor"	
	fi
else
    	echo "did not find governor config file: doing nothing"
    	governor=`$BB cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`
    	echo "your current governor is: $governor"
fi


# init.d support 
# executes <0-9><0-9>scriptname, <E>scriptname, <S>scriptname 
# in this order.
echo; echo "init.d"
    echo "starting init.d script execution..."

    echo $($BB date) USER INIT START from /system/etc/init.d
    	if cd /system/etc/init.d >/dev/null 2>&1 ; then
           for file in [0-9][0-9]* ; do
		if [ "$file" != "00initd_verify" ]; then
            		if ! ls "$file" >/dev/null 2>&1 ; then continue ; fi
           	 	echo "init.d: START '$file'"
            		/system/bin/sh "$file"
            		echo "init.d: EXIT '$file' ($?)"
		else
			echo "do not execute 00initd_verify"
		fi
           done
    	fi
    echo $($BB date) USER INIT DONE from /system/etc/init.d

    echo $($BB date) USER EARLY INIT START from /system/etc/init.d
    	if cd /system/etc/init.d >/dev/null 2>&1 ; then
            for file in E* ; do
            	if ! $BB cat "$file" >/dev/null 2>&1 ; then continue ; fi
            	echo "init.d: START '$file'"
            	/system/bin/sh "$file"
            	echo "init.d: EXIT '$file' ($?)"
            done
    	fi
    echo $($BB date) USER EARLY INIT DONE from /system/etc/init.d

    echo $($BB date) USER INIT START from /system/etc/init.d
    if cd /system/etc/init.d >/dev/null 2>&1 ; then
        for file in S* ; do
            if ! ls "$file" >/dev/null 2>&1 ; then continue ; fi
            echo "init.d: START '$file'"
            /system/bin/sh "$file"
            echo "init.d: EXIT '$file' ($?)"
        done
    fi
    echo $($BB date) USER INIT DONE from /system/etc/init.d

# set live_oc_value
echo; echo "live_oc_value"
if [ -e "/data/local/devil/live_oc_value" ];then
	live_oc_value=`$BB cat /data/local/devil/live_oc_value`
	if [ "$live_oc_value" -le 150 ] && [ "$live_oc_value" -ge 90 ];then
    		echo "live_oc_value: found valid live_oc_value mode: <$live_oc_value>"
    		echo $live_oc_value > /sys/devices/virtual/misc/liveoc/oc_value
		oc_enabled=1
	else
		echo "live_oc_value: did not find valid live_oc_value mode: setting default"
		echo "live_oc_value has to be betwenn 90 and 150"
		echo 100 > /sys/devices/virtual/misc/liveoc/oc_value
		oc_enabled=0
	fi
else
	echo "live_oc_value: did not find valid live_oc_value mode: doing nothing"
 	oc_enabled=0
fi

# set live_oc_target
echo; echo "live_oc_target"
if [ $oc_enabled -eq 1 ];then
if [ -e "/data/local/devil/live_oc_target_low" ];then
	live_oc_target_low=`$BB cat /data/local/devil/live_oc_target_low`
	if [ "$live_oc_target_low" -le 1400000 ] || [ "$live_oc_target_low" -ge 100000 ];then
    		echo "live_oc_target: found valid live_oc_target_low: <$live_oc_target_low>"
    		echo $live_oc_target_low > /sys/devices/virtual/misc/liveoc/oc_target_low
	else
		echo "live_oc_target: did not find valid live_oc_target_low: setting default"
		echo 800000 > /sys/devices/virtual/misc/liveoc/oc_target_low
	fi
else
	echo "live_oc_target_low: did not find valid live_oc_target mode: setting default"
	echo 800000 > /data/local/devil/live_oc_target_low
	echo 800000 > /sys/devices/virtual/misc/liveoc/oc_target_low
fi

if [ -e "/data/local/devil/live_oc_target_high" ];then
	live_oc_target_high=`$BB cat /data/local/devil/live_oc_target_high`
	if [ "$live_oc_target_high" -le 1400000 ] || [ "$live_oc_target_high" -ge 100000 ];then
    		echo "live_oc_target: found valid live_oc_target_high: <$live_oc_target_high>"
    		echo $live_oc_target_high > /sys/devices/virtual/misc/liveoc/oc_target_high
	else
		echo "live_oc_target: did not find valid live_oc_target_high: setting default"
		echo 1400000 > /sys/devices/virtual/misc/liveoc/oc_target_high
	fi
else
	echo "live_oc_target_high: did not find valid live_oc_target mode: setting default"
	echo 1400000 > /data/local/devil/live_oc_target_high
	echo 1400000 > /sys/devices/virtual/misc/liveoc/oc_target_high
fi
fi


# governor specific settings:
echo; echo "governor settings"
    governor=`$BB cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`
	if [ "$governor" = "conservative" ] || [ "$governor" = "ondemand" ];then
		if [ -e "/data/local/devil/$governor" ];then
		$responsiveness=`$BB cat /data/local/devil/$governor/responsiveness`
		$min_upthreshold=`$BB cat /data/local/devil/$governor/min_upthreshold`
		$sleep_multiplier=`$BB cat /data/local/devil/$governor/sleep_multiplier`
		echo $responsiveness > /sys/devices/system/cpu/cpufreq/$governor/responsiveness_freq
		echo $min_upthreshold > /sys/devices/system/cpu/cpufreq/$governor/up_threshold_min_freq
		echo $sleep_multiplier > /sys/devices/system/cpu/cpufreq/$governor/sleep_multiplier
		else
		echo "/data/local/devil/$governor not found, skipping..."
		fi
	else
		echo "nothing to do"
	fi



