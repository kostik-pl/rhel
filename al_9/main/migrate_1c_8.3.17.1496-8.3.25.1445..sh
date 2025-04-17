#!/bin/bash

read -p 'Start install 1c ? [Y/n]: ' -n 1 -r
echo
if [[ "$REPLY" =~ ^[yY]$ ]]
then
	#Install 1C Enterprise server packages from work dir
	#Download form GOOGLE
	curl "https://drive.usercontent.google.com/download?id=1n_PTnHOY5_M__JxMzkfWrt3Z69UuZVae&confirm=xxx" -o setup-full-8.3.25.1445-x86_64.run
	chmod +x setup-full-8.3.25.1445-x86_64.run
	#ATTENTION! Batch installation will always install the 1c client and, if missing, the trimmed GNOME
	./setup-full-8.3.25.1445-x86_64.run --mode unattended --unattendedmodeui minimal --disable-components client_full,client_thin,client_thin_fib,config_storage_server,liberica_jre,integrity_monitoring --enable-components server,server_admin,ws,additional_admin_functions,v8_install_deps,uk,ru
	#Manual installation, if have GUI (GNOME), the process will run in it
	#./setup-full-8.3.25.1445-x86_64.run

sed -ri 's/Environment=SRV1CV8_DEBUG=/Environment=SRV1CV8_DEBUG=-debug/' /opt/1cv8/x86_64/8.3.25.1445/srv1cv8-8.3.25.1445@.service
sed -ri 's/Environment=SRV1CV8_DATA=\/home\/usr1cv8\/.1cv8\/1C\/1cv8/Environment=SRV1CV8_DATA=\/_data\/srv1c_inf_log/' /opt/1cv8/x86_64/8.3.25.1445/srv1cv8-8.3.25.1445@.service
sed -ri 's/Environment=SRV1CV8_KEYTAB=\/opt\/1cv8\/x86_64\/8.3.25.1445\/usr1cv8.keytab/Environment=SRV1CV8_KEYTAB=\/_data\/usr1cv8.keytab/' /opt/1cv8/x86_64/8.3.25.1445/srv1cv8-8.3.25.1445@.service

systemctl link /opt/1cv8/x86_64/8.3.25.1445/srv1cv8-8.3.25.1445@.service
systemctl link /opt/1cv8/x86_64/8.3.25.1445/ras-8.3.25.1445.service
systemctl enable srv1cv8-8.3.25.1445@default
systemctl enable ras-8.3.25.1445
systemctl start srv1cv8-8.3.25.1445@default
systemctl start ras-8.3.25.1445

    if grep -q 'Environment=SRV1CV8_DEBUG=-debug' /opt/1cv8/x86_64/8.3.25.1445/srv1cv8-8.3.25.1445@.service
    then
        echo 'DEBUG already ENABLED'
    else
        sed -ri 's/Environment=SRV1CV8_DEBUG=/Environment=SRV1CV8_DEBUG=-debug/' /opt/1cv8/x86_64/8.3.25.1445/srv1cv8-8.3.25.1445@.service
    fi
    sed -ri 's/Environment=SRV1CV8_DATA=\/home\/usr1cv8\/.1cv8\/1C\/1cv8/Environment=SRV1CV8_DATA=\/_data\/srv1c_inf_log/' /opt/1cv8/x86_64/8.3.25.1445/srv1cv8-8.3.25.1445@.service
    sed -ri 's/Environment=SRV1CV8_KEYTAB=\/opt\/1cv8\/x86_64\/'8.3.25.1445'\/usr1cv8.keytab/Environment=SRV1CV8_KEYTAB=\/_data\/usr1cv8.keytab/' /opt/1cv8/x86_64/8.3.25.1445/srv1cv8-8.3.25.1445@.service
fi
read -p 'Change & restart service 1c ? [Y/n]: ' -n 1 -r
echo
if [[ "$REPLY" =~ ^[yY]$ ]]
then
    systemctl link /opt/1cv8/x86_64/8.3.25.1445/srv1cv8-8.3.25.1445@.service
    systemctl link /opt/1cv8/x86_64/8.3.25.1445/ras-8.3.25.1445.service
    systemctl disable srv1cv83
    systemctl disable ras-8.3.17.1469
    systemctl enable srv1cv8-8.3.25.1445@default
    systemctl enable ras-8.3.25.1445
    systemctl stop srv1cv83
    systemctl stop ras-8.3.17.1469
    systemctl start srv1cv8-8.3.25.1445@default
    systemctl start ras-8.3.25.1445

#    sed -ri 's/'$old'/'8.3.25.1445'/' /_data/httpd/conf/extra/httpd-1C-pub.conf
#    sed -ri 's/'$old'/'8.3.25.1445'/' /_data/httpd/conf/extra/httpd-1C-pub-unauth.conf
#    systemctl restart httpd
fi
