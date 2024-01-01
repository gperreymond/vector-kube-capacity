#!/bin/bash
set -e

echo "[INFO] start application"

echo "[INFO] [1/3] check kube-capacity"
kube-capacity version

echo "[INFO] [2/3] check vector"
vector --version

echo "[INFO] [3/3] check kubectl"
kubectl version --client=true --short

/usr/app/bin/vector --config-dir /usr/app/vector