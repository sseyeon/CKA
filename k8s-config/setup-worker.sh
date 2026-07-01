#!/bin/bash
# =============================================
# Worker 노드 전용 설정 스크립트
# 사용법: sudo bash setup-worker.sh <join 명령어>
# 예시: sudo bash setup-worker.sh "kubeadm join 192.168.x.x:6443 --token xxx --discovery-token-ca-cert-hash sha256:xxx"
# =============================================

set -e

if [ -z "$1" ]; then
  echo "join 명령어를 입력해주세요!"
  echo "사용법: sudo bash setup-worker.sh \"kubeadm join 192.168.x.x:6443 --token xxx --discovery-token-ca-cert-hash sha256:xxx\""
  exit 1
fi

echo "=============================="
echo " Worker 노드 클러스터 Join"
echo "=============================="
sudo $1

echo ""
echo "Worker 설정 완료"
echo "Master에서 kubectl get nodes 로 확인하세요"