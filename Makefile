# OS Migrate AsciiDoc Documentation Makefile

# Tools
ASCIIDOCTOR = asciidoctor

# Source and output directories
SRC_DIR = .
HTML_OUTPUT_DIR = docs
IMAGE_SRC_DIR = images

# Main document
MAIN_DOC = index.adoc

# AsciiDoc options
ASCIIDOC_OPTS = -a toc=left -a toclevels=3 -a sectlinks -a sectanchors -a icons=font -a source-highlighter=rouge

.PHONY: all html clean help

all: html

html: $(HTML_OUTPUT_DIR)/index.html

$(HTML_OUTPUT_DIR)/index.html: $(MAIN_DOC) $(wildcard **/*.adoc)
	@echo "Building single-page HTML documentation..."
	@mkdir -p $(HTML_OUTPUT_DIR)
	@mkdir -p $(HTML_OUTPUT_DIR)/images
	@echo "Copying images..."
	@cp -r $(IMAGE_SRC_DIR)/*.svg $(HTML_OUTPUT_DIR)/images/ 2>/dev/null || true
	$(ASCIIDOCTOR) $(ASCIIDOC_OPTS) -D $(HTML_OUTPUT_DIR) $(MAIN_DOC)

clean:
	@echo "Cleaning build directories..."
	rm -rf $(HTML_OUTPUT_DIR)

help:
	@echo "Available targets:"
	@echo "  all         - Build HTML documentation"
	@echo "  html        - Build HTML documentation"
	@echo "  clean       - Remove build directory"
	@echo "  help        - Show this help message"
