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

# or simply
make

# Clean build artifacts
make clean

# Show available build targets
make help
```

Output locations:
- **HTML**: `docs/index.html`
- **Images**: `docs/images/` (SVG files automatically copied during build)

## Documentation Structure

The documentation uses AsciiDoc format with the following structure:

- `index.adoc` - Main documentation source (used for HTML generation)
- `source/` - All AsciiDoc documentation files
  - `operator-*.adoc` - Operator documentation (guides, VMware migration, troubleshooting)
    - `operator-vmware-guide.adoc` - VMware migration guide
    - `operator-aee.adoc` - Ansible Execution Environment guide
    - `operator-quickstart-guide.adoc` - Quickstart guide
    - `operator-troubleshooting.adoc` - Troubleshooting guide
  - `developer-*.adoc` - Developer documentation (contributing, design, development setup)
    - `developer-contributing-code.adoc` - Code contribution guide
    - `developer-design.adoc` - Design documentation
    - `developer-dev-env-setup.adoc` - Development environment setup
  - `reference-module-*.adoc` - Ansible module reference documentation
  - `reference-role-*.adoc` - Ansible role reference documentation
- `images/` - Static SVG workflow diagrams
  - `*.svg` - VMware migration workflow diagrams
- `docs/` - Build output directory (generated, not in source control)

### Key Documentation Features
- Single-page HTML generation
- Native AsciiDoctor table of contents (left sidebar, 3 levels deep)
- Cross-references and automatic section linking
- SVG image support with automatic copying
- Syntax highlighting with Rouge
- Modular structure using include directives
- Clean rendering using only AsciiDoctor native features

## Build Architecture

The build process is straightforward:

### HTML Build
- Uses `index.adoc` as the source document
- Builds single-page HTML with all content
- Output: `docs/index.html`
- Automatically copies SVG images from `images/` to `docs/images/`

## Development Workflow

When working with documentation:

1. Source files use AsciiDoc format (.adoc)
2. Build output goes to the `docs/` directory
3. Static SVG images are automatically copied during build
4. Use `make clean` to reset build state
5. Edit `index.adoc` to control what content is included

## Important Notes for Code Assistance

### File Path Patterns
All AsciiDoc files are located in the `source/` directory:
- Operator documentation: `source/operator-*.adoc`
- Developer documentation: `source/developer-*.adoc`
- Module reference docs: `source/reference-module-*.adoc`
- Role reference docs: `source/reference-role-*.adoc`

### AsciiDoc Configuration
The build uses these AsciiDoctor attributes (defined in Makefile):
- `toc=left` - Table of contents on left sidebar
- `toclevels=3` - Show 3 levels in TOC
- `sectlinks` - Make section titles clickable links
- `sectanchors` - Add anchor symbols to sections
- `icons=font` - Use Font Awesome icons
- `source-highlighter=rouge` - Syntax highlighting with Rouge

## Ruby Dependencies

The project uses these key Ruby gems (defined in `Gemfile`):
- `asciidoctor` (~> 2.0) - Core AsciiDoc processor
- `rouge` (~> 4.1) - Syntax highlighting
