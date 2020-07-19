#!/bin/sh
apphostname=""
sha256=""
token=""
vip=10.10.73.68
echo "Kubernetes Cluster installation is in Progress...."
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
echo "updating Etc/hosts.."
cat hostconf >>/etc/hosts
echo "Setting hostname.."
hostnamectl set-hostname $apphostname
if [ "$?" -ne 0 ]; then
echo "failed to set hostname!!!"
    exit 1
fi
echo "Disabling ufw!!"
ufw disable
if [ "$?" -ne 0 ]; then
echo "Failed to Disabled ufw!!"
    exit 1
fi
echo "Disabled ufw..."
echo "disabling swap"
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
echo "Removed swap entry....."
echo "updating network configuration..."
cat networkconf >/etc/sysctl.d/kubernetes.conf
sysctl --system
if [ "$?" -ne 0 ]; then
echo "Failed to update network config!!"
    exit 1
fi
echo "Running system update "
apt-get update -y
if [ "$?" -ne 0 ]; then
echo "Failed to system update!!"
    exit 1
fi
echo "Installing docker......"
apt-get install docker.io -y
if [ "$?" -ne 0 ]; then
echo "Failed to installed docker!!"
    exit 1
fi
echo "Successfuly installed docker......"
echo "Enabling docker......."
systemctl enable docker
if [ "$?" -ne 0 ]; then
echo "Failed to Enable docker!!"
    exit 1
fi
echo "Successfuly enabled docker......."
echo "Starting docker......."
systemctl start docker
if [ "$?" -ne 0 ]; then
echo "Failed to started docker!!"
    exit 1
fi
echo "Successfuly started docker........"
echo "updating curl...."
apt-get install curl -y
if [ "$?" -ne 0 ]; then
echo "Failed to installed curl!!"
    exit 1
fi
echo "Successfuly installed curl........."
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
if [ "$?" -ne 0 ]; then
echo "Failed to add apt-key!!"
    exit 1
fi
echo "Successfuly add apt-key.........."
echo "Adding kube repository..."
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
if [ "$?" -ne 0 ]; then
echo "Failed to add kube repo!!"
    exit 1
fi
echo "Successfuly add kube repo..........."
echo "Installing Kubernetes..."
apt install -y kubeadm=1.18.5-00 kubelet=1.18.5-00 kubectl=1.18.5-00
if [ "$?" -ne 0 ]; then
echo "Failed to install kubeadm kubelet kubectl!!"
    exit 1
fi
echo "Waiting to complete the process kube install..."
apt-mark hold kubeadm kubelet kubectl
if [ "$?" -ne 0 ]; then
echo "Failed to hold kubeadm kubelet kubectl!!"
    exit 1
fi
echo "Successfuly installed kubeadm kubelet kubectl............"

exec 1>>log.out 2>&1
#Install Kubernetes node 01
kubeadm join $vip:6443 --token $token --discovery-token-ca-cert-hash sha256:$sha256
if [ "$?" -ne 0 ]; then
echo "Failed to add Kubernetes worker node!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "Successfuly completed Kubernetes $apphostname cluster setup................"
echo
echo "##############################################################################################"
echo "################################# Kubernetes Cluster #########################################"
echo "################################ Successfully Created ########################################"
echo "#################################### On $apphostname #############################################"
echo "##############################################################################################"

