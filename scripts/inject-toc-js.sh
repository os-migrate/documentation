#!/bin/bash

# Script to inject TOC folding CSS and JavaScript into generated HTML files

HTML_OUTPUT_DIR="docs"

# Function to inject CSS and JavaScript into an HTML file
inject_toc_assets() {
    local html_file="$1"
    local css_path="$2"
    local js_path="$3"

    if [ -f "$html_file" ]; then
        echo "Injecting TOC assets into $html_file..."

        # Create the CSS link tag
        local css_tag="<link rel=\"stylesheet\" href=\"$css_path\">"

        # Create the script tag
        local script_tag="<script src=\"$js_path\"></script>"

        # Insert CSS before closing </head> tag
        sed -i "s|</head>|$css_tag\n</head>|" "$html_file"

        # Insert JavaScript before closing </body> tag
        sed -i "s|</body>|$script_tag\n</body>|" "$html_file"
    fi
}

# Main index
if [ -f "$HTML_OUTPUT_DIR/index.html" ]; then
    inject_toc_assets "$HTML_OUTPUT_DIR/index.html" "assets/css/toc-fold.css" "assets/js/toc-fold.js"
fi

# Single page version
if [ -f "$HTML_OUTPUT_DIR/index-single.html" ]; then
    inject_toc_assets "$HTML_OUTPUT_DIR/index-single.html" "assets/css/toc-fold.css" "assets/js/toc-fold.js"
fi

# Operator docs
if [ -f "$HTML_OUTPUT_DIR/operator/index.html" ]; then
    inject_toc_assets "$HTML_OUTPUT_DIR/operator/index.html" "../assets/css/toc-fold.css" "../assets/js/toc-fold.js"
fi

# Developer docs
if [ -f "$HTML_OUTPUT_DIR/developer/index.html" ]; then
    inject_toc_assets "$HTML_OUTPUT_DIR/developer/index.html" "../assets/css/toc-fold.css" "../assets/js/toc-fold.js"
fi

# Reference docs
if [ -f "$HTML_OUTPUT_DIR/reference/modules/index.html" ]; then
    inject_toc_assets "$HTML_OUTPUT_DIR/reference/modules/index.html" "../../assets/css/toc-fold.css" "../../assets/js/toc-fold.js"
fi

if [ -f "$HTML_OUTPUT_DIR/reference/roles/index.html" ]; then
    inject_toc_assets "$HTML_OUTPUT_DIR/reference/roles/index.html" "../../assets/css/toc-fold.css" "../../assets/js/toc-fold.js"
fi

echo "JavaScript injection completed."