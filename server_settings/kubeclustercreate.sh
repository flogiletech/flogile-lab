#!/bin/bash
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
setup_configuration()
{
   mkdir -p $HOME/.kube
   cp -vf /etc/kubernetes/admin.conf $HOME/.kube/config
   chown $(id -u):$(id -g) $HOME/.kube/config
}
install_dependent()
{  
   apt install -y nfs-common
   track_error $? "nfs-common installation" 
   rm /lib/systemd/system/nfs-common.service
   systemctl daemon-reload
   systemctl start nfs-common
   track_error $? "nfs-common start"
   systemctl status nfs-common
}
install_masterdependent()
{
   snap install helm --classic
   track_error $? "Helm installation"
}
master_create()
{
  if [ -z $KUBE_VIP ] || [ -z $KUBE_PODCIDR ] ;
  then
     log "missing data for KUBE_VIP and KUBE_PODCIDR"
     usage
     exit 1
  fi
   kubeadm init --kubernetes-version 1.18.5 --control-plane-endpoint $KUBE_VIP --upload-certs --pod-network-cidr=$KUBE_PODCIDR/24
   track_error $? "Kube master initialisation" 
   setup_configuration
   kubectl create -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml
   track_error $? "Calico" 
   kubectl get nodes
   install_masterdependent
   install_dependent
}
replicamaster_create()
{
   if [ -z $KUBE_VIP ] || [ -z $KUBE_TOKEN ] || [ -z $KUBE_SHA256 ] || [ -z $KUBE_CERTKEY ] ;
   then
     log "Missing KUBE_VIP KUBE_TOKEN KUBE_SHA256 KUBE_CERTKEY"
     exit 1
   fi
   kubeadm join $KUBE_VIP:6443 --token $KUBE_TOKEN --discovery-token-ca-cert-hash sha256:$KUBE_SHA256 --control-plane --certificate-key $KUBE_CERTKEY
   track_error $? "Kube replica initialisation" 
   setup_configuration
   kubectl get nodes
   install_masterdependent
   install_dependent
}
apply_configuration()
{
   mkdir -p /etc/keepalived
   mkdir -p /etc/haproxy
   mkdir -p /etc/kubernetes/manifests
   cp -f $servername/keepalived.conf /etc/keepalived/keepalived.conf
   cp -f common/check_apiserver.sh /etc/keepalived/check_apiserver.sh
   cp -f common/haproxy.cfg /etc/haproxy/haproxy.cfg
   cp -f common/keepalived.yaml /etc/kubernetes/manifests/keepalived.yaml
   cp -f common/haproxy.yaml /etc/kubernetes/manifests/haproxy.yaml
}
create_node()
{
   if [ -z $KUBE_VIP ] || [ -z $KUBE_TOKEN ] || [ -z $KUBE_SHA256 ] ;
   then
     log "Missing KUBE_VIP KUBE_TOKEN KUBE_SHA256"
     exit 1
   fi
   kubeadm join $KUBE_VIP:6443 --token $KUBE_TOKEN --discovery-token-ca-cert-hash sha256:$KUBE_SHA256
   track_error $? "Kube replica initialisation"
   install_dependent

}
if [ -e kubeconf ];
then
	source kubeconf
else
   log "provide conf file"
	exit 1
fi

if [ "$servername" = "master1" ] || [ "$servername" = "master2" ] || [ "$servername" = "master3" ] || [ "$servername" = "node" ] ;
then 
   if [ "$servername" = "node" ];	
   then
      log "setting not  needed"
   else	   
      apply_configuration
   fi	   
else 
   log "please provide proper value to the code"
   exit 1
fi

if [ "$servername" = "master1" ];
then 
   master_create
else 
   if [ "$servername" = "node" ];
   then
     create_node
   else
     replicamaster_create
   fi
   
fi

