#!/bin/bash
set -e

VERSION=$1

APP_DIR=/opt/app
RELEASE_DIR=$APP_DIR/releases/$VERSION
REPO_DIR=$(cd "$(dirname "$0")/../backend" && pwd)

TEST_PORT=6000

echo "creating release $VERSION..."
mkdir -p "$RELEASE_DIR"
cp -r "$REPO_DIR"/* "$RELEASE_DIR"

cd "$RELEASE_DIR"
npm install --production

echo "starting test instance..."
PORT=$TEST_PORT VERSION=$VERSION node src/server.js &
PID=$!

sleep 5

echo "checking health..."

if curl -fs http://localhost:$TEST_PORT/health > /dev/null; then
  echo "health passed"

  kill $PID

  ln -sfn "$RELEASE_DIR" "$APP_DIR/current"

  echo "restarting service"
  sudo systemctl restart skincare

  echo "deployment successful"
else
  echo "health failed — rollback"
  kill $PID
  rm -rf "$RELEASE_DIR"
  exit 1
fi
