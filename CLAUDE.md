# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the documentation repository for OS Migrate, an open source toolbox for parallel OpenStack cloud migration. The repository contains AsciiDoc-formatted documentation.

## Build Commands

### Documentation Building (AsciiDoc)

The main documentation is located in `asciidoc/` directory:

```bash
# Navigate to asciidoc directory first
cd asciidoc/

# Install Ruby dependencies
bundle install

# Build HTML documentation
make html

# Build PDF documentation  
make pdf

# Build both HTML and PDF
make all

# Build PlantUML diagrams only
make diagrams

# Clean build artifacts
make clean

# Show available build targets
make help
```

Output locations:
- HTML: `asciidoc/_build/html/index.html`
- PDF: `asciidoc/_build/pdf/index.pdf`

### Alternative Build Method (Legacy)

For the legacy documentation build process:

```bash
# Build documentation using toolbox container
make toolbox-build
./toolbox/run make docs
```

## Documentation Structure

The documentation uses AsciiDoc format with the following structure:

- `index.adoc` - Main documentation entry point
- `user/` - User documentation (installation, usage, troubleshooting) 
- `operator/` - Operator documentation (capacity planning, guides, walkthrough)
- `devel/` - Developer documentation (contributing, design, development setup)
- `modules/` - Ansible module documentation
- `roles/` - Ansible role documentation
- `images/plantuml/` - PlantUML diagram sources

### Key Documentation Features
- PlantUML diagram generation from source
- Cross-references and automatic TOC generation
- Multiple output formats (HTML/PDF)
- Syntax highlighting with Rouge
- Modular structure using include directives

## Development Workflow

When working with documentation:

1. Source files use AsciiDoc format (.adoc)
2. Build outputs go to `_build/` directory
3. PlantUML diagrams are auto-generated during build
4. Both HTML and PDF outputs are supported
5. Use `make clean` to reset build state

## Ruby Dependencies

The project uses these key Ruby gems (defined in `asciidoc/Gemfile`):
- `asciidoctor` - Core AsciiDoc processor
- `asciidoctor-pdf` - PDF generation
- `asciidoctor-diagram` - PlantUML diagram support
- `rouge` - Syntax highlighting