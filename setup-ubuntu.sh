#!/usr/bin/env bash



apt-get update
apt-get install -y docker.io
systemctl enable docker && systemctl start docker

cat << EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl

swapoff -a

#cat <<EOF >  /etc/sysctl.d/k8s.conf
#net.bridge.bridge-nf-call-ip6tables = 1
#net.bridge.bridge-nf-call-iptables = 1
#EOF
#sysctl --system


kubeadm init --pod-network-cidr=192.168.100.0/16
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml
kubectl taint nodes --all node-role.kubernetes.io/master-

# kubeadm join --token 77f384.beb0f9cf7781aba9 192.168.24.42:6443 --discovery-token-ca-cert-hash sha256:9b8e6be2b3a6be2d2a1e88ef1406dd2c463dd55358a36b822415f7fa2702d061

kubectl get pods --all-namespaces

