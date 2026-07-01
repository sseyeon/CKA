#!/bin/bash
# =============================================
# 공통 설정 스크립트 (master, worker1, worker2)
# =============================================

set -e  # 에러나면 즉시 종료

echo "=============================="
echo " [1/5] 스왑 비활성화"
echo "=============================="
sudo swapoff -a

echo "=============================="
echo " [2/5] 커널 모듈 설정"
echo "=============================="
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

echo "=============================="
echo " [3/5] 네트워크 설정"
echo "=============================="
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

echo "=============================="
echo " [4/5] containerd 설치 및 설정"
echo "=============================="
sudo apt-get update
sudo apt-get install -y containerd

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

echo "=============================="
echo " [5/5] kubeadm, kubelet, kubectl 설치"
echo "=============================="
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo ""
echo "공통 설정 완료"
echo "kubeadm version: $(kubeadm version --output short)"