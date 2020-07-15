#!/bin/sh
# ###################################################################### #
# This is the shell script version Created by Flogile Technlologies Ltd  #
# ---------------------------------------------------------------------  #
# "Kmaster3_setup.sh" is will setup Kubernetes master node3              #
# Author: Anand Sreenivasan (anands@flogile.com)                         #
#                                                                        #
# Version 1.0.0:   Created by Anand Sreenivasan (14-July-2020)           #
# ###################################################################### #
#set -e
#Set servers IP
#ip4=$(/sbin/ip -o -4 addr list enp0s3 | awk '{print $4}' | cut -d/ -f1)
km1ip=192.168.0.131
km2ip=192.168.0.132
km3ip=192.168.0.133
kn1ip=192.168.0.134
vip=192.168.0.201
enp=enp0s3
sha256=""
certkey=""
token=""
echo
echo "* * * *  *          * * *      * * *    *  *        * * * *"
echo "*        *        *       *  *       *  *  *        *      "
echo "*        *        *       *  *          *  *        *      "
echo "* * *    *        *       *  *          *  *        * * *  "
echo "*        *        *       *  *   * * *  *  *        *      "
echo "*        *        *       *  *       *  *  *        *      "
echo "*        * * * *    * * *      * * *    *  * * * *  * * * *"   
echo
exec 1>log.out 2>&1
if [ $(/usr/bin/id -u) -ne 0 ]; then
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
#Master server hostname
km1name=kmaster1
km2name=kmaster2
km3name=kmaster3
kn1name=knode1
echo "Setting up Host entry..."
cat >>/etc/hosts<<EOF
$km1ip $km1name
$km2ip $km2name
$km3ip $km3name
$kn1ip $kn1name
EOF
apt-get update -y
hostnamectl set-hostname $km3name
if [ "$?" -ne 0 ]; then 
echo "failed to set hostname!!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "Setting hostname.."
exec 1>>log.out 2>&1
ufw disable
if [ "$?" -ne 0 ]; then 
echo "Failed to Disabled ufw!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "Disabled ufw..."
exec 1>>log.out 2>&1
swapoff -a
if [ "$?" -ne 0 ]; then 
echo "Failed to swapoff!!"
    exit 1
fi
echo "swapoff is done...."
sed -i '/swap/d' /etc/fstab
if [ "$?" -ne 0 ]; then 
echo "Failed to remove swap entry!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "Removed swap entry....."
exec 1>>log.out 2>&1
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward       = 1
EOF
sysctl --system
if [ "$?" -ne 0 ]; then 
echo "Failed to update kube config!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "updated kube config......"
exec 1>>log.out 2>&1
apt-get install docker.io -y 
if [ "$?" -ne 0 ]; then 
echo "Failed to installed docker!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "Successfuly installed docker......"
exec 1>>log.out 2>&1
systemctl enable docker
if [ "$?" -ne 0 ]; then 
echo "Failed to Enable docker!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "Successfuly enabled docker......."
exec 1>>log.out 2>&1
systemctl start docker
if [ "$?" -ne 0 ]; then 
echo "Failed to started docker!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "Successfuly started docker........"
exec 1>>log.out 2>&1
apt-get install curl -y
if [ "$?" -ne 0 ]; then 
echo "Failed to installed curl!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "Successfuly installed curl........."
exec 1>>log.out 2>&1
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
if [ "$?" -ne 0 ]; then 
echo "Failed to add apt-key!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "Successfuly add apt-key.........."
exec 1>>log.out 2>&1
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
if [ "$?" -ne 0 ]; then 
echo "Failed to add kube repo!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "Successfuly add kube repo..........."
exec 1>>log.out 2>&1
apt install -y kubeadm=1.18.5-00 kubelet=1.18.5-00 kubectl=1.18.5-00
if [ "$?" -ne 0 ]; then 
echo "Failed to install kubeadm kubelet kubectl!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "Successfuly installed kubeadm kubelet kubectl............"
exec 1>>log.out 2>&1
apt-mark hold kubeadm kubelet kubectl
if [ "$?" -ne 0 ]; then 
echo "Failed to hold kubeadm kubelet kubectl!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "Successfuly hold kubeadm kubelet kubectl............"
exec 1>>log.out 2>&1
#Install Kubernetes master 03
kubeadm join $vip:6443 --token $token --discovery-token-ca-cert-hash sha256:$sha256 --control-plane --certificate-key $certkey
if [ "$?" -ne 0 ]; then 
echo "Failed to setup Kubernetes cluster!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "Successfuly completed Kubernetes $km3name cluster setup................"
exec 1>>log.out 2>&1
docker run -v /etc/kubernetes/admin.conf:/etc/kubernetes/admin.conf --network host --rm plndr/kube-vip:0.1.5 kubeadm join --interface $enp --vip $vip --startAsLeader=false | tee /etc/kubernetes/manifests/vip.yaml
if [ "$?" -ne 0 ]; then 
echo "Failed to setup VIP interface!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "Successfuly created VIP interface.............."
echo
echo "##############################################################################################"
echo "################################# Kubernetes Cluster #########################################"
echo "################################ Successfully Created ########################################"
echo "#################################### On $km3name #############################################"
echo "##############################################################################################"
echo
