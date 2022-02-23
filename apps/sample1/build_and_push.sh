#!/bin/bash
cd $(dirname $0)

if [[ $# != 1 ]]; then
  echo "Usage: $0 <new_tag>"
  exit 1
fi

NEW_TAG=$1
GCR_IMAGE_NAME='us-central1-docker.pkg.dev/maugram-dev/sampleapp1/sampleapp1'

docker build -t ${GCR_IMAGE_NAME}:${NEW_TAG} .
docker push ${GCR_IMAGE_NAME}:${NEW_TAG}
