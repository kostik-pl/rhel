#!/bin/bash
# Installs usb-vhci-hcd (DKMS), libusb_vhci and usbhasp on RHEL-based systems
# version 8+ (RHEL, AlmaLinux, Rocky, CentOS Stream, Oracle Linux, RED OS)

eexit() {
  >&2 echo
  for arg in "$@"; do >&2 echo "$arg"; done
  exit 1
}

[[ "$(id -u)" == "0" ]] || \
eexit 'This script must be run as root'

PM=$(dnf --version 1>/dev/null 2>&1 && echo dnf) || \
eexit 'Unsupported package manager (dnf is required)'

rpm --version 1>/dev/null 2>&1 || \
eexit 'Unsupported package management system (rpm is required)'
PMSi='rpm -q'

. /etc/os-release

[[ "${VERSION_ID%%.*}" =~ ^[0-9]+$ ]] && (( ${VERSION_ID%%.*} >= 8 )) || \
eexit "Only version 8 and later is supported (detected: $NAME $VERSION_ID)"

ARCH=$(uname -m)
[[ "$ARCH" == "x86_64" ]] || \
eexit 'This version of the script supports x86_64 only'

SDIR=$(dirname $(readlink -f $0))

# ---------- Locate Sentinel LDK RTE package (fail early) ----------

RTE_RPM=$(ls ${SDIR}/rpm/aksusbd-*.x86_64.rpm 2>/dev/null | sort -V | tail -n1)

# No RPM yet: extract it from the vendor archive if present
if [[ -z "$RTE_RPM" ]]; then
  RTE_TAR=$(ls ${SDIR}/rpm/Sentinel_LDK_*RPM*Run-time_Installer*gz 2>/dev/null | tail -n1)
  [[ -n "$RTE_TAR" ]] && \
  tar xzf "$RTE_TAR" -C ${SDIR}/rpm/ --strip-components=1 --wildcards '*/aksusbd-*.x86_64.rpm'
  RTE_RPM=$(ls ${SDIR}/rpm/aksusbd-*.x86_64.rpm 2>/dev/null | sort -V | tail -n1)
fi

[[ -n "$RTE_RPM" ]] || \
eexit "Sentinel LDK RTE not found in ${SDIR}/rpm/" \
      "Put aksusbd-*.x86_64.rpm or the Sentinel_LDK_..._RPM_Run-time_Installer archive there"

# ---------- Build dependencies ----------

$PM makecache --refresh && \
if [[ $NAME =~ ^Oracle ]]; then
  $PM install epel-release -y
  $PM install jansson-devel -y || \
  $PM --enablerepo=$($PM repolist all | awk '{print $1}' | grep -E '^ol[0-9]+_codeready_builder$' | head -n1) install jansson-devel -y && \
  $PM install kernel$(uname -r | grep uek 1>/dev/null 2>&1 && echo '-uek')-devel-$(uname -r) dkms gcc-c++ -y
elif [[ $ID == redos ]]; then
  $PM install epel-release -y
  $PM install jansson-devel -y && \
  $PM install kernel$(uname -r | grep '\-rt' 1>/dev/null 2>&1 && echo '-rt' || echo '-lt')-devel-$(uname -r | sed 's/-rt.*//') dkms gcc-c++ -y
else
  $PM install epel-release -y
  $PM install jansson-devel -y || \
  $PM --enablerepo=$($PM repolist all | awk '{print $1}' | grep -iE '^(crb|powertools|codeready-builder-for-rhel-[0-9]+-x86_64-rpms)$' | head -n1) install jansson-devel -y && \
  $PM install kernel-devel-$(uname -r) dkms gcc-c++ -y
fi || \
eexit 'Failed to install packages'

# ---------- Kernel module usb-vhci-hcd (DKMS) ----------

dkms status usb-vhci-hcd/1.15.1 | grep usb-vhci-hcd 1>/dev/null && \
eexit 'usb-vhci-hcd/1.15.1 is already installed' 'Run uninstall.sh first'

cp -fpr ${SDIR}/src/usb-vhci-hcd-1.15.1 /usr/src/
dkms add -m usb-vhci-hcd -v 1.15.1
dkms build -m usb-vhci-hcd -v 1.15.1 || \
eexit "Failed to build 'usb-vhci-hcd'"
dkms install -m usb-vhci-hcd -v 1.15.1 || \
eexit "Failed to install 'usb-vhci-hcd'"

# ---------- Library libusb_vhci ----------

cd ${SDIR}/src/libusb_vhci-0.8/
# Restore exec bits (they get lost when sources pass through Windows)
chmod +x configure config.guess config.sub install-sh missing depcomp compile 2>/dev/null
./configure CXXFLAGS='-std=c++11' && \
make && \
make install || \
eexit "Failed to build 'libusb-vhci'"

cat /etc/ld.so.conf.d/* | grep -E '^[[:blank:]]*/usr/local/lib/?[[:blank:]]*$' 1>/dev/null || \
cat << EOF > /etc/ld.so.conf.d/libc.conf
# libc default configuration
/usr/local/lib
EOF
ldconfig

