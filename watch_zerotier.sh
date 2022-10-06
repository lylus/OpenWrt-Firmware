#!/bin/bash


echo "开始ping vpn网段"
netok=$(ping 192.168.0.1 -c3 |grep "time=")
if [ "$netok" ]; then

echo "vpn畅通，任务结束。"
exit 0

else

echo "vpn不通，开始ping 另一个 vpn网段。"

fi

netok1=$(ping 192.168.1.1 -c5 |grep "time=")
if [ "$netok1" ]; then

echo "vpn畅通，任务结束。"
exit 0


else

echo "vpn全不通，重启zerotier。"

/etc/init.d/zerotier restart

echo "任务运行完成。"

fi
