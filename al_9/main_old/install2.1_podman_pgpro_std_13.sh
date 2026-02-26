#!/bin/bash
clear

#Install PODMAN
dnf install -y podman 

#Change Podman storage
#sed -i 's/graphroot = "\/var\/lib\/containers\/storage"/graphroot = "\/_containers"/g' /etc/containers/storage.conf
#systemctl restart podman

#Add POSTGRES GROUP and USER same as in container
echo 'Create postgres user and group...' 
groupadd -r postgres --gid=9999
useradd -r -M -g postgres --uid=9999 postgres

#Change access rights
echo 'Create folder and set permision...'
if [ ! -d "/_data/pg_backup" ] ; then
	mkdir /_data/pg_backup
fi
if [ ! -d "/_data/pg_data" ] ; then
	mkdir /_data/pg_data
fi
chown -R postgres:postgres /_data/pg_data
find /_data/pg_data -type d -exec chmod 700 {} +
find /_data/pg_data -type f -exec chmod 600 {} +

chown -R postgres:postgres /_data/pg_backup
find /_data/pg_backup -type d -exec chmod 777 {} +
find /_data/pg_backup -type f -exec chmod 666 {} +

#Start POSTGRESPRO container
#Change the image name to the desired image. Example kernelbranch/al_9:pgpro_std_13
echo 'Pull and setup container...'
podman run --userns=host --name pgpro --shm-size 2G -d -p 5432:5432 -v /_data:/_data docker.io/kernelbranch/pgpro_std:pgpro-13.18.1_al-9.5
podman generate systemd --new --name pgpro > /etc/systemd/system/pgpro.service
systemctl enable pgpro
systemctl start pgpro
firewall-cmd --permanent --zone=public --add-service=postgresql
firewall-cmd --reload
sleep 15s
PG_PASSWD='RheujvDhfub72'
podman exec -ti pgpro psql -c "ALTER USER postgres WITH PASSWORD '$PG_PASSWD';"
#srv1c_PASSWD = '\$GitybwZ - ZxvtyM\$' # $GitybwZ - ZxvtyM$
#podman exec -ti pgpro psql -c "ALTER USER srv1c WITH PASSWORD '$srv1c_PASSWD';"