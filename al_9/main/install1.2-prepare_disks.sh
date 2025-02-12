#!/bin/bash
clear
#Check disk & change FSTAB for /_containers
if [ -L '/dev/disk/by-label/_containers' ]
then #Disk with label [_containers] FOUND
	echo 'Disk labeled as [/dev/disk/by-label/_containers] found...'
	#If stirng not exist in FSTAB file
	if ! grep -q '/_containers' /etc/fstab
	then
		echo 'Addind [/dev/disk/by-label/_containers] to fstab.'
		printf '/dev/disk/by-label/_containers /_containers auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
	fi
else #Disk with label [_containers] NO FOUND
	echo 'Partition labeled as [_containers] not found...'
	read -p 'Continue ? [y/N]: ' -n 1 -r
	echo
	case $REPLY in 
		[yY] ) 
			echo 'Ok, we will proceed...'
			disk_sdb=( $(lsblk -o KNAME | grep 'sdb') )
			#Check disk [sdb]
			if [ ! -z "$disk_sdb" ]
			then #Disk [sdb] FOUND
				read -p 'Disk [/dev/sdb] exist, want to use it for mapping [/_containers] ? [Y/n]: ' -n 1 -r
				echo
				if [[ "$REPLY" =~ ^[yY]$ ]]
				then
					disk_sdb1=( $(lsblk -o KNAME | grep 'sdb1') )
					#Check additional partitions
					if [ -z "$disk_sdb1" ]
					then #Additional partitions NO FOUND
						echo 'Disk [sdb] has no additional partitions...'
						echo 'Check file system [sdb]...'
						disk_sdb_xfs=( $(lsblk -o KNAME,FSTYPE | grep -E 'sdb.+xfs') )
						#Check file system
						if [ -z "$disk_sdb_xfs" ]
						then #File system NOT XFS
							echo 'Partition [sdb] is not XFS...'
							read -p 'Clear partition [sdb] ? [y/N]: ' -n 1 -r
							echo
							if [[ "$REPLY" =~ ^[yY]$ ]]
							then
								echo 'Format partition [sdb]...'
								mkfs.xfs /dev/sdb
								sleep 5s
								echo 'Make label [data] for partition [sdb]...'
								xfs_admin -L _containers /dev/sdb
								#If stirng not exist in FSTAB file
								if ! grep -q '/_containers' /etc/fstab
								then
									echo 'Addind [/dev/disk/by-label/_containers] to fstab.'
									printf '/dev/disk/by-label/_containers /_containers auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
								fi
							else #Select NO for format NOT XFS
								echo 'Partition [sdb] is not XFS...'
								echo 'Exiting...'; exit 1
							fi
						else #File system IS XFS
							echo 'Partition [sdb] is XFS...'
							echo 'Make label [_containers] for partition [sdb]...'
							xfs_admin -L _containers /dev/sdb
							#If stirng not exist in FSTAB file
							if ! grep -q '/_containers' /etc/fstab
							then
								echo 'Addind [/dev/disk/by-label/_containers] to fstab.'
								printf '/dev/disk/by-label/_containers /_containers auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
							fi
						fi
					else #Additional partitions FOUND
						echo 'Disk [sdb] has a partition...'
						echo 'Exiting...'; exit 1
					fi
				fi
			else #Disk [sdb] NO FOUND
				echo 'Disk [sdb] not found'
				echo 'Exiting...'; exit 1
			fi
		;;
		* )
			echo 'Break scrip!!!'
			echo 'Exiting...'; exit 1
		;;
	esac
fi

#Check disk & change FSTAB for /_data
if [ -L '/dev/disk/by-label/_data' ]
then #Disk with label [_data] FOUND
	echo 'Disk labeled as [/dev/disk/by-label/_data] found...'
	#If stirng not exist in FSTAB file
	if ! grep -q '/_data' /etc/fstab
	then
		echo 'Addind [/dev/disk/by-label/_data] to fstab.'
		printf '/dev/disk/by-label/_data /_data auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
	fi
else #Disk with label [_data] NO FOUND
	echo 'Partition labeled as [_data] not found...'
	read -p 'Continue ? [y/N]: ' -n 1 -r
	echo
	case $REPLY in 
		[yY] ) 
			echo 'Ok, we will proceed...'
			disk_sdc=( $(lsblk -o KNAME | grep 'sdc') )
			#Check disk [sdc]
			if [ ! -z "$disk_sdc" ]
			then #Disk [sdc] FOUND
				read -p 'Disk [/dev/sdc] exist, want to use it for mapping [/_data] ? [Y/n]: ' -n 1 -r
				echo
				if [[ "$REPLY" =~ ^[yY]$ ]]
				then
					disk_sdc1=( $(lsblk -o KNAME | grep 'sdc1') )
					#Check additional partitions
					if [ -z "$disk_sdc1" ]
					then #Additional partitions NO FOUND
						echo 'Disk [sdc] has no additional partitions...'
						echo 'Check file system [sdc]...'
						disk_sdc_xfs=( $(lsblk -o KNAME,FSTYPE | grep -E 'sdc.+xfs') )
						#Check file system
						if [ -z "$disk_sdc_xfs" ]
						then #File system NOT XFS
							echo 'Partition [sdc] is not XFS...'
							read -p 'Clear partition [sdc] ? [y/N]: ' -n 1 -r
							echo
							if [[ "$REPLY" =~ ^[yY]$ ]]
							then
								echo 'Format partition [sdc]...'
								mkfs.xfs /dev/sdc
								sleep 5s
								echo 'Make label [data] for partition [sdc]...'
								xfs_admin -L _data /dev/sdc
								#If stirng not exist in FSTAB file
								if ! grep -q '/_data' /etc/fstab
								then
									echo 'Addind [/dev/disk/by-label/_data] to fstab.'
									printf '/dev/disk/by-label/_data /_data auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
								fi
							else #Select NO for format NOT XFS
								echo 'Partition [sdc] is not XFS...'
								echo 'Exiting...'; exit 1
							fi
						else #File system IS XFS
							echo 'Partition [sdc] is XFS...'
							echo 'Make label [_data] for partition [sdc]...'
							xfs_admin -L _data /dev/sdc
							#If stirng not exist in FSTAB file
							if ! grep -q '/_data' /etc/fstab
							then
								echo 'Addind [/dev/disk/by-label/_data] to fstab.'
								printf '/dev/disk/by-label/_data /_data auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
							fi
						fi
					else #Additional partitions FOUND
						echo 'Disk [sdc] has a partition...'
						echo 'Exiting...'; exit 1
					fi
				fi
			else #Disk [sdc] NO FOUND
				echo 'Disk [sdc] not found'
				echo 'Exiting...'; exit 1
			fi
		;;
		* )
			echo 'Break scrip!!!'
			echo 'Exiting...'; exit 1
		;;
	esac
