#!/bin/bash

#Install 1C Enterprise server packages from work dir
#Download form GOOGLE
curl "https://drive.usercontent.google.com/download?id=1ZsCOPrMJl5fU0r4tsEPE0C7tluO-i3zX&confirm=xxx" -o setup-full-8.3.25.1286-x86_64.run
chmod +x setup-full-8.3.25.1286-x86_64.run
#ATTENTION! Batch installation will always install the 1c client and, if missing, the trimmed GNOME
./setup-full-8.3.25.1286-x86_64.run --mode unattended --unattendedmodeui minimal --disable-components client_full,client_thin,client_thin_fib,config_storage_server,liberica_jre,integrity_monitoring --enable-components server,server_admin,ws,additional_admin_functions,v8_install_deps,uk,ru
#Manual installation, if have GUI (GNOME), the process will run in it
#./setup-full-8.3.25.1286-x86_64.run

sed -ri 's/Environment=SRV1CV8_DEBUG=/Environment=SRV1CV8_DEBUG=-debug/' /opt/1cv8/x86_64/8.3.25.1286/srv1cv8-8.3.25.1286@.service
sed -ri 's/Environment=SRV1CV8_DATA=\/home\/usr1cv8\/.1cv8\/1C\/1cv8/Environment=SRV1CV8_DATA=\/_data\/srv1c_inf_log/' /opt/1cv8/x86_64/8.3.25.1286/srv1cv8-8.3.25.1286@.service

systemctl link /opt/1cv8/x86_64/8.3.25.1286/srv1cv8-8.3.25.1286@.service
systemctl link /opt/1cv8/x86_64/8.3.25.1286/ras-8.3.25.1286.service
systemctl disable srv1cv8-8.3.21.1302@default
systemctl disable ras-8.3.21.1302
systemctl enable srv1cv8-8.3.25.1286@default
systemctl enable ras-8.3.25.1286
systemctl stop srv1cv8-8.3.21.1302@default
systemctl stop ras-8.3.21.1302
systemctl start srv1cv8-8.3.25.1286@default
systemctl start ras-8.3.25.1286