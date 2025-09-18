# OS Migrate Documentation

This is the documentation repository for OS Migrate, an open source toolbox for parallel OpenStack cloud migration. The repository contains AsciiDoc-formatted documentation.

## Structure

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

## Building Documentation

### Prerequisites

Install Ruby dependencies using bundler:

```bash
# Install Ruby gems
bundle install
```

### Build Commands

```bash
# Build multi-page HTML documentation (default)
make html

# Build multi-page HTML documentation (explicit)
make html-multi

# Build single-page HTML documentation
make html-single

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
- **Multi-page HTML**: `docs/index.html` (main page with links to sections)
  - `docs/operator/index.html` - Operator guide
  - `docs/developer/index.html` - Developer documentation
  - `docs/reference/modules/index.html` - Modules reference
  - `docs/reference/roles/index.html` - Roles reference
- **Single-page HTML**: `docs/index-single.html` (complete documentation in one file)
- **PDF**: `pdf/index.pdf`
- **Images**: `docs/images/` and subdirectories (automatically copied during build)

## Features

- **AsciiDoc format**: Human-readable documentation source format
- **PlantUML diagrams**: Automatic diagram generation from source to PNG
- **SVG workflow diagrams**: Static SVG diagrams for complex workflows (VMware migration)
- **Multiple output formats**: HTML and PDF generation
- **Working table of contents**: Properly linked section navigation
- **Image handling**: Automatic copying of static and generated images
- **Cross-references**: Maintained document linking
- **Include directives**: Modular documentation structure
- **Syntax highlighting**: Code block highlighting with Rouge

## Recent Improvements

- **Multi-page HTML output**: Documentation now generates as separate pages per section for better navigation and performance
- **Fixed TOC links**: Section links now properly navigate to correct locations
- **Clean rendering**: Removed preprocessing directive artifacts from output
- **SVG image support**: VMware workflow diagrams now render correctly
- **Improved build process**: Automatic image copying and proper file structure
- **Flexible build options**: Choose between single-page or multi-page HTML output
