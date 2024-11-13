systemctl disable srv1cv8-8.3.21.1302@default
systemctl disable ras-8.3.21.1302
systemctl stop srv1cv8-8.3.21.1302@default
systemctl stop ras-8.3.21.1302

systemctl link /opt/1cv8/x86_64/8.3.25.1286/srv1cv8-8.3.25.1286@.service
systemctl link /opt/1cv8/x86_64/8.3.25.1286/ras-8.3.25.1286.service
systemctl enable srv1cv8-8.3.25.1286@default
systemctl enable ras-8.3.25.1286
systemctl start srv1cv8-8.3.25.1286@default
systemctl start ras-8.3.25.1286
