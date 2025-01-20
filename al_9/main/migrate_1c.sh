#!/bin/bash
#Version 1cv8 use only new install 
old=8.3.21.1302
#8.3.22.1750
#8.3.25.1286
new=8.3.25.1445
#Google Drive files
#id_1c_file=1eYMu7e0KNAfByJMZqjNsUPjf3slyQBxJ #8.3.21.1302
#id_1c_file=1ZsCOPrMJl5fU0r4tsEPE0C7tluO-i3zX #8.3.25.1286
id_1c_file=1n_PTnHOY5_M__JxMzkfWrt3Z69UuZVae #8.3.25.1445
file_name="setup-full-"$new"-x86_64.run"
#Install 1C Enterprise server packages from work dir
#Download form GOOGLE
curl "https://drive.usercontent.google.com/download?id=$id_1c_file&confirm=xxx" -o $file_name
chmod +x $file_name
#ATTENTION! Batch installation will always install the 1c client and, if missing, the trimmed GNOME
#Manual installation the process will run witout options
./$file_name --mode unattended --unattendedmodeui minimal --disable-components client_full,client_thin,client_thin_fib,config_storage_server,liberica_jre,integrity_monitoring --enable-components server,server_admin,ws,additional_admin_functions,v8_install_deps,uk,ru

sed -ri 's/Environment=SRV1CV8_DEBUG=/Environment=SRV1CV8_DEBUG=-debug/' /opt/1cv8/x86_64/$new/srv1cv8-$new@.service
sed -ri 's/Environment=SRV1CV8_DATA=\/home\/usr1cv8\/.1cv8\/1C\/1cv8/Environment=SRV1CV8_DATA=\/_data\/srv1c_inf_log/' /opt/1cv8/x86_64/$new/srv1cv8-$new@.service
sed -ri 's/Environment=SRV1CV8_KEYTAB=\/opt\/1cv8\/x86_64\/'$new'\/usr1cv8.keytab/Environment=SRV1CV8_KEYTAB=\/_data\/usr1cv8.keytab/' /opt/1cv8/x86_64/$new/srv1cv8-$new@.service

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