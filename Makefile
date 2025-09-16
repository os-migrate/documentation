# OS Migrate AsciiDoc Documentation Makefile

# Tools
ASCIIDOCTOR = asciidoctor
ASCIIDOCTOR_PDF = asciidoctor-pdf
ASCIIDOCTOR_DIAGRAM = asciidoctor-diagram

# Source and output directories
SRC_DIR = .
HTML_OUTPUT_DIR = docs
PDF_OUTPUT_DIR = pdf

# Main document
MAIN_DOC = index.adoc

# AsciiDoc options
ASCIIDOC_OPTS = -a toc=left -a toclevels=3 -a sectlinks -a sectanchors -a icons=font -a source-highlighter=rouge

# PlantUML diagram options
DIAGRAM_OPTS = -r asciidoctor-diagram

.PHONY: all html pdf diagrams clean help

all: html pdf

html: $(HTML_OUTPUT_DIR)/index.html

pdf: $(PDF_OUTPUT_DIR)/index.pdf

diagrams:
	@echo "Building diagrams..."
	$(ASCIIDOCTOR) $(DIAGRAM_OPTS) -a data-uri -o $(HTML_OUTPUT_DIR)/diagrams.html images/plantuml/*.plantuml

$(HTML_OUTPUT_DIR)/index.html: $(MAIN_DOC) $(wildcard **/*.adoc)
	@echo "Building HTML documentation..."
	@mkdir -p $(HTML_OUTPUT_DIR)
	$(ASCIIDOCTOR) $(ASCIIDOC_OPTS) $(DIAGRAM_OPTS) -D $(HTML_OUTPUT_DIR) $(MAIN_DOC)

$(PDF_OUTPUT_DIR)/index.pdf: $(MAIN_DOC) $(wildcard **/*.adoc)
	@echo "Building PDF documentation..."
	@mkdir -p $(PDF_OUTPUT_DIR)
	$(ASCIIDOCTOR_PDF) $(ASCIIDOC_OPTS) $(DIAGRAM_OPTS) -D $(PDF_OUTPUT_DIR) $(MAIN_DOC)

clean:
	@echo "Cleaning build directory..."
	rm -rf $(OUTPUT_DIR)

help:
	@echo "Available targets:"
	@echo "  all      - Build both HTML and PDF documentation"
	@echo "  html     - Build HTML documentation"
	@echo "  pdf      - Build PDF documentation" 
	@echo "  diagrams - Build PlantUML diagrams"
	@echo "  clean    - Remove build directory"
	@echo "  help     - Show this help message"
