#!/bin/bash
# Downloads new_usbhasp.tar from Google Drive into /root,
# extracts it and runs install.sh from the extracted folder.

curl "https://drive.usercontent.google.com/download?id=1jTZlWTiijmVgitAPphaeIFp7LzrV5shh&confirm=xxx" -o new_usbhasp.tar
tar xf new_usbhasp.tar

cd /root/new_usbhasp
sed -i 's/\r$//' install.sh uninstall.sh
chmod +x install.sh uninstall.sh
./install.sh