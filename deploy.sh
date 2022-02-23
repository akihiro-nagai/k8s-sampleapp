#!/bin/bash
cd $(dirname $0)

kustomize build ./sample-app/overlays/dev | kubectl apply -f -
