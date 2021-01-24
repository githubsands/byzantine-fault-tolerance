#!/bin/bash

set -e

log() {
    echo "LOG - $(date) - centos-harnes: $1"
}

SEEDNODEDIR=$(pwd)/seed-node

if [ "$1" = "--start" ]; then
    log "start input, creating a minikube"
    CLUSTER=$(minikube status)
    STATUS=$?
    if [ "$STATUS" -lt 1 ]; then
      log "existing minikube detected";
      minikube delete
    else
      log "starting a new minikube";
    fi

fi

minikube start --memory 1500
eval $(minikube -p minikube docker-env)

log "building tendermint docker image"
docker build -t tendermint-node .

log "creating namespaces"
kubectl create namespace honest_0
log "adversary_0 namespace created"
kubectl create namespace adversary_0
log "adversary_1 namespace created"
kubectl create namespace adversary_1
log "downloading tendermint file"
wget https://raw.githubusercontent.com/tendermint/tendermint/master/DOCKER/Dockerfile
wget https://raw.githubusercontent.com/tendermint/tendermint/master/DOCKER/docker-entrypoint.sh
log "building tendermint image"
docker build -t tendermint-node .
sleep 5s

log "pointing kubectl to honest_0"
kubectl config set-context --current --namespace=honest_0
log "applying containers to honest_0"
kubectl apply -f tendermint-deployment-honest_0.yaml

log "pointing kubectl to adversary_0"
kubectl config set-context --current --namespace=adversary_0
log "applying containers to adversary_0"
kubectl apply -f tendermint-deployment-1.yaml

log "pointing kubectl to adversary_1"
kubectl config set-context --current --namespace=adversary_1
log "applying containers to adversary_1"
kubectl apply -f tendermint-deployment-2.yaml
