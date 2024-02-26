#!/usr/bin/env bash

set -o errexit
set -o nounset

generate_repo_index() {
  DIR="$1"
  REPO_URL="$2"
  ARTIFACTS_URL="$3"

  REPO_INDEX_FILE="${REPO_URL}/index.yaml"

  echo "DIR: $DIR"
  echo "REPO_URL: $REPO_URL"
  echo "REPO_INDEX_FILE: $REPO_INDEX_FILE"
  echo "ARTIFACTS_URL: $ARTIFACTS_URL"

  if wget -q "$REPO_INDEX_FILE" -O old_index.yaml; then
    echo "File ${REPO_INDEX_FILE} downloaded."
  elif [ $? -eq 8 ]; then
    echo "File ${REPO_INDEX_FILE} does not exist."
  else
    echo "Error: File ${REPO_INDEX_FILE} is not available."
    exit 1
  fi

  if [ -f ./old_index.yaml ] && [ -s ./old_index.yaml ]; then
    echo "File ${REPO_INDEX_FILE} is not empty. Add new release to file."
    helm repo index --merge old_index.yaml --url "${ARTIFACTS_URL}" "$DIR"
    rm -f ./old_index.yaml
  else
    echo "File ${REPO_INDEX_FILE} does not esist or it is empty."
    helm repo index --url "${ARTIFACTS_URL}" "$DIR"
  fi
}

main() {
  DIR="$1"
  REPO_URL="$2"
  ARTIFACTS_URL="$3"

  generate_repo_index "$DIR" "$REPO_URL" "$ARTIFACTS_URL"
}

main "$@"
