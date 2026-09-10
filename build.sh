#!/bin/bash
set -e

echo "=== Starting Flutter Web Build ==="

if command -v flutter > /dev/null 2>&1; then
  echo "Flutter command found in PATH."
  flutter build web --release
else
  echo "Flutter command not found. Cloning Flutter stable SDK..."
  if [ ! -d "_flutter" ]; then
    git clone -b stable --depth 1 https://github.com/flutter/flutter.git _flutter
  fi
  export PATH="$PATH:$(pwd)/_flutter/bin"
  flutter config --no-analytics
  flutter build web --release
fi

echo "Setting up output for static web hosting..."
rm -rf public
mkdir -p public
cp -R build/web/* public/

echo "=== Build finished successfully ==="
