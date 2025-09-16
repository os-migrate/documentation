# OS Migrate Documentation

This is the documentation repository for OS Migrate, an open source toolbox for parallel OpenStack cloud migration. The repository contains AsciiDoc-formatted documentation.

## Structure

- `index.adoc` - Main documentation entry point
- `user/` - User documentation (installation, usage, troubleshooting)
- `operator/` - Operator documentation (capacity planning, guides, walkthrough)
- `devel/` - Developer documentation (contributing, design, development setup)
- `modules/` - Ansible module documentation
- `roles/` - Ansible role documentation  
- `images/plantuml/` - PlantUML diagram sources

## Building Documentation

### Prerequisites

Install Ruby dependencies using bundler:

```bash
# Install Ruby gems
bundle install
```

### Build Commands

```bash
# Build HTML documentation
make html

# Build PDF documentation  
make pdf

# Build both formats
make all

# Build PlantUML diagrams only
make diagrams

# Clean build artifacts
make clean

# Show available build targets
make help
```

### Output

Built documentation will be available in:
- HTML: `asciidoc/_build/html/index.html`
- PDF: `asciidoc/_build/pdf/index.pdf`

## Features

- **AsciiDoc format**: Human-readable documentation source format
- **PlantUML diagrams**: Automatic diagram generation from source
- **Multiple output formats**: HTML and PDF generation
- **Cross-references**: Maintained document linking
- **Include directives**: Modular documentation structure
- **Syntax highlighting**: Code block highlighting with Rouge
- **Table of contents**: Automatic TOC generation