# ---------- Emulator usbhasp ----------

cd ${SDIR}/src/UsbHasp/
# Clean first so a stale prebuilt binary in dist/ is never reused
make clean 1>/dev/null 2>&1
make CFLAGS=-std=gnu99 || \
eexit "Failed to build 'usbhasp'"

install -m 755 ${SDIR}/src/UsbHasp/dist/Release/GNU-Linux/usbhasp /usr/bin/usbhasp
mkdir -p /etc/usbhaspd/keys/

cat << EOF > /etc/usbhaspd/usbhaspd.conf
# Usbhaspd conf

# Dir for keys. Default /etc/usbhaspd/keys
# Simply put keys *.json to KEY_DIR
# KEY_DIR=/etc/usbhaspd/keys

EOF

cat << EOF > /usr/bin/usbhaspd
#!/bin/bash

NAME=usbhaspd

DAEMON_BIN=/usr/bin/usbhasp
KEY_DIR=/etc/\${NAME}/keys
DAEMON_CONF=/etc/\${NAME}/\${NAME}.conf

# read optional conf
if test -f \${DAEMON_CONF} ; then . \${DAEMON_CONF}; fi

# Read key list
keys=""
if test -d \${KEY_DIR}; then keys="\${KEY_DIR}/*.json"; fi

DAEMON_ARGS="\$keys"

# Start kernel modules
modprobe usb_vhci_hcd
modprobe usb_vhci_iocifc

# Start daemon
\$DAEMON_BIN \$DAEMON_ARGS

exit 0
EOF
chmod a+x /usr/bin/usbhaspd

cat << EOF > /lib/systemd/system/usbhaspd.service
[Unit]
Description=Usbhasp daemon

[Service]
Type=simple
ExecStart=/usr/bin/usbhaspd

[Install]
WantedBy=multi-user.target
EOF

# ---------- Install kernel-devel after a kernel update ----------

cat << EOF > /usr/sbin/install-headers
#!/bin/bash

[[ ! -f /usr/bin/usbhaspd ]] && exit

timeout=180
interval=10

start_time=\$(date +%s)

# Wait until the repositories are reachable (this also refreshes the metadata cache)
# (checked via dnf instead of ping: ICMP is often blocked)
while ! $PM -q makecache --refresh >/dev/null 2>&1; do
  current_time=\$(date +%s)
  (( current_time - start_time < timeout )) || exit
  sleep \$interval
done

$(
if [[ $NAME =~ ^Oracle ]]; then
  echo "$PMSi kernel\$(uname -r | grep uek 1>/dev/null 2>&1 && echo '-uek')-devel-\$(uname -r) 1>/dev/null 2>&1 || {"
  echo "  $PM install kernel\$(uname -r | grep uek 1>/dev/null 2>&1 && echo '-uek')-devel-\$(uname -r) -y && \\"
  echo "  dkms autoinstall && \\"
  echo "  { systemctl is-enabled usbhaspd && systemctl start usbhaspd; }"
  echo "}"
elif [[ $ID == redos ]]; then
  echo "$PMSi kernel\$(uname -r | grep '\-rt' 1>/dev/null 2>&1 && echo '-rt' || echo '-lt')-devel-\$(uname -r | sed 's/-rt.*//') 1>/dev/null 2>&1 || {"
  echo "  $PM install kernel\$(uname -r | grep '\-rt' 1>/dev/null 2>&1 && echo '-rt' || echo '-lt')-devel-\$(uname -r | sed 's/-rt.*//') -y && \\"
  echo "  dkms autoinstall && \\"
  echo "  { systemctl is-enabled usbhaspd && systemctl start usbhaspd; }"
  echo "}"
else
  echo "$PMSi kernel-devel-\$(uname -r) 1>/dev/null 2>&1 || {"
  echo "  $PM install kernel-devel-\$(uname -r) -y && \\"
  echo "  dkms autoinstall && \\"
  echo "  { systemctl is-enabled usbhaspd && systemctl start usbhaspd; }"
  echo "}"
fi
)
EOF
chmod a+x /usr/sbin/install-headers

cat << EOF > /etc/cron.d/install-headers
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
@reboot root if [ -x /usr/sbin/install-headers ]; then /usr/sbin/install-headers; fi
EOF

# ---------- Sentinel LDK Run-time Environment (official RPM) ----------
# (package was located at the start of the script)

# Force 64-bit daemons even if 32-bit glibc is present
# (checked by the package's post-install script)
mkdir -p /var/hasplm/init && touch /var/hasplm/init/force_x86_64

# Installs or upgrades; the package itself installs udev rules,
# systemd units and enables/starts aksusbd and hasplmd
$PM install -y "$RTE_RPM" || \
eexit "Failed to install Sentinel LDK RTE ($(basename "$RTE_RPM"))"

# ---------- Start the service ----------

systemctl daemon-reload
systemctl is-active --quiet usbhaspd && systemctl stop usbhaspd
cp -fpr ${SDIR}/dump/* /etc/usbhaspd/keys
systemctl start usbhaspd && systemctl enable usbhaspd

>&2 echo -e "\nDone!\n"