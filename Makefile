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

.PHONY: all html html-single html-multi pdf clean help

all: html pdf

html: html-multi

html-single: $(HTML_OUTPUT_DIR)/index-single.html

$(HTML_OUTPUT_DIR)/index-single.html: $(MAIN_DOC) $(wildcard **/*.adoc)
	@echo "Building single-page HTML documentation..."
	@mkdir -p $(HTML_OUTPUT_DIR)
	@mkdir -p $(HTML_OUTPUT_DIR)/images
	@echo "Copying images..."
	@cp -r $(IMAGE_SRC_DIR)/*.svg $(HTML_OUTPUT_DIR)/images/ 2>/dev/null || true
	$(ASCIIDOCTOR) $(ASCIIDOC_OPTS) -D $(HTML_OUTPUT_DIR) $(MAIN_DOC)
	@mv $(HTML_OUTPUT_DIR)/index.html $(HTML_OUTPUT_DIR)/index-single.html

html-multi: $(HTML_OUTPUT_DIR)/index.html $(HTML_OUTPUT_DIR)/operator/index.html $(HTML_OUTPUT_DIR)/developer/index.html $(HTML_OUTPUT_DIR)/reference/modules/index.html $(HTML_OUTPUT_DIR)/reference/roles/index.html

pdf: $(PDF_OUTPUT_DIR)/index.pdf

$(HTML_OUTPUT_DIR)/index.html: index-multi.adoc
	@echo "Building main HTML page..."
	@mkdir -p $(HTML_OUTPUT_DIR)
	@mkdir -p $(HTML_OUTPUT_DIR)/images
	@echo "Copying images..."
	@cp -r $(IMAGE_SRC_DIR)/*.svg $(HTML_OUTPUT_DIR)/images/ 2>/dev/null || true
	$(ASCIIDOCTOR) $(ASCIIDOC_OPTS) -D $(HTML_OUTPUT_DIR) index-multi.adoc
	@mv $(HTML_OUTPUT_DIR)/index-multi.html $(HTML_OUTPUT_DIR)/index.html

$(HTML_OUTPUT_DIR)/operator/index.html: operator/index.adoc $(wildcard operator/*.adoc)
	@echo "Building operator documentation..."
	@mkdir -p $(HTML_OUTPUT_DIR)/operator
	@mkdir -p $(HTML_OUTPUT_DIR)/operator/images
	@cp -r $(IMAGE_SRC_DIR)/*.svg $(HTML_OUTPUT_DIR)/operator/images/ 2>/dev/null || true
	$(ASCIIDOCTOR) $(ASCIIDOC_OPTS) -D $(HTML_OUTPUT_DIR)/operator operator/index.adoc

$(HTML_OUTPUT_DIR)/developer/index.html: developer/index.adoc $(wildcard developer/*.adoc)
	@echo "Building developer documentation..."
	@mkdir -p $(HTML_OUTPUT_DIR)/developer
	@mkdir -p $(HTML_OUTPUT_DIR)/developer/images
	@cp -r $(IMAGE_SRC_DIR)/*.svg $(HTML_OUTPUT_DIR)/developer/images/ 2>/dev/null || true
	$(ASCIIDOCTOR) $(ASCIIDOC_OPTS) -D $(HTML_OUTPUT_DIR)/developer developer/index.adoc

$(HTML_OUTPUT_DIR)/reference/modules/index.html: reference/modules/index.adoc $(wildcard reference/modules/*.adoc)
	@echo "Building modules reference..."
	@mkdir -p $(HTML_OUTPUT_DIR)/reference/modules
	@mkdir -p $(HTML_OUTPUT_DIR)/reference/modules/images
	@cp -r $(IMAGE_SRC_DIR)/*.svg $(HTML_OUTPUT_DIR)/reference/modules/images/ 2>/dev/null || true
	$(ASCIIDOCTOR) $(ASCIIDOC_OPTS) -D $(HTML_OUTPUT_DIR)/reference/modules reference/modules/index.adoc

$(HTML_OUTPUT_DIR)/reference/roles/index.html: reference/roles/index.adoc $(wildcard reference/roles/*.adoc)
	@echo "Building roles reference..."
	@mkdir -p $(HTML_OUTPUT_DIR)/reference/roles
	@mkdir -p $(HTML_OUTPUT_DIR)/reference/roles/images
	@cp -r $(IMAGE_SRC_DIR)/*.svg $(HTML_OUTPUT_DIR)/reference/roles/images/ 2>/dev/null || true
	$(ASCIIDOCTOR) $(ASCIIDOC_OPTS) -D $(HTML_OUTPUT_DIR)/reference/roles reference/roles/index.adoc

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
	@echo "  html        - Build multi-page HTML documentation (default)"
	@echo "  html-multi  - Build multi-page HTML documentation"
	@echo "  html-single - Build single-page HTML documentation"
	@echo "  pdf         - Build PDF documentation"
	@echo "  clean       - Remove build directory"
	@echo "  help        - Show this help message"
