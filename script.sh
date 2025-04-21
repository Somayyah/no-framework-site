#!/bin/bash

# Step 1: Set up the directories
mkdir -p src/assets src/css src/html src/js dist

# Step 2: Create main SASS files
echo "// main.scss - Entry point for all your styles" > src/css/main.scss
echo "// _variables.scss - Define your variables, mixins, etc." > src/css/_variables.scss

# Step 3: Create the Pug files
echo "doctype html
html(lang='en')
  head
    title My Website
    link(rel='stylesheet', href='style.css')
  body
    header
      h1 Welcome to My Website
    section
      p This is the homepage.
    footer
      p Copyright 2025" > src/html/index.pug

echo "doctype html
html(lang='en')
  head
    title My Website
    link(rel='stylesheet', href='/style.css')
  body
    block content" > src/html/layout.pug

# Step 4: Create a basic JS file (empty for now)
echo "// main.js - If you ever need to add JavaScript" > src/js/main.js

# Step 5: Initialize Bun
bun init

# Step 6: Install necessary packages (e.g., Pug compiler, SASS)
bun add pug-cli sass

# Step 7: Add a basic build script
echo "#!/bin/bash

# Compile Pug to HTML
pug src/html/index.pug --out dist

# Compile SASS to CSS
sass src/css/main.scss dist/style.css" > build.sh
chmod +x build.sh

echo "Project setup complete! Run './build.sh' to compile your assets."

