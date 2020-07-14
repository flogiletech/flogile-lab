#!/bin/sh
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
	echo "Please run as a root user"
    exit
fi
lockfile1=/var/cache/apt/archives/lock
lockfile2=/var/lib/dpkg/lock-frontend
[ -f $lockfile1 ] && rm -rf $lockfile1
[ -f $lockfile2 ] && rm -rf $lockfile2
apt-get install nfs-kernel-server
mkdir -p /var/nfsshare
chown nobody:nogroup /var/nfsshare
chmod 777 /var/nfsshare
echo '/var/nfsshare *(rw,sync)'>>/etc/exports
exportfs -a
systemctl restart nfs-kernel-server

