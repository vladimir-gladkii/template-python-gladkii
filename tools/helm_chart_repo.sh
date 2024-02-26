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

  if wget -q "$REPO_INDEX_FILE" -O index.yaml; then
    echo "File ${REPO_INDEX_FILE} downloaded. Add a new release to index.yaml."
    helm repo index --merge index.yaml --url "${ARTIFACTS_URL}" "$DIR"
  elif [ $? -eq 8 ]; then
    echo "File ${REPO_INDEX_FILE} does not exist. Create new index.yaml."
    helm repo index --url "${ARTIFACTS_URL}" "$DIR"
  else
    echo "Error: File ${REPO_INDEX_FILE} is not available."
    exit 1
  fi
}

main() {
  DIR="$1"
  REPO_URL="$2"
  ARTIFACTS_URL="$3"

  generate_repo_index "$DIR" "$REPO_URL" "$ARTIFACTS_URL"
}

main "$@"
