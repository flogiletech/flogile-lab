#!/bin/bash
#./preinstall.sh hostanme 2>&1 | tee presinstall.log
APPHOSTNAME=$1
VALIDATEIP=10.10.85.197
log()
{
   echo "`date +'%D %T'` : $1"
}
track_error()
{
   if [ $1 != "0" ]; then
        log "$2 exited with error code $1"
        log "completed execution IN ERROR at `date`"
        exit $1
   else
        log "$2 success"
   fi
}
general_setting()
{
    systemctl stop ufw
    systemctl disable ufw
    track_error $? "ufw disable"
    swapoff -a
    track_error $? "swap disable"
    sed -i '/swap/d' /etc/fstab
    track_error $? "swap entry removal"
    if [ -n "$(grep $VALIDATEIP /etc/hosts)" ];
    then
        log "host entry already exist"
    else
        cat hostconf >>/etc/hosts
        track_error $? "Network conf"
    fi
}
install_haenv()
{
   apt update
   track_error $? "apt update"
   apt install -y vrrpd keepalived docker.io  curl
   track_error $? "apt install vrrpd keepalived docker.io  curl"
   systemctl stop keepalived
   track_error $? "keepalive stop"
   systemctl disable keepalived
   track_error $? "keepalive disable"
   systemctl start docker
   track_error $? "docker start"
   systemctl enable docker
   track_error $? "docker enable"
}
install_kubernetes()
{
   curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add
   track_error $? "kube key add"
   apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
   track_error $? "Kube Repo Addition" 
   apt update
   track_error $? "apt update"   
   apt install -y kubeadm=1.18.5-00 kubelet=1.18.5-00 kubectl=1.18.5-00
   track_error $? "kube install"   
   apt-mark hold kubeadm kubelet kubectl
   track_error $? "kube install"    
}
main()
{
    if [ -z $APPHOSTNAME ];
    then
      log "No hostanme provided"
    else
      hostanmectl set-hostname $APPHOSTNAME
    fi
    general_setting
    install_haenv
    install_kubernetes
}
main
