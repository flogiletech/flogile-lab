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
#master servers IP
#ip4=$(/sbin/ip -o -4 addr list enp0s3 | awk '{print $4}' | cut -d/ -f1)

vip=192.168.0.201
enp=enp0s3
sha256="d5f7749ac41605535e6a95953c4476eb80dcd69f351a4c864591a486d42dc5a0"
certkey="a44ce5b257bd59b1f72223051e7475d32003b2b431e5c4129f7ab113e64fdedf"
token="6p1cku.7xuoojfxn544qjbx"
km1ip=192.168.0.131
km2ip=192.168.0.132
km3ip=192.168.0.133
kn1ip=192.168.0.134
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
hostnamectl set-hostname $km2name
ufw disable
swapoff -a
sed -i '/swap/d' /etc/fstab
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward       = 1
EOF
sysctl --system
apt-get install docker.io -y 
systemctl enable docker
systemctl start docker
apt-get install curl -y
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
apt update
apt install -y kubeadm=1.18.5-00 kubelet=1.18.5-00 kubectl=1.18.5-00
apt-mark hold kubeadm kubelet kubectl
#Install Kubernetes master 02
kubeadm join $vip:6443 --token $token --discovery-token-ca-cert-hash sha256:$sha256 --control-plane --certificate-key $certkey
docker run -v /etc/kubernetes/admin.conf:/etc/kubernetes/admin.conf --network host --rm plndr/kube-vip:0.1.5 kubeadm join --interface $enp --vip $vip --startAsLeader=false | tee /etc/kubernetes/manifests/vip.yaml

