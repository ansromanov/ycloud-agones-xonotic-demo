#!/usr/bin/env bash
set -euxo pipefail

CLUSTER_NAME="flyaway-xonotic-k8s-cluster"
AGONES_RELEASE="1.22.0"

yc managed-kubernetes cluster get-credentials ${CLUSTER_NAME} --external --force

kubectl apply -f https://raw.githubusercontent.com/googleforgames/agones/release-${AGONES_RELEASE}/examples/xonotic/gameserver.yaml

kubectl get gameservers