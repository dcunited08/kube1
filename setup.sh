#!/usr/bin/env bash

# Taken from https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/
# start with fresh CentOS 7

firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --zone=public --permanent --add-port=6443/tcp
firewall-cmd --zone=public --permanent --add-port=2379-2380/tcp
firewall-cmd --zone=public --permanent --add-port=10250-10255/tcp

sudo firewall-cmd --reload

yum -y update

yum install -y docker
systemctl enable docker && systemctl start docker

cat << EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
swapoff -a
setenforce 0
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system


kubeadm init --pod-network-cidr=192.168.0.0/16
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml

# kubeadm join --token 77f384.beb0f9cf7781aba9 192.168.24.42:6443 --discovery-token-ca-cert-hash sha256:9b8e6be2b3a6be2d2a1e88ef1406dd2c463dd55358a36b822415f7fa2702d061

kubectl get pods --all-namespaces

kubectl taint nodes --all node-role.kubernetes.io/master-