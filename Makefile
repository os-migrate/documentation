# OS Migrate AsciiDoc Documentation Makefile

# Tools
ASCIIDOCTOR = asciidoctor
ASCIIDOCTOR_PDF = asciidoctor-pdf
ASCIIDOCTOR_DIAGRAM = asciidoctor-diagram

# Source and output directories
SRC_DIR = .
HTML_OUTPUT_DIR = docs
PDF_OUTPUT_DIR = pdf
PLANTUML_SRC_DIR = images
PLANTUML_OUTPUT_DIR = images/render

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
	@echo "Building PlantUML diagrams..."
	@mkdir -p $(PLANTUML_OUTPUT_DIR)
	@for plantuml_file in $(PLANTUML_SRC_DIR)/*.plantuml; do \
		if [ -f "$$plantuml_file" ]; then \
			echo "Processing $$plantuml_file..."; \
			base_name=$$(basename "$$plantuml_file" .plantuml); \
			echo "plantuml::$$plantuml_file[format=png]" | $(ASCIIDOCTOR) $(DIAGRAM_OPTS) -a imagesoutdir=$(PLANTUML_OUTPUT_DIR) -o /tmp/$$base_name.html -; \
		fi; \
	done
	@echo "PlantUML diagrams generated in $(PLANTUML_OUTPUT_DIR)"

$(HTML_OUTPUT_DIR)/index.html: $(MAIN_DOC) $(wildcard **/*.adoc) diagrams
	@echo "Building HTML documentation..."
	@mkdir -p $(HTML_OUTPUT_DIR)
	$(ASCIIDOCTOR) $(ASCIIDOC_OPTS) $(DIAGRAM_OPTS) -D $(HTML_OUTPUT_DIR) $(MAIN_DOC)

$(PDF_OUTPUT_DIR)/index.pdf: $(MAIN_DOC) $(wildcard **/*.adoc) diagrams
	@echo "Building PDF documentation..."
	@mkdir -p $(PDF_OUTPUT_DIR)
	$(ASCIIDOCTOR_PDF) $(ASCIIDOC_OPTS) $(DIAGRAM_OPTS) -D $(PDF_OUTPUT_DIR) $(MAIN_DOC)

clean:
	@echo "Cleaning build directories..."
	rm -rf $(HTML_OUTPUT_DIR) $(PDF_OUTPUT_DIR) $(PLANTUML_OUTPUT_DIR)

help:
	@echo "Available targets:"
	@echo "  all      - Build both HTML and PDF documentation"
	@echo "  html     - Build HTML documentation"
	@echo "  pdf      - Build PDF documentation" 
	@echo "  diagrams - Build PlantUML diagrams"
	@echo "  clean    - Remove build directory"
	@echo "  help     - Show this help message"
