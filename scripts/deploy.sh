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

echo "starting app on test port $TEST_PORT..."
PORT=$TEST_PORT node src/server.js &
TEST_PID=$!

sleep 5

echo "running health check..."
if curl -fs http://localhost:$TEST_PORT/health > /dev/null; then
  echo "health check passed"
  kill $TEST_PID

  ln -sfn "$RELEASE_DIR" "$APP_DIR/current"
  sudo systemctl restart skincare

  echo "deployment successful"
else
  echo "health check failed — rolling back"
  kill $TEST_PID
  rm -rf "$RELEASE_DIR"
  exit 1
fi
