#!/bin/bash
set -e

VERSION=$1

APP_DIR=/opt/app
RELEASE_DIR=$APP_DIR/releases/$VERSION
REPO_DIR=$(cd "$(dirname "$0")/../backend" && pwd)

echo "creating release $VERSION..."

mkdir -p $RELEASE_DIR
cp -r $REPO_DIR/* $RELEASE_DIR/

cd $RELEASE_DIR
npm install --production

ln -sfn $RELEASE_DIR $APP_DIR/current

sudo systemctl restart skincare

echo "deployment complete"
