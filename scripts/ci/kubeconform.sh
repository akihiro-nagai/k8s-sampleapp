#!/bin/bash
set -u -o pipefail

K8S_VERSION='1.23.14'

function validate() {
  local env=${1}

  kustomize build k8s/sample-app/overlays/${env} | \
    kubeconform \
    -kubernetes-version=${K8S_VERSION} \
    -schema-location=default \
    -schema-location='https://raw.githubusercontent.com/istio/api/master/kubernetes/customresourcedefinitions.gen.yaml' \
    -schema-location='https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
    -strict
}

for env in dev; do
  echo "----- k8s yaml validation for ${env} -----"
  validate ${env}
done
