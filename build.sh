#!/bin/bash

set -e

echo "Starting build..."

SRC="src"
PUBLIC="public"

echo "Compiling SASS..."
sass "$SRC/sass/main.scss" "$PUBLIC/css/main.css" --no-source-map

echo "Compiling Pug templates..."
pug "$SRC/html" --pretty --out "$PUBLIC/html"
pug "$SRC/index.pug" --pretty --out "$PUBLIC/index.html"

echo "Copying JS..."
mkdir -p "$PUBLIC/js"
cp "$SRC/js/"*.js "$PUBLIC/js/"

echo "Copying assets..."
rsync -a "$SRC/assets/" "$PUBLIC/assets/"

echo "Build complete!"

