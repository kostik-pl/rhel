#!/bin/bash
clear

#Install PODMAN
dnf install -y podman 

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
	mkdir /_data/pg_data2
fi
chown -R postgres:postgres /_data/pg_data2
find /_data/pg_data2 -type d -exec chmod 700 {} +
find /_data/pg_data2 -type f -exec chmod 600 {} +

chown -R postgres:postgres /_data/pg_backup
find /_data/pg_backup -type d -exec chmod 777 {} +
find /_data/pg_backup -type f -exec chmod 666 {} +

#Start POSTGRESQL container
echo 'Pull and setup container...'
podman run --userns=host --name pgsql --shm-size 2G -d -p 15432:5432 -v /_data:/_data docker.io/kernelbranch/pgsql_17:pgsql-17-wal2json
podman generate systemd --new --name pgsql > /etc/systemd/system/pgsql.service
systemctl enable pgsql
systemctl start pgsql
firewall-cmd --permanent --zone=public --add-port=15432/tcp
firewall-cmd --reload
sleep 15s
