#!/bin/bash
clear

###############################################
# DETECT DISK TYPE (SCSI or NVMe)
###############################################

DISK_LIST=( $(lsblk -ndo NAME,TYPE | awk '$2=="disk"{print $1}') )
DISK_COUNT=${#DISK_LIST[@]}

echo "Total physical disks found: $DISK_COUNT"

if [[ "$DISK_COUNT" -lt 2 ]]; then
    echo "Not enough disks for /_data"
    exit 1
fi

# Determine disk type
if [[ "${DISK_LIST[0]}" =~ ^sd ]]; then
    DISK_TYPE="scsi"
elif [[ "${DISK_LIST[0]}" =~ ^nvme ]]; then
    DISK_TYPE="nvme"
else
    echo "Unknown disk type!"
    exit 1
fi

echo "Detected disk type: $DISK_TYPE"

###############################################
# UNIVERSAL PARTITION CHECK
###############################################
partition_exists() {
    local disk="$1"
    lsblk -ndo NAME | grep -qx "${disk}1" || lsblk -ndo NAME | grep -qx "${disk}p1"
}

###############################################
# UNIVERSAL FS TYPE CHECK
###############################################
get_fs_type() {
    blkid -o value -s TYPE "/dev/$1" 2>/dev/null
}

###############################################
# SELECT DISKS FOR _data AND _storage
###############################################

DISK_DATA="${DISK_LIST[1]}"
DISK_STORAGE="${DISK_LIST[2]}"

echo "Disk for /_data: /dev/$DISK_DATA"
echo "Disk for /_storage: /dev/$DISK_STORAGE"

###############################################
# PROCESS /_data DISK
###############################################

if [ "$DISK_COUNT" -ge 2 ]; then
    if [ -L '/dev/disk/by-label/_data' ]; then
        echo 'Disk labeled as [_data] found...'
        if ! grep -q '/_data' /etc/fstab; then
            echo 'Adding [_data] to fstab.'
            printf '/dev/disk/by-label/_data /_data auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
        fi
    else
        echo 'Partition labeled as [_data] not found...'
        read -p 'Continue ? [y/N]: ' -n 1 -r
        echo
        case $REPLY in
            [yY] )
                echo "Using disk /dev/$DISK_DATA for /_data"

                if partition_exists "$DISK_DATA"; then
                    echo "Disk /dev/$DISK_DATA has partitions!"
                    echo "Exiting..."
                    exit 1
                fi

                fs=$(get_fs_type "$DISK_DATA")

                if [[ "$fs" != "xfs" ]]; then
                    echo "Disk /dev/$DISK_DATA is not XFS..."
                    read -p 'Clear partition ? [y/N]: ' -n 1 -r
                    echo
                    if [[ "$REPLY" =~ ^[yY]$ ]]; then
                        echo "Formatting /dev/$DISK_DATA..."
                        mkfs.xfs "/dev/$DISK_DATA"
                        sleep 5s
                        echo "Setting label [_data]..."
                        xfs_admin -L _data "/dev/$DISK_DATA"

                        if ! grep -q '/_data' /etc/fstab; then
                            printf '/dev/disk/by-label/_data /_data auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
                        fi
                    else
                        echo "Exiting..."
                        exit 1
                    fi
                else
                    echo "Disk /dev/$DISK_DATA is XFS..."
                    echo "Setting label [_data]..."
                    xfs_admin -L _data "/dev/$DISK_DATA"

                    if ! grep -q '/_data' /etc/fstab; then
                        printf '/dev/disk/by-label/_data /_data auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
                    fi
                fi
            ;;
            * )
                echo 'Break script!!!'
                exit 1
            ;;
        esac
    fi
fi

###############################################
# PROCESS /_storage DISK
###############################################

if [ "$DISK_COUNT" -ge 3 ]; then
    if [ -L '/dev/disk/by-label/_storage' ]; then
        echo 'Disk labeled as [_storage] found...'
        if ! grep -q '/_storage' /etc/fstab; then
            printf '/dev/disk/by-label/_storage /_storage auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
        fi
    else
        echo 'Partition labeled as [_storage] not found...'
        read -p 'Continue ? [y/N]: ' -n 1 -r
        echo
        case $REPLY in
            [yY] )
                echo "Using disk /dev/$DISK_STORAGE for /_storage"

                if partition_exists "$DISK_STORAGE"; then
                    echo "Disk /dev/$DISK_STORAGE has partitions!"
                    exit 1
                fi

                fs=$(get_fs_type "$DISK_STORAGE")

                if [[ "$fs" != "xfs" ]]; then
                    echo "Disk /dev/$DISK_STORAGE is not XFS..."
                    read -p 'Clear partition ? [y/N]: ' -n 1 -r
                    echo
                    if [[ "$REPLY" =~ ^[yY]$ ]]; then
                        echo "Formatting /dev/$DISK_STORAGE..."
                        mkfs.xfs "/dev/$DISK_STORAGE"
                        sleep 5s
                        echo "Setting label [_storage]..."
                        xfs_admin -L _storage "/dev/$DISK_STORAGE"

                        if ! grep -q '/_storage' /etc/fstab; then
                            printf '/dev/disk/by-label/_storage /_storage auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
                        fi
                    else
                        echo "Exiting..."
                        exit 1
                    fi
                else
                    echo "Disk /dev/$DISK_STORAGE is XFS..."
                    echo "Setting label [_storage]..."
                    xfs_admin -L _storage "/dev/$DISK_STORAGE"

                    if ! grep -q '/_storage' /etc/fstab; then
                        printf '/dev/disk/by-label/_storage /_storage auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
                    fi
                fi
            ;;
            * )
                echo 'Break script!!!'
                exit 1
            ;;
        esac
    fi
fi

###############################################
# CREATE DIRECTORIES AND MOUNT
###############################################

if [ ! -d '/_data' ]; then
    mkdir /_data
fi
chown root:root /_data
chmod 777 /_data

if [ ! -d '/_storage' ]; then
    mkdir /_storage
fi
chown root:root /_storage
chmod 777 /_storage

echo 'Reloading systemd...'
systemctl daemon-reload
sleep 15s

echo 'Mounting all...'
mount -a
