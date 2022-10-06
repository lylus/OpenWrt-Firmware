#!/bin/bash

# 本脚本需要复制到/etc/config目录下使用，或直接ssh登录openwrt后复制下面的代码,注意，复制时不要带上第一个字符#！！！！！

# cd /etc/config && wget -O autoupdate.sh https://github.com/lylus/OpenWrt-Firmware/raw/main/autoupdate.sh && chmod 700 /etc/config/autoupdate.sh && /etc/config/autoupdate.sh

# 在openwrt的luci界面的计划任务里面添加如下命令，可实时自动更新，例如下面的命令为 每两天的凌晨5点执行更新。

# 0 5 */2 * * /etc/config/autoupdate.sh

# 获取固件最新版本号
	cd /etc/config

	api_url="https://api.github.com/repos/lylus/OpenWrt-Firmware/releases/latest"

	new_ver=`curl ${PROXY} -s ${api_url} --connect-timeout 10| grep 'tag_name' | cut -d\" -f4`

	touch ./version.txt
	cat <<EOF > ./version.txt
${new_ver}
EOF

	sed -i 's/v//g' ./version.txt
	get_releases=$(cat ./version.txt)

	releases_url=https://github.com/lylus/OpenWrt-Firmware/releases/download/${new_ver}/immortalwrt-x86-64-generic-squashfs-combined-efi.img.gz
	sha256sums_url=https://github.com/lylus/OpenWrt-Firmware/releases/download/${new_ver}/sha256sums


#	rm -rf ./version.txt


# 检测版本和更新软件包安装sha256

#	opkg update
#	opkg install coreutils-sha256sum

        old_ver=$(cat ./oldver.txt)

        echo "检测到本机上次更新的版本: $old_ver"


        echo "检测到最新的版本: $get_releases"

if [ "$old_ver" = "$get_releases" ]

then

echo "没有检测到新的版本!"

else
# 更新固件


	cd /tmp

	wget -O sha256sums ${sha256sums_url}
	
	echo "正在下载固件，请耐心等待。"
	
	wget -O immortalwrt-x86-64-generic-squashfs-combined-efi.img.gz ${releases_url}


	chmod 755 immortalwrt-x86-64-generic-squashfs-combined-efi.img.gz

	sha256=$(sha256sum -c sha256sums 2> /dev/null | grep OK)
	
if [ "$sha256" = "immortalwrt-x86-64-generic-squashfs-combined-efi.img.gz: OK" ]

then
	cd /etc/config

	cp -f ./version.txt ./oldver.txt

	rm -rf ./version.txt

	echo "验证sha256sum正确，准备更新，更新完成自动重启!"

	sleep 5

	sysupgrade /tmp/immortalwrt-x86-64-generic-squashfs-combined-efi.img.gz

	echo "新版本，已更新完成!"

else

	echo "sha256sum未通过校验，3秒后开始重试。"
	sleep 3
/etc/config/autoupdate.sh

fi

fi

     echo "脚本运行结束！"
