#!/bin/bash

set -e

SRC="src"
PUBLIC="public"

if [ -d "$DIRECTORY" ]; then
	echo "Clearing public/"
	rm -rf $PUBLIC
fi

echo "Starting build..."

for toplevel in js portal posts projects side-ventures; do
	mkdir -p $PUBLIC/$toplevel/
done

echo "Compiling SASS..."
sass "$SRC/sass/main.scss" "$PUBLIC/css/main.css" --no-source-map

echo "Compiling Pug templates..."
pug "$SRC/html/content" --pretty --out "$PUBLIC/"
pug "$SRC/index.pug" --pretty --out "$PUBLIC"
pug "$SRC/404.pug" --pretty --out "$PUBLIC"

echo "Copying JS..."
if [ "$(find "$SRC/js" -maxdepth 1 -name '*.js' | head -n 1)" ]; then
  cp "$SRC/js"/*.js "$PUBLIC/js/"
fi

cp "$SRC/index.js" "$PUBLIC/"

echo "Copying assets..."
rsync -a "$SRC/assets/" "$PUBLIC/assets/"

echo "Build complete!"

## python3 -m http.server 8000 -d public/