#!/bin/sh
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
	echo "Please run as a root user"
    exit
fi
lockfile1=/var/cache/apt/archives/lock
lockfile2=/var/cache/apt/archives/lock-frontend
lockfile3=/var/lib/dpkg/lock-frontend
lockfile4=/var/lib/dpkg/lock
[ -f $lockfile1 ] && rm -rf $lockfile1
[ -f $lockfile2 ] && rm -rf $lockfile2
[ -f $lockfile3 ] && rm -rf $lockfile3
[ -f $lockfile4 ] && rm -rf $lockfile4
apt-get install nfs-kernel-server
mkdir -p /var/nfsshare
chown nobody:nogroup /var/nfsshare
chmod 777 /var/nfsshare
echo '/var/nfsshare *(rw,sync)'>>/etc/exports
exportfs -a
systemctl restart nfs-kernel-server

