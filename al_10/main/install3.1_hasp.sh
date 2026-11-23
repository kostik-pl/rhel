#!/bin/bash

eexit() {
  >&2 echo
  for arg in "$@"; do >&2 echo "$arg"; done
  exit 1
}

msg() { >&2 echo "--> $*"; }

[[ "$(id -u)" == "0" ]] || \
eexit 'This script must be run as root'

# Google Drive file ID of new_haspusb.tar
# (from https://drive.google.com/file/d/<FILE_ID>/view)
FILE_ID='1jTZlWTiijmVgitAPphaeIFp7LzrV5shh'

WORK_DIR=/root
ARCHIVE=${WORK_DIR}/new_haspusb.tar

for tool in curl tar; do
  command -v $tool 1>/dev/null 2>&1 || dnf install -y $tool || \
  eexit "Failed to install '$tool'"
done

# ---------- Download ----------

msg "Downloading new_haspusb.tar (file ID: $FILE_ID)"
rm -f "$ARCHIVE"
curl -fL --retry 3 --progress-bar -o "$ARCHIVE" \
  "https://drive.usercontent.google.com/download?id=${FILE_ID}&export=download&confirm=t" || \
eexit 'Download failed'

# Google returns an HTML page instead of the file if the link is not public
tar tf "$ARCHIVE" 1>/dev/null 2>&1 || {
  head -c 300 "$ARCHIVE" | grep -qi '<html' && \
  eexit 'Google Drive returned a web page instead of the archive.' \
        'Check that the file is shared as "Anyone with the link".'
  eexit "Downloaded file is not a valid tar archive: $ARCHIVE"
}

# ---------- Extract ----------

# Path of install.sh inside the archive, e.g. "new_haspusb/install.sh"
INSTALL_REL=$(tar tf "$ARCHIVE" | grep -E '(^|/)install\.sh$' | awk -F/ '{print NF, $0}' | sort -n | head -n1 | cut -d' ' -f2-)
[[ -n "$INSTALL_REL" ]] || \
eexit 'install.sh not found in the archive'

TOP_DIR=${INSTALL_REL%%/*}
if [[ "$TOP_DIR" != "$INSTALL_REL" && -n "$TOP_DIR" && "$TOP_DIR" != "." ]]; then
  # Remove a previous copy so no stale files are left behind
  msg "Removing previous ${WORK_DIR}/${TOP_DIR}"
  rm -rf "${WORK_DIR:?}/${TOP_DIR}"
fi

msg "Extracting into ${WORK_DIR}"
tar xf "$ARCHIVE" -C "$WORK_DIR" || \
eexit 'Failed to extract the archive'

INSTALL_SH=${WORK_DIR}/${INSTALL_REL}
INSTALL_DIR=$(dirname "$INSTALL_SH")

# ---------- Run install.sh ----------

# Fix Windows line endings and lost exec bits
sed -i 's/\r$//' "$INSTALL_SH" "${INSTALL_DIR}/uninstall.sh" 2>/dev/null
chmod +x "$INSTALL_SH" "${INSTALL_DIR}/uninstall.sh" 2>/dev/null

msg "Running $INSTALL_SH (log: ${INSTALL_DIR}/install.log)"
cd "$INSTALL_DIR" || eexit "Can't enter $INSTALL_DIR"
./install.sh 2>&1 | tee install.log
exit ${PIPESTATUS[0]}