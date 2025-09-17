# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the documentation repository for OS Migrate, an open source toolbox for parallel OpenStack cloud migration. The repository contains AsciiDoc-formatted documentation.

## Build Commands

### Documentation Building (AsciiDoc)

The documentation is built directly from the repository root:

```bash
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
- HTML: `docs/index.html`
- PDF: `pdf/index.pdf`

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
2. Build outputs go to `docs/` and `pdf/` directories
3. PlantUML diagrams are auto-generated during build
4. Both HTML and PDF outputs are supported
5. Use `make clean` to reset build state

## Ruby Dependencies

The project uses these key Ruby gems (defined in `Gemfile`):
- `asciidoctor` (~> 2.0) - Core AsciiDoc processor
- `asciidoctor-pdf` (~> 2.3) - PDF generation
- `asciidoctor-diagram` (~> 2.2) - PlantUML diagram support
- `rouge` (~> 4.1) - Syntax highlighting