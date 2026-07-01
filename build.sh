#!/bin/bash
set -e
shopt -s nullglob 
SRC="src"
PUBLIC="public"
if [ -d "$PUBLIC" ]; then
	echo "Clearing public/"
	rm -rf $PUBLIC
fi
echo "Starting build..."
for toplevel in js portal posts projects side-ventures; do
	mkdir -p $PUBLIC/$toplevel/
done
echo "Compiling SASS..."
npx sass "$SRC/sass/main.scss" "$PUBLIC/css/main.css" --no-source-map
GHRepo="https://www.github.com/somayyah/content.git"
TMP_REPO="/tmp/content-repo"
if [ -d "$TMP_REPO" ]; then
	echo "Updating existing content repository"
	cd "$TMP_REPO" && git pull && cd -
else
	echo "Cloning content repository"
	git clone "$GHRepo" "$TMP_REPO"
fi
echo "Compiling Pug templates..."
for i in side-ventures portal posts projects; do
	# Process MD files into HTML via Pug
	for file in "${TMP_REPO}"/"${i}"/*; do
		DEST="${PUBLIC}/${i}/"
		node MD2HTML.js "${file}" "${DEST}"
	done
done
# Render main pages
npx pug "$SRC/index.pug" --pretty --out "$PUBLIC"
npx pug "$SRC/404.pug" --pretty --out "$PUBLIC"

# Generate category listings
node build.js

echo "Copying JS..."
if [ "$(find "$SRC/js" -maxdepth 1 -name '*.js' | head -n 1)" ]; then
  cp "$SRC/js"/*.js "$PUBLIC/js/"
fi
cp "$SRC/index.js" "$PUBLIC/"
echo "Copying assets..."
rsync -a "$SRC/assets/" "$PUBLIC/assets/"
echo "Build complete!"
python3 -m http.server 8000 -d public/
