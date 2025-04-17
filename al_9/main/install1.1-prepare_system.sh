#!/bin/bash

#Change REPO
find /etc/yum.repos.d/ -type f -name 'almalinux*' -exec sed -i 's/mirrorlist/#mirrorlist/g' {} \;
find /etc/yum.repos.d/ -type f -name 'almalinux*' -exec sed -i 's/# baseurl/baseurl/g' {} \;

#Disable selinux
sed -i 's/enforcing/disabled/g' /etc/selinux/config
sed -i "s/active = yes/active = no/" /etc/audit/plugins.d/sedispatch.conf

#Disable IP6 in GRUB or SYSTEM_CONFIG
grubby --update-kernel=ALL --args="ipv6.disable=1"
for conn in $(nmcli -t -f NAME connection show); do
	nmcli connection modify "$conn" ipv6.method "disabled"
	nmcli connection down "$conn"
	nmcli connection up "$conn"
done
firewall-cmd --permanent --zone=public --remove-service=dhcpv6-client

#Setup system
dnf upgrade -y

#To disable the GUI on boot
#systemctl set-default multi-user.target
#To enable the GUI on boot
#systemctl set-default graphical.target

#Install cockpit and related pcp (performance co-pilot)
dnf install -y pcp pcp-system-tools pcp-gui
systemctl enable --now pmcd pmlogger
dnf install -y cockpit
systemctl enable cockpit.socket

#Or install htop and iotop
#dnf install -y htop iotop

#Install mc
dnf install -y mc
dnf install -y cifs-utils

#Reboot
reboot
