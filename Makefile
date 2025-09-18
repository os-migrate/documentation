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
ASSETS_DIR = assets

# Main document
MAIN_DOC = index.adoc

# AsciiDoc options
ASCIIDOC_OPTS = -a toc=left -a toclevels=3 -a sectlinks -a sectanchors -a icons=font -a source-highlighter=rouge -a linkcss -a stylesheet=assets/css/toc-fold.css
ASCIIDOC_BOOK_OPTS = -a toc=left -a toclevels=3 -a sectlinks -a sectanchors -a icons=font -a source-highlighter=rouge -a doctype=book -a linkcss -a stylesheet=assets/css/toc-fold.css

# PlantUML diagram options
DIAGRAM_OPTS = -r asciidoctor-diagram

.PHONY: all html html-single html-multi pdf diagrams clean help

all: html pdf

html: html-multi

html-single: $(HTML_OUTPUT_DIR)/index-single.html

$(HTML_OUTPUT_DIR)/index-single.html: $(MAIN_DOC) $(wildcard **/*.adoc) diagrams
	@echo "Building single-page HTML documentation..."
	@mkdir -p $(HTML_OUTPUT_DIR)
	@mkdir -p $(HTML_OUTPUT_DIR)/images
	@mkdir -p $(HTML_OUTPUT_DIR)/assets/css
	@mkdir -p $(HTML_OUTPUT_DIR)/assets/js
	@echo "Copying images..."
	@cp -r $(PLANTUML_SRC_DIR)/*.svg $(HTML_OUTPUT_DIR)/images/ 2>/dev/null || true
	@cp -r $(PLANTUML_OUTPUT_DIR)/*.png $(HTML_OUTPUT_DIR)/images/ 2>/dev/null || true
	@echo "Copying assets..."
	@cp -r $(ASSETS_DIR)/css/*.css $(HTML_OUTPUT_DIR)/assets/css/ 2>/dev/null || true
	@cp -r $(ASSETS_DIR)/js/*.js $(HTML_OUTPUT_DIR)/assets/js/ 2>/dev/null || true
	$(ASCIIDOCTOR) $(ASCIIDOC_OPTS) $(DIAGRAM_OPTS) -D $(HTML_OUTPUT_DIR) $(MAIN_DOC)
	@mv $(HTML_OUTPUT_DIR)/index.html $(HTML_OUTPUT_DIR)/index-single.html
	@echo "Injecting TOC JavaScript into single-page version..."
	@./scripts/inject-toc-js.sh

html-multi: $(HTML_OUTPUT_DIR)/index.html $(HTML_OUTPUT_DIR)/operator/index.html $(HTML_OUTPUT_DIR)/developer/index.html $(HTML_OUTPUT_DIR)/reference/modules/index.html $(HTML_OUTPUT_DIR)/reference/roles/index.html
	@echo "Injecting TOC JavaScript..."
	@./scripts/inject-toc-js.sh

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

$(HTML_OUTPUT_DIR)/index.html: index-multi.adoc diagrams
	@echo "Building main HTML page..."
	@mkdir -p $(HTML_OUTPUT_DIR)
	@mkdir -p $(HTML_OUTPUT_DIR)/images
	@mkdir -p $(HTML_OUTPUT_DIR)/assets/css
	@mkdir -p $(HTML_OUTPUT_DIR)/assets/js
	@echo "Copying images..."
	@cp -r $(PLANTUML_SRC_DIR)/*.svg $(HTML_OUTPUT_DIR)/images/ 2>/dev/null || true
	@cp -r $(PLANTUML_OUTPUT_DIR)/*.png $(HTML_OUTPUT_DIR)/images/ 2>/dev/null || true
	@echo "Copying assets..."
	@cp -r $(ASSETS_DIR)/css/*.css $(HTML_OUTPUT_DIR)/assets/css/ 2>/dev/null || true
	@cp -r $(ASSETS_DIR)/js/*.js $(HTML_OUTPUT_DIR)/assets/js/ 2>/dev/null || true
	$(ASCIIDOCTOR) $(ASCIIDOC_OPTS) $(DIAGRAM_OPTS) -D $(HTML_OUTPUT_DIR) index-multi.adoc
	@mv $(HTML_OUTPUT_DIR)/index-multi.html $(HTML_OUTPUT_DIR)/index.html

$(HTML_OUTPUT_DIR)/operator/index.html: operator/index.adoc $(wildcard operator/*.adoc) diagrams
	@echo "Building operator documentation..."
	@mkdir -p $(HTML_OUTPUT_DIR)/operator
	@mkdir -p $(HTML_OUTPUT_DIR)/operator/images
	@mkdir -p $(HTML_OUTPUT_DIR)/operator/assets/css
	@mkdir -p $(HTML_OUTPUT_DIR)/operator/assets/js
	@cp -r $(PLANTUML_SRC_DIR)/*.svg $(HTML_OUTPUT_DIR)/operator/images/ 2>/dev/null || true
	@cp -r $(PLANTUML_OUTPUT_DIR)/*.png $(HTML_OUTPUT_DIR)/operator/images/ 2>/dev/null || true
	@cp -r $(ASSETS_DIR)/css/*.css $(HTML_OUTPUT_DIR)/operator/assets/css/ 2>/dev/null || true
	@cp -r $(ASSETS_DIR)/js/*.js $(HTML_OUTPUT_DIR)/operator/assets/js/ 2>/dev/null || true
	$(ASCIIDOCTOR) $(ASCIIDOC_OPTS) $(DIAGRAM_OPTS) -a leveloffset=-1 -D $(HTML_OUTPUT_DIR)/operator operator/index.adoc

$(HTML_OUTPUT_DIR)/developer/index.html: developer/index.adoc $(wildcard developer/*.adoc) diagrams
	@echo "Building developer documentation..."
	@mkdir -p $(HTML_OUTPUT_DIR)/developer
	@mkdir -p $(HTML_OUTPUT_DIR)/developer/images
	@mkdir -p $(HTML_OUTPUT_DIR)/developer/assets/css
	@mkdir -p $(HTML_OUTPUT_DIR)/developer/assets/js
	@cp -r $(PLANTUML_SRC_DIR)/*.svg $(HTML_OUTPUT_DIR)/developer/images/ 2>/dev/null || true
	@cp -r $(PLANTUML_OUTPUT_DIR)/*.png $(HTML_OUTPUT_DIR)/developer/images/ 2>/dev/null || true
	@cp -r $(ASSETS_DIR)/css/*.css $(HTML_OUTPUT_DIR)/developer/assets/css/ 2>/dev/null || true
	@cp -r $(ASSETS_DIR)/js/*.js $(HTML_OUTPUT_DIR)/developer/assets/js/ 2>/dev/null || true
	$(ASCIIDOCTOR) $(ASCIIDOC_OPTS) $(DIAGRAM_OPTS) -a leveloffset=-1 -D $(HTML_OUTPUT_DIR)/developer developer/index.adoc

$(HTML_OUTPUT_DIR)/reference/modules/index.html: reference/modules/index.adoc $(wildcard reference/modules/*.adoc) diagrams
	@echo "Building modules reference..."
	@mkdir -p $(HTML_OUTPUT_DIR)/reference/modules
	@mkdir -p $(HTML_OUTPUT_DIR)/reference/modules/images
	@mkdir -p $(HTML_OUTPUT_DIR)/reference/modules/assets/css
	@mkdir -p $(HTML_OUTPUT_DIR)/reference/modules/assets/js
	@cp -r $(PLANTUML_SRC_DIR)/*.svg $(HTML_OUTPUT_DIR)/reference/modules/images/ 2>/dev/null || true
	@cp -r $(PLANTUML_OUTPUT_DIR)/*.png $(HTML_OUTPUT_DIR)/reference/modules/images/ 2>/dev/null || true
	@cp -r $(ASSETS_DIR)/css/*.css $(HTML_OUTPUT_DIR)/reference/modules/assets/css/ 2>/dev/null || true
	@cp -r $(ASSETS_DIR)/js/*.js $(HTML_OUTPUT_DIR)/reference/modules/assets/js/ 2>/dev/null || true
	$(ASCIIDOCTOR) $(ASCIIDOC_OPTS) $(DIAGRAM_OPTS) -a leveloffset=-1 -D $(HTML_OUTPUT_DIR)/reference/modules reference/modules/index.adoc

$(HTML_OUTPUT_DIR)/reference/roles/index.html: reference/roles/index.adoc $(wildcard reference/roles/*.adoc) diagrams
	@echo "Building roles reference..."
	@mkdir -p $(HTML_OUTPUT_DIR)/reference/roles
	@mkdir -p $(HTML_OUTPUT_DIR)/reference/roles/images
	@mkdir -p $(HTML_OUTPUT_DIR)/reference/roles/assets/css
	@mkdir -p $(HTML_OUTPUT_DIR)/reference/roles/assets/js
	@cp -r $(PLANTUML_SRC_DIR)/*.svg $(HTML_OUTPUT_DIR)/reference/roles/images/ 2>/dev/null || true
	@cp -r $(PLANTUML_OUTPUT_DIR)/*.png $(HTML_OUTPUT_DIR)/reference/roles/images/ 2>/dev/null || true
	@cp -r $(ASSETS_DIR)/css/*.css $(HTML_OUTPUT_DIR)/reference/roles/assets/css/ 2>/dev/null || true
	@cp -r $(ASSETS_DIR)/js/*.js $(HTML_OUTPUT_DIR)/reference/roles/assets/js/ 2>/dev/null || true
	$(ASCIIDOCTOR) $(ASCIIDOC_OPTS) $(DIAGRAM_OPTS) -a leveloffset=-1 -D $(HTML_OUTPUT_DIR)/reference/roles reference/roles/index.adoc

$(PDF_OUTPUT_DIR)/index.pdf: $(MAIN_DOC) $(wildcard **/*.adoc) diagrams
	@echo "Building PDF documentation..."
	@mkdir -p $(PDF_OUTPUT_DIR)
	@mkdir -p $(PDF_OUTPUT_DIR)/images
	@echo "Copying images for PDF..."
	@cp -r $(PLANTUML_SRC_DIR)/*.svg $(PDF_OUTPUT_DIR)/images/ 2>/dev/null || true
	@cp -r $(PLANTUML_OUTPUT_DIR)/*.png $(PDF_OUTPUT_DIR)/images/ 2>/dev/null || true
	$(ASCIIDOCTOR_PDF) $(ASCIIDOC_OPTS) $(DIAGRAM_OPTS) -D $(PDF_OUTPUT_DIR) $(MAIN_DOC)

clean:
	@echo "Cleaning build directories..."
	rm -rf $(HTML_OUTPUT_DIR) $(PDF_OUTPUT_DIR) $(PLANTUML_OUTPUT_DIR)

help:
	@echo "Available targets:"
	@echo "  all         - Build both HTML and PDF documentation"
	@echo "  html        - Build multi-page HTML documentation (default)"
	@echo "  html-multi  - Build multi-page HTML documentation"
	@echo "  html-single - Build single-page HTML documentation"
	@echo "  pdf         - Build PDF documentation"
	@echo "  diagrams    - Build PlantUML diagrams"
	@echo "  clean       - Remove build directory"
	@echo "  help        - Show this help message"
