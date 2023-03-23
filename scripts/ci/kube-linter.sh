#!/bin/bash

function lint() {
  local env=${1}

  kustomize build ./k8s/sample-app/overlays/${env} | \
    kube-linter lint \
    --config=./scripts/ci/kube-linter-config.yaml \
    -
}

for env in dev; do
  echo "----- run kube-linter for ${env} ----"
  lint ${env}
done
