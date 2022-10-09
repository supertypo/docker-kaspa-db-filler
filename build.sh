#!/bin/sh
PUSH=$1

DOCKER_REPO=supertypo/kaspa-db-filler

BUILD_DIR="$(dirname $0)"
REPO_URL="https://github.com/lAmeR1/kaspa-db-filler.git"
REPO_DIR="$BUILD_DIR/work/kaspa-db-filler"

set -e

if [ ! -d "$REPO_DIR" ]; then
  git clone "$REPO_URL" "$REPO_DIR"
  echo $(cd "$REPO_DIR" && git reset --hard HEAD~1)
fi

if $(cd "$REPO_DIR" && git pull | grep -qv "up to date"); then
  commitId=$(cd "$REPO_DIR" && git log -n1 --format="%h")
  tag=$(date -u +"%Y-%m-%d").$commitId
  echo
  echo "Git repo changed, building tag '$tag'."
  echo

  docker build --pull --build-arg REPO_DIR="$REPO_DIR" -t $DOCKER_REPO:$tag "$BUILD_DIR"
  docker tag $DOCKER_REPO:$tag $DOCKER_REPO:latest
  echo Tagged $DOCKER_REPO:latest

  if [ "$PUSH" = "push" ]; then
    docker push $DOCKER_REPO:$tag
    docker push $DOCKER_REPO:latest
  fi
else
  commitId=$(cd "$REPO_DIR" && git log -n1 --format="%h")
  echo "Git repo is still at '$commitId', skipping build."
fi