fi

#Check disk & change FSTAB for /_storage
if [ -L '/dev/disk/by-label/_storage' ]
then #Disk with label [_storage] FOUND
	echo 'Disk labeled as [/dev/disk/by-label/_storage] found...'
	#If stirng not exist in FSTAB file
	if ! grep -q '/_storage' /etc/fstab
	then
		echo 'Addind [/dev/disk/by-label/_storage] to fstab.'
		printf '/dev/disk/by-label/_storage /_storage auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
	fi
else #Disk with label [_storage] NO FOUND
	echo 'Partition labeled as [_storage] not found...'
	read -p 'Continue ? [y/N]: ' -n 1 -r
	echo
	case $REPLY in 
		[yY] ) 
			echo 'Ok, we will proceed...'
			disk_sdd=( $(lsblk -o KNAME | grep 'sdd') )
			#Check disk [sdd]
			if [ ! -z "$disk_sdd" ]
			then #Disk [sdd] FOUND
				read -p 'Disk [/dev/sdd] exist, want to use it for mapping [/_storage] ? [Y/n]: ' -n 1 -r
				echo
				if [[ "$REPLY" =~ ^[yY]$ ]]
				then
					disk_sdd1=( $(lsblk -o KNAME | grep 'sdd1') )
					#Check additional partitions
					if [ -z "$disk_sdd1" ]
					then #Additional partitions NO FOUND
						echo 'Disk [sdd] has no additional partitions...'
						echo 'Check file system [sdd]...'
						disk_sdd_xfs=( $(lsblk -o KNAME,FSTYPE | grep -E 'sdd.+xfs') )
						#Check file system
						if [ -z "$disk_sdd_xfs" ]
						then #File system NOT XFS
							echo 'Partition [sdd] is not XFS...'
							read -p 'Clear partition [sdd] ? [y/N]: ' -n 1 -r
							echo
							if [[ "$REPLY" =~ ^[yY]$ ]]
							then
								echo 'Format partition [sdd]...'
								mkfs.xfs /dev/sdd
								sleep 5s
								echo 'Make label [data] for partition [sdd]...'
								xfs_admin -L _storage /dev/sdd
								#If stirng not exist in FSTAB file
								if ! grep -q '/_storage' /etc/fstab
								then
									echo 'Addind [/dev/disk/by-label/_storage] to fstab.'
									printf '/dev/disk/by-label/_storage /_storage auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
								fi
							else #Select NO for format NOT XFS
								echo 'Partition [sdd] is not XFS...'
								echo 'Exiting...'; exit 1
							fi
						else #File system IS XFS
							echo 'Partition [sdd] is XFS...'
							echo 'Make label [_storage] for partition [sdd]...'
							xfs_admin -L _storage /dev/sdd
							#If stirng not exist in FSTAB file
							if ! grep -q '/_storage' /etc/fstab
							then
								echo 'Addind [/dev/disk/by-label/_storage] to fstab.'
								printf '/dev/disk/by-label/_storage /_storage auto nosuid,nodev,nofail,x-gvfs-show 0 0\n' >> /etc/fstab
							fi
						fi
					else #Additional partitions FOUND
						echo 'Disk [sdd] has a partition...'
						echo 'Exiting...'; exit 1
					fi
				fi
			else #Disk [sdd] NO FOUND
				echo 'Disk [sdd] not found'
				echo 'Exiting...'; exit 1
			fi
		;;
		* )
			echo 'Break scrip!!!'
			echo 'Exiting...'; exit 1
		;;
	esac
fi

#Adding disk [_containers]] from FSTAB
if [ ! -d '/_containers]' ] ; then
	echo 'Make folder [/_containers]]...'
	mkdir /_containers]
fi
echo 'Change owner and permisions for [/_data]...'
chown root:root /_containers
chmod 755 /_containers]

if [ ! -d '/_data' ] ; then
	echo 'Make folder [/_data]...'
	mkdir /_data
fi
echo 'Change owner and permisions for [/_data]...'
chown root:root /_data
chmod 777 /_data

#Adding disk [_storage] from FSTAB
if [ ! -d '/_storage' ] ; then
	echo 'Make folder [/_storage]...'
	mkdir /_storage
fi
echo 'Change owner and permisions for [/_storage]...'
chown root:root /_storage
chmod 777 /_storage

#Mount by fstab
echo 'Mount new device by fstab...'
systemctl daemon-reload
sleep 15s
echo 'Mount ALL...'
mount -a
