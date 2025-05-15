#!/bin/bash

SRC_DIR="src/html/content"
OUT_DIR="public/html/content"

# Convert all .md files in SRC_DIR to .html in OUT_DIR with same structure
find "$SRC_DIR" -type f -name '*.md' | while read -r file; do
    # Strip src prefix
    relative_path="${file#$SRC_DIR/}"
    
    # Change extension to .html
    out_path="${relative_path%.md}.html"
    
    # Construct full output path
    full_out_path="$OUT_DIR/$out_path"

    # Make sure the output directory exists
    mkdir -p "$(dirname "$full_out_path")"

    # Convert with pandoc
    
    pandoc "$file" -f markdown -t html -o - | tidy -indent -quiet -wrap 0 -o "$full_out_path" 2>/dev/null

    echo "Converted: $file → $full_out_path"
done

