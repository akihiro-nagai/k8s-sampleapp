#!/bin/bash
cd $(dirname $0)

kustomize build ./k8s/sample-app/overlays/dev | kubectl apply -f -
