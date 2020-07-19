#!/bin/sh
apphostname="crvs-master1"
vip=10.10.73.68
enp=ens32
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

# Install Kubernetes master 01
docker run --network host --rm plndr/kube-vip:0.1.5 kubeadm init --interface $enp --vip $vip --startAsLeader=true | tee /etc/kubernetes/manifests/vip.yaml
if [ "$?" -ne 0 ]; then
echo "Failed to setup VIP interface!!"
    exit 1
fi
echo "Successfuly created VIP interface.............."

exec 1>log.out 2>&1
kubeadm init --kubernetes-version 1.18.5 --control-plane-endpoint $vip --upload-certs
if [ "$?" -ne 0 ]; then
echo "Failed to setup Kubernetes cluster!!"
    exit 1
fi
exec > /dev/tty 2>&1
echo "Successfuly completed Kubernetes $apphostname cluster setup................"

echo "configuring the Kube services..."
mkdir -p $HOME/.kube
cp -vf /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "Launcing the Kubernates Netowrk setup....."
kubectl create -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml
if [ "$?" -ne 0 ]; then
echo "Failed to setup calico pod!!"
    exit 1
fi

echo "Successfuly created calico pod................."
#kubectl get pods -n kube-system
kubectl get nodes
echo
echo "##############################################################################################"
echo "################################# Kubernetes Cluster #########################################"
echo "################################ Successfully Created ########################################"
echo "#################################### On $apphostname #############################################"
echo "##############################################################################################"
echo

