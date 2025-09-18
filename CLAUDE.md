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
- Images: `docs/images/` (automatically copied during build)

## Documentation Structure

The documentation uses AsciiDoc format with the following structure:

- `index.adoc` - Main documentation entry point
- `operator/` - Operator documentation (capacity planning, guides, walkthrough, VMware migration)
- `developer/` - Developer documentation (contributing, design, development setup)
- `reference/` - Reference documentation
  - `modules/` - Ansible module documentation
  - `roles/` - Ansible role documentation
- `images/` - Static images and diagrams
  - `*.svg` - SVG workflow diagrams (especially VMware migration workflows)
  - `*.plantuml` - PlantUML diagram sources
  - `render/` - Generated PlantUML diagrams (PNG format)

### Key Documentation Features
- PlantUML diagram generation from source to PNG
- SVG workflow diagrams with automatic copying
- Working table of contents with proper section linking
- Cross-references and automatic TOC generation
- Multiple output formats (HTML/PDF)
- Syntax highlighting with Rouge
- Modular structure using include directives
- Clean rendering without preprocessing artifacts

## Development Workflow

When working with documentation:

1. Source files use AsciiDoc format (.adoc)
2. Build outputs go to `docs/` and `pdf/` directories
3. PlantUML diagrams are auto-generated during build to PNG format
4. Static SVG images are automatically copied during build
5. Both HTML and PDF outputs are supported
6. Use `make clean` to reset build state

## Important Notes for Code Assistance

### Fixed Issues (DO NOT REINTRODUCE)
1. **Section IDs**: All section IDs use static values like `[id="section-name_context"]` instead of `{context}` variables
2. **Include paths**: Reference documentation uses direct file names (e.g., `module-auth_info.adoc`) not subdirectories
3. **Preprocessing directives**: No `ifdev::` or similar directives should appear in rendered output
4. **Image handling**: SVG files are automatically copied by the Makefile during build

### File Path Patterns
- Operator chapters: `operator/chapter_os-migrate-*.adoc`
- Developer chapters: `developer/chapter_os-migrate-*.adoc`
- Module docs: `reference/modules/module-*.adoc`
- Role docs: `reference/roles/role-*.adoc`

## Ruby Dependencies

The project uses these key Ruby gems (defined in `Gemfile`):
- `asciidoctor` (~> 2.0) - Core AsciiDoc processor
- `asciidoctor-pdf` (~> 2.3) - PDF generation
- `asciidoctor-diagram` (~> 2.2) - PlantUML diagram support
- `rouge` (~> 4.1) - Syntax highlighting