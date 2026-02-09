#!/bin/bash
set -e

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "usage: ./deploy.sh v1|v2|v3"
  exit 1
fi

APP_DIR=/opt/app
RELEASE_DIR=$APP_DIR/releases/$VERSION
REPO_DIR=$HOME/repo/backend

echo "creating release $VERSION..."

mkdir -p $RELEASE_DIR

cp -r $REPO_DIR/* $RELEASE_DIR/

cd $RELEASE_DIR
npm install --production

echo "switching to $VERSION..."
ln -sfn $RELEASE_DIR $APP_DIR/current

echo "restarting app..."
pkill node || true
cd $APP_DIR/current
PORT=5000 node src/server.js &

echo "deployment complete: $VERSION live"
