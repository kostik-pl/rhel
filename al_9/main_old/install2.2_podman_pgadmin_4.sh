#!/bin/bash
clear

#Install PODMAN
dnf install -y podman 

#Start PGADMIN container
#Change the image name to the desired image. Example kostikpl/ol9:pgpro_1c_13 > kostikpl/rhel8:pgpro_std_13
echo 'Pull and setup container...'
podman run --name pgadmin -d -p 5050:80 -e 'PGADMIN_LISTEN_ADDRESS=0.0.0.0' -e 'PGADMIN_DEFAULT_EMAIL=k.druchevsky@kernel.ua' -e 'PGADMIN_DEFAULT_PASSWORD=a1502EMC2805' docker.io/dpage/pgadmin4
podman generate systemd --new --name pgadmin > /etc/systemd/system/pgadmin.service
systemctl enable --now pgadmin
firewall-cmd --permanent --zone=public --add-port=5050/tcp
firewall-cmd --reload