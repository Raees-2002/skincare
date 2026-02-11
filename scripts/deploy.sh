#!/bin/bash
set -e

VERSION=$1

APP_DIR=/opt/app
RELEASES_DIR=$APP_DIR/releases
RELEASE_DIR=$RELEASES_DIR/$VERSION
CURRENT_LINK=$APP_DIR/current
ARTIFACT=/tmp/app.tar.gz

TEST_PORT=6000

OLD_VERSION=$(basename "$(readlink -f $CURRENT_LINK 2>/dev/null || echo none)")

echo "=============================="
echo "starting deployment: $VERSION"
echo "current version: $OLD_VERSION"
echo "=============================="

mkdir -p "$RELEASE_DIR"

echo "extracting artifact..."
tar -xzf $ARTIFACT -C "$RELEASE_DIR"

cd "$RELEASE_DIR"

echo "starting test instance on port $TEST_PORT..."
PORT=$TEST_PORT VERSION=$VERSION node src/server.js &
PID=$!

sleep 5

echo "running health check..."

if curl -fs http://localhost:$TEST_PORT/health > /dev/null; then
  echo "health passed"

  kill $PID

  echo "switching traffic to $VERSION"
  ln -sfn "$RELEASE_DIR" "$CURRENT_LINK"

  pm2 reload skincare || pm2 start src/server.js --name skincare

  echo "deployment successful"
  echo "active version: $(basename "$(readlink -f $CURRENT_LINK)")"
  echo "=============================="
  exit 0

else
  echo "health failed"
  echo "rolling back to $OLD_VERSION"

  kill $PID
  rm -rf "$RELEASE_DIR"

  echo "rollback complete"
  echo "still running: $OLD_VERSION"
  echo "=============================="
  exit 1
fi
