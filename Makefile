# OS Migrate AsciiDoc Documentation Makefile

# Tools
ASCIIDOCTOR = asciidoctor
ASCIIDOCTOR_PDF = asciidoctor-pdf

# Source and output directories
SRC_DIR = .
HTML_OUTPUT_DIR = docs
PDF_OUTPUT_DIR = pdf
IMAGE_SRC_DIR = images

# Main document
MAIN_DOC = index.adoc

# AsciiDoc options
ASCIIDOC_OPTS = -a toc=left -a toclevels=3 -a sectlinks -a sectanchors -a icons=font -a source-highlighter=rouge
ASCIIDOC_BOOK_OPTS = -a toc=left -a toclevels=3 -a sectlinks -a sectanchors -a icons=font -a source-highlighter=rouge -a doctype=book

.PHONY: all html pdf clean help

all: html pdf

html: $(HTML_OUTPUT_DIR)/index.html

$(HTML_OUTPUT_DIR)/index.html: $(MAIN_DOC) $(wildcard **/*.adoc)
	@echo "Building single-page HTML documentation..."
	@mkdir -p $(HTML_OUTPUT_DIR)
	@mkdir -p $(HTML_OUTPUT_DIR)/images
	@echo "Copying images..."
	@cp -r $(IMAGE_SRC_DIR)/*.svg $(HTML_OUTPUT_DIR)/images/ 2>/dev/null || true
	$(ASCIIDOCTOR) $(ASCIIDOC_OPTS) -D $(HTML_OUTPUT_DIR) $(MAIN_DOC)

pdf: $(PDF_OUTPUT_DIR)/index.pdf

$(PDF_OUTPUT_DIR)/index.pdf: $(MAIN_DOC) $(wildcard **/*.adoc)
	@echo "Building PDF documentation..."
	@mkdir -p $(PDF_OUTPUT_DIR)
	@mkdir -p $(PDF_OUTPUT_DIR)/images
	@echo "Copying images for PDF..."
	@cp -r $(IMAGE_SRC_DIR)/*.svg $(PDF_OUTPUT_DIR)/images/ 2>/dev/null || true
	$(ASCIIDOCTOR_PDF) $(ASCIIDOC_OPTS) -D $(PDF_OUTPUT_DIR) $(MAIN_DOC)

clean:
	@echo "Cleaning build directories..."
	rm -rf $(HTML_OUTPUT_DIR) $(PDF_OUTPUT_DIR)

help:
	@echo "Available targets:"
	@echo "  all         - Build both HTML and PDF documentation"
	@echo "  html        - Build single-page HTML documentation"
	@echo "  pdf         - Build PDF documentation"
	@echo "  clean       - Remove build directories"
	@echo "  help        - Show this help message"
