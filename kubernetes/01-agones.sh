#!/usr/bin/env bash
set -euxo pipefail

CLUSTER_NAME="flyaway-xonotic-k8s-cluster"
AGONES_NAMESPACE="agones-system"
AGONES_RELEASE="1.22.0"

yc managed-kubernetes cluster get-credentials ${CLUSTER_NAME} --external --force


helm repo add agones https://agones.dev/chart/stable
helm repo update
helm upgrade -i my-release --namespace ${AGONES_NAMESPACE} --create-namespace agones/agones

helm test my-release --namespace ${AGONES_NAMESPACE} 

