#!/bin/sh
apt-get install nfs-kernel-server
mkdir -p /var/nfsshare
chown nobody:nogroup /var/nfsshare
chmod 777 /var/nfsshare
echo '/var/nfsshare *(rw,sync)'>>/etc/exports
exportfs -a
systemctl restart nfs-kernel-server

