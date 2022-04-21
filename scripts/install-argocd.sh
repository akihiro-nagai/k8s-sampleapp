#!/bin/bash

ARGOCD_VERSION='stable'
ARGOCD_VERSION='v2.1.3'

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml
