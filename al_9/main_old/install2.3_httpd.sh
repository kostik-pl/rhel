#!/bin/bash

#Install httpd (Appache)
dnf -y install httpd
systemctl enable --now httpd

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --reload
