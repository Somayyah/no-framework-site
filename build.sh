#!/bin/bash

# Compile Pug to HTML
pug src/html/index.pug --out dist

# Compile SASS to CSS
bun run sass src/css/main.scss dist/style.css
