#disable firewall#disable firewall
sudo ufw disable
#disable swap
sudo swapoff -a; sed -i '/swap/d' /etc/fstab
#sysctl settings update for K8s networking
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
#Docker installation
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
# Docker daemon.jeson
sudo cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl stop docker.socket
sudo systemctl start docker.socket
#updating the ubuntu
sudo apt update
#Adding K8s Repo
sudo apt -y install curl apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
#K8s package installation
sudo apt-get install kubelet=1.23.15-00 kubeadm=1.23.15-00 kubectl=1.23.15-00 -y --allow-change-held-packages

echo '-----------'
sudo kubeadm version