#!/bin/bash
#Version 1cv8 use only new install 
#old=8.3.21.1302
old=8.3.22.1750
#8.3.25.1286
new=8.3.25.1445
#Google Drive files
#id_1c_file=1eYMu7e0KNAfByJMZqjNsUPjf3slyQBxJ #8.3.21.1302
#id_1c_file=1ZsCOPrMJl5fU0r4tsEPE0C7tluO-i3zX #8.3.25.1286
id_1c_file=1n_PTnHOY5_M__JxMzkfWrt3Z69UuZVae #8.3.25.1445
file_name="setup-full-"$new"-x86_64.run"

read -p 'Start install 1c ? [Y/n]: ' -n 1 -r
echo
if [[ "$REPLY" =~ ^[yY]$ ]]
then
    #Install 1C Enterprise server packages from work dir
    #Download form GOOGLE
    curl "https://drive.usercontent.google.com/download?id=$id_1c_file&confirm=xxx" -o $file_name
    chmod +x $file_name
    #ATTENTION! Batch installation will always install the 1c client and, if missing, the trimmed GNOME
    #Manual installation the process will run witout options
    ./$file_name --mode unattended --unattendedmodeui minimal --disable-components client_full,client_thin,client_thin_fib,config_storage_server,liberica_jre,integrity_monitoring --enable-components server,server_admin,ws,additional_admin_functions,v8_install_deps,uk,ru

    if [ -f '/opt/1cv8/x86_64/'$old'/usr1cv8.keytab ' ]
    then 
        yes | cp -v '/opt/1cv8/x86_64/'$old'/usr1cv8.keytab' /_data/usr1cv8.keytab
        chown usr1cv8:grp1cv8 /_data/usr1cv8.keytab
        chmod 644 /_data/usr1cv8.keytab
    fi

    if grep -q 'Environment=SRV1CV8_DEBUG=-debug' /opt/1cv8/x86_64/$new/srv1cv8-$new@.service
    then
        echo 'DEBUG already ENABLED'
    else
	    sed -ri 's/Environment=SRV1CV8_DEBUG=/Environment=SRV1CV8_DEBUG=-debug/' /opt/1cv8/x86_64/$new/srv1cv8-$new@.service
    fi
    sed -ri 's/Environment=SRV1CV8_DATA=\/home\/usr1cv8\/.1cv8\/1C\/1cv8/Environment=SRV1CV8_DATA=\/_data\/srv1c_inf_log/' /opt/1cv8/x86_64/$new/srv1cv8-$new@.service
    sed -ri 's/Environment=SRV1CV8_KEYTAB=\/opt\/1cv8\/x86_64\/'$new'\/usr1cv8.keytab/Environment=SRV1CV8_KEYTAB=\/_data\/usr1cv8.keytab/' /opt/1cv8/x86_64/$new/srv1cv8-$new@.service
fi

read -p 'Change & restart service 1c ? [Y/n]: ' -n 1 -r
echo
if [[ "$REPLY" =~ ^[yY]$ ]]
then
    systemctl link /opt/1cv8/x86_64/$new/srv1cv8-$new@.service
    systemctl link /opt/1cv8/x86_64/$new/ras-$new.service
    systemctl disable srv1cv8-$old@default
    systemctl disable ras-$old
    systemctl enable srv1cv8-$new@default
    systemctl enable ras-$new
    systemctl stop srv1cv8-$old@default
    systemctl stop ras-$old
    systemctl start srv1cv8-$new@default
    systemctl start ras-$new

    sed -ri 's/'$old'/'$new'/' /_data/httpd/conf/extra/httpd-1c-pub.conf
    sed -ri 's/'$old'/'$new'/' /_data/httpd/conf/extra/httpd-1c-pub_unauth.conf
    systemctl restart httpd
fi