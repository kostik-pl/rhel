#!/bin/bash

#Change REPO
find /etc/yum.repos.d/ -type f -name 'almalinux*' -exec sed -i 's/mirrorlist/#mirrorlist/g' {} \;
find /etc/yum.repos.d/ -type f -name 'almalinux*' -exec sed -i 's/# baseurl/baseurl/g' {} \;

#Disable selinux
sed -i 's/enforcing/disabled/g' /etc/selinux/config
sed -i "s/active = yes/active = no/" /etc/audisp/plugins.d/sedispatch.conf

#Disable IP6 in GRUB or SYSTEM_CONFIG
grubby --update-kernel=ALL --args="ipv6.disable=1"
nmcli connection modify ens192 ipv6.method "disabled"
firewall-cmd --permanent --zone=public --remove-service=dhcpv6-client

#Setup system
dnf upgrade -y

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
