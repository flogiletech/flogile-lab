#!/bin/sh
# ###################################################################### #
# This is the shell script version Created by Flogile Technlologies Ltd  #
# ---------------------------------------------------------------------  #
# "Kmaster1_setup.sh" is will setup Kubernetes master node1              #
# Author: Anand Sreenivasan (anands@flogile.com)                         #
#                                                                        #
# Version 1.0.0:   Created by Anand Sreenivasan (14-July-2020)           #
# ###################################################################### #
#Set servers IP
#ip4=$(/sbin/ip -o -4 addr list enp0s3 | awk '{print $4}' | cut -d/ -f1)
km1ip=10.10.73.72
km2ip=10.10.73.73
km3ip=10.10.73.78
kn1ip=10.10.73.86
kn2ip=10.10.73.87
kn3ip=10.10.73.88
kn4ip=10.10.73.89
kn5ip=10.10.73.90
kn6ip=10.10.73.80
kn7ip=10.10.73.81
kn8ip=10.10.73.82
nfs1ip=10.10.73.85
vip=10.10.73.68
enp=enp0s3
echo
echo "* * * *  *          * * *      * * *    *  *        * * * *"
echo "*        *        *       *  *       *  *  *        *      "
echo "*        *        *       *  *          *  *        *      "
echo "* * *    *        *       *  *          *  *        * * *  "
echo "*        *        *       *  *   * * *  *  *        *      "
echo "*        *        *       *  *       *  *  *        *      "
echo "*        * * * *    * * *      * * *    *  * * * *  * * * *"      
echo
echo "Kubernetes Cluster installation is in Progross...."
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
kn2name=knode2
kn3name=knode3
kn4name=knode4
kn5name=knode5
kn6name=knode6
kn7name=knode7
kn8name=knode8
nfs1name=nfs1
echo "Setting up Host entry..."
cat >>/etc/hosts<<EOF
$km1ip $km1name
$km2ip $km2name
$km3ip $km3name
$kn1ip $kn1name
$kn2ip $kn2name
$kn3ip $kn3name
$kn4ip $kn4name
$kn5ip $kn5name
$kn6ip $kn6name
$kn7ip $kn7name
$kn8ip $kn8name
$nfs1ip $nfs1name
EOF
apt-get update -y
hostnamectl set-hostname $km1name
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
# Install Kubernetes master 01
docker run --network host --rm plndr/kube-vip:0.1.5 kubeadm init --interface $enp --vip $vip --startAsLeader=true | tee /etc/kubernetes/manifests/vip.yaml
if [ "$?" -ne 0 ]; then 
echo "Failed to setup VIP interface!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "Successfuly created VIP interface.............."
exec 1>>log.out 2>&1
kubeadm init --kubernetes-version 1.18.5 --control-plane-endpoint $vip --upload-certs
if [ "$?" -ne 0 ]; then 
echo "Failed to setup Kubernetes cluster!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "Successfuly completed Kubernetes $km1name cluster setup................"
exec 1>>log.out 2>&1
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl create -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml
if [ "$?" -ne 0 ]; then 
echo "Failed to setup calico pod!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "Successfuly created calico pod................."
#kubectl get pods -n kube-system
kubectl get nodes
echo
echo "##############################################################################################"
echo "################################# Kubernetes Cluster #########################################"
echo "################################ Successfully Created ########################################"
echo "#################################### On $km1name #############################################"
echo "##############################################################################################"
echo

