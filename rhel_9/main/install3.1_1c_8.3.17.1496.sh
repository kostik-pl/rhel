#!/bin/bash

#Add 1c GROUP and USER
echo 'Create 1c user and group...' 
groupadd -r grp1cv8 --gid=991
useradd -r -m -g grp1cv8 --uid=991 usr1cv8

#Change access rights
echo 'Create folder and set permision...'
if [ ! -d "/_data/srv1c_inf_log" ] ; then
	mkdir /_data/srv1c_inf_log
fi
chown -R usr1cv8:grp1cv8 /_data/srv1c_inf_log
chmod -R 755 /_data/srv1c_inf_log

#Install CHKCONFIG for support old INIT.D service
dnf install -y chkconfig

#Install 1C Enterprise requirements from STANDART repositories
echo 'Dowload and install addons...'
dnf install -y postgresql-odbc
dnf install -y libgsf

#Install 1C Enterprise requirements from EPEL repositories
dnf install -y epel-release
dnf install -y ImageMagick

#Install 1C Enterprise server requirements from FONTS packages
dnf install -y almalinux-release-devel
dnf install -y cabextract
dnf install -y xorg-x11-font-utils
rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
#Previous version
#curl "https://drive.usercontent.google.com/download?id=1-6UeVusRsqn33AAmAozG_NH-CmHDwKMx&confirm=xxx" -o msttcorefonts-2.5-1.noarch.rpm
#rpm -ivh msttcorefonts-2.5-1.noarch.rpm
fc-cache -fv

#Install 1C Enterprise server packages from work dir
#Download form GOOGLE
curl "https://drive.usercontent.google.com/download?id=1kTZ8Wi9Vur9Xha-x_-PNbADn2iI9455l&confirm=xxx" -o rpm64_8_3_17_1496.tar.gz
mkdir rpm64_8_3_17_1496
tar -xf rpm64_8_3_17_1496.tar.gz -C rpm64_8_3_17_1496
dnf localinstall -y rpm64_8_3_17_1496/*.rpm

sed -ri 's/#SRV1CV8_DEBUG=/SRV1CV8_DEBUG=-debug/' /etc/sysconfig/srv1cv83
sed -ri 's/#SRV1CV8_DATA=/SRV1CV8_DATA=\/_data\/srv1c_inf_log/' /etc/sysconfig/srv1cv83
sed -ri 's/#SRV1CV8_KEYTAB=/SRV1CV8_KEYTAB=\/_data\/usr1cv8.keytab/' /etc/sysconfig/srv1cv83

systemctl daemon-reload
systemctl enable srv1cv83
systemctl start srv1cv83

#Open ports
curl "https://drive.usercontent.google.com/download?id=1RND475Sc9MquDt9W1At9rMQP_N6OOfSk&confirm=xxx" -o /etc/firewalld/services/srv1c.xml
firewall-cmd --reload
firewall-cmd --permanent --zone=public --add-service=srv1c
firewall-cmd --reload
