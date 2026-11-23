#!/bin/bash
# Removes everything installed by install.sh:
# usbhasp, libusb_vhci, usb-vhci-hcd (DKMS) and Sentinel LDK RTE,
# plus leftovers of the old (pre-RPM) installer.
#
# Usage: ./uninstall.sh           - keep key dumps in /etc/usbhaspd/keys
#        ./uninstall.sh --purge   - remove key dumps as well
#
# Build dependencies (dkms, kernel-devel, gcc-c++, jansson-devel, epel-release)
# are NOT removed: other software may use them.

eexit() {
  >&2 echo
  for arg in "$@"; do >&2 echo "$arg"; done
  exit 1
}

msg() { >&2 echo "--> $*"; }

[[ "$(id -u)" == "0" ]] || \
eexit 'This script must be run as root'

PM=$(dnf --version 1>/dev/null 2>&1 && echo dnf) || \
eexit 'Unsupported package manager (dnf is required)'
PMSi='rpm -q'

PURGE=0
[[ "$1" == "--purge" ]] && PURGE=1

SDIR=$(dirname $(readlink -f $0))

# ---------- Emulator usbhasp ----------

msg 'Stopping and removing usbhaspd'
systemctl is-active --quiet usbhaspd && systemctl stop usbhaspd
systemctl is-enabled --quiet usbhaspd 2>/dev/null && systemctl disable usbhaspd

rm -f /lib/systemd/system/usbhaspd.service
rm -f /usr/bin/usbhaspd /usr/bin/usbhasp
rm -f /etc/usbhaspd/usbhaspd.conf

if [[ $PURGE == 1 ]]; then
  msg 'Removing key dumps (--purge)'
  rm -rf /etc/usbhaspd
else
  rmdir /etc/usbhaspd/keys /etc/usbhaspd 2>/dev/null || \
  msg 'Key dumps kept in /etc/usbhaspd/keys (use --purge to remove)'
fi

# ---------- Kernel headers helper (cron) ----------

msg 'Removing install-headers'
rm -f /etc/cron.d/install-headers /usr/sbin/install-headers

# ---------- Sentinel LDK Run-time Environment ----------

if $PMSi aksusbd 1>/dev/null 2>&1; then
  msg 'Removing Sentinel LDK RTE package'
  # The package's own scripts stop and disable aksusbd and hasplmd
  $PM remove -y aksusbd || \
  eexit 'Failed to remove Sentinel LDK RTE package (aksusbd)'
else
  msg 'Sentinel LDK RTE package not installed, cleaning up old installer leftovers'
  for svc in aksusbd hasplmd; do
    systemctl is-active --quiet $svc && systemctl stop $svc
    systemctl is-enabled --quiet $svc 2>/dev/null && systemctl disable $svc
  done
  rm -f /etc/systemd/system/aksusbd.service /etc/systemd/system/hasplmd.service
  rm -f /usr/sbin/aksusbd /usr/sbin/aksusbd_x86_64
  rm -f /usr/sbin/hasplmd /usr/sbin/hasplmd_x86_64
  rm -f /etc/udev/rules.d/80-hasp.rules
fi
rm -f /var/hasplm/init/force_x86_64
rmdir /var/hasplm/init /var/hasplm 2>/dev/null

# Old installer only: NetHASP License Manager and usbhaspinfo
systemctl is-active --quiet hasplm && systemctl stop hasplm
systemctl is-enabled --quiet hasplm 2>/dev/null && systemctl disable hasplm
rm -f /etc/systemd/system/hasplm.service
rm -f /usr/sbin/hasplm /usr/sbin/usbhaspinfo
rm -f /etc/hasplm/hasplm.conf /etc/hasplm/nethasp.ini
rmdir /etc/hasplm 2>/dev/null

# ---------- Kernel module usb-vhci-hcd (DKMS) ----------

msg 'Unloading kernel modules'
modprobe -r usb_vhci_iocifc 2>/dev/null
modprobe -r usb_vhci_hcd 2>/dev/null

if dkms status usb-vhci-hcd/1.15.1 2>/dev/null | grep -q usb-vhci-hcd; then
  msg 'Removing usb-vhci-hcd from DKMS'
  dkms remove usb-vhci-hcd/1.15.1 --all || \
  eexit "Failed to remove 'usb-vhci-hcd' from DKMS"
fi
rm -rf /usr/src/usb-vhci-hcd-1.15.1

# ---------- Library libusb_vhci ----------

msg 'Removing libusb_vhci'
if [[ -f ${SDIR}/src/libusb_vhci-0.8/Makefile ]]; then
  make -C ${SDIR}/src/libusb_vhci-0.8 uninstall 1>/dev/null 2>&1
fi
# Fallback in case the configured source tree is not available
rm -f /usr/local/lib/libusb_vhci.*
rm -f /usr/local/include/libusb_vhci.h /usr/local/include/libusb-vhci.h
ldconfig
# /etc/ld.so.conf.d/libc.conf (/usr/local/lib) is left in place:
# it is harmless and other software may rely on it

# ---------- Finish ----------

systemctl daemon-reload
udevadm control --reload 2>/dev/null

>&2 echo -e "\nDone!\n"