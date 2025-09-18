#!/bin/bash

# Script to inject TOC folding JavaScript into generated HTML files

HTML_OUTPUT_DIR="docs"

# Function to inject JavaScript into an HTML file
inject_js() {
    local html_file="$1"
    local js_path="$2"

    if [ -f "$html_file" ]; then
        echo "Injecting TOC JavaScript into $html_file..."

        # Create the script tag
        local script_tag="<script src=\"$js_path\"></script>"

        # Insert before closing </body> tag
        sed -i "s|</body>|$script_tag\n</body>|" "$html_file"
    fi
}

# Main index
if [ -f "$HTML_OUTPUT_DIR/index.html" ]; then
    inject_js "$HTML_OUTPUT_DIR/index.html" "assets/js/toc-fold.js"
fi

# Single page version
if [ -f "$HTML_OUTPUT_DIR/index-single.html" ]; then
    inject_js "$HTML_OUTPUT_DIR/index-single.html" "assets/js/toc-fold.js"
fi

# Operator docs
if [ -f "$HTML_OUTPUT_DIR/operator/index.html" ]; then
    inject_js "$HTML_OUTPUT_DIR/operator/index.html" "assets/js/toc-fold.js"
fi

# Developer docs
if [ -f "$HTML_OUTPUT_DIR/developer/index.html" ]; then
    inject_js "$HTML_OUTPUT_DIR/developer/index.html" "assets/js/toc-fold.js"
fi

# Reference docs
if [ -f "$HTML_OUTPUT_DIR/reference/modules/index.html" ]; then
    inject_js "$HTML_OUTPUT_DIR/reference/modules/index.html" "assets/js/toc-fold.js"
fi

if [ -f "$HTML_OUTPUT_DIR/reference/roles/index.html" ]; then
    inject_js "$HTML_OUTPUT_DIR/reference/roles/index.html" "assets/js/toc-fold.js"
fi

echo "JavaScript injection completed."