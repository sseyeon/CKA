#!/bin/bash
# =============================================
# Master 노드 전용 설정 스크립트
# =============================================

set -e

echo "=============================="
echo " [1/4] Master IP 확인"
echo "=============================="
MASTER_IP=$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
echo "Master IP: $MASTER_IP"

echo "=============================="
echo " [2/4] kubeadm init"
echo "=============================="
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address=$MASTER_IP

echo "=============================="
echo " [3/4] kubectl 설정"
echo "=============================="
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "=============================="
echo " [4/4] Flannel 네트워크 플러그인 설치"
echo "=============================="
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

echo ""
echo "Master 설정 완료"
echo ""
echo "=============================="
echo " Worker 노드 join 명령어"
echo "=============================="
kubeadm token create --print-join-command