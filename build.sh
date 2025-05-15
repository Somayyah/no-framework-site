#!/bin/bash

set -e  

if [[ ! -d "./public" ]]; then
    mkdir ./public
fi

echo "Cleaning public folder..."
rm -rf public/*
mkdir -p public/css public/js public/assets/fonts public/assets/images

echo "Compiling Pug templates..."
pug -w src --out public --pretty --exclude src/_partials &

echo "Compiling SASS..."
sass -w src/sass/main.scss public/css/main.css --no-source-map &

echo "Copying JS files..."
cp -r src/js/* public/js/

echo "Copying assets..."
cp -r src/assets/fonts/* public/assets/fonts/
cp -r src/assets/images/* public/assets/images/

echo "Build complete"

# python3 -m http.server 8000 -d ./public/
