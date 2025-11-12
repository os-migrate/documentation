# OS Migrate Documentation

This is the documentation repository for OS Migrate, an open source toolbox for parallel OpenStack cloud migration. The repository contains AsciiDoc-formatted documentation.

## Structure

- `index.adoc` - Main documentation entry point
- `source/` - All AsciiDoc documentation files
  - `operator-*.adoc` - Operator documentation (guides, VMware migration, troubleshooting)
  - `developer-*.adoc` - Developer documentation (contributing, design, development setup)
  - `reference-module-*.adoc` - Ansible module reference documentation
  - `reference-role-*.adoc` - Ansible role reference documentation
- `images/` - Static SVG workflow diagrams
- `build/` - Build output directory (generated)

## Building Documentation

### Prerequisites

Install Ruby dependencies using bundler:

```bash
bundle install
```

### Build Commands

```bash
# Build HTML documentation
make html

# or simply
make

# Clean build artifacts
make clean

# Show available build targets
make help
```

### Output

Built documentation will be available at:
- **HTML**: `build/index.html`
- **Images**: `build/images/` (SVG files automatically copied during build)

## Features

- **AsciiDoc format**: Human-readable documentation source format
- **Single-page HTML**: All documentation built into one HTML file
- **SVG workflow diagrams**: Static diagrams for VMware migration workflows
- **Table of contents**: Left sidebar navigation (3 levels deep)
- **Syntax highlighting**: Code block highlighting with Rouge
- **Modular structure**: Include directives for organizing content
- **Cross-references**: Automatic section linking and anchors

## Build Configuration

The Makefile uses AsciiDoctor with the following configuration:
- `toc=left` - Table of contents on left sidebar
- `toclevels=3` - Show 3 levels in TOC
- `sectlinks` - Make section titles clickable links
- `sectanchors` - Add anchor symbols to sections
- `icons=font` - Use Font Awesome icons
- `source-highlighter=rouge` - Syntax highlighting with Rouge

## Ruby Dependencies

The project uses these Ruby gems (defined in `Gemfile`):
- `asciidoctor` (~> 2.0) - Core AsciiDoc processor
- `rouge` (~> 4.1) - Syntax highlighting

The upstream documentation is available [here](https://github.com/os-migrate/documentation). For Red Hat Certified and Supported documentation, please see [Red Hat OpenStack VMWare Migration Toolkit](https://console.redhat.com/ansible/automation-hub/repo/published/os_migrate/vmware_migration_kit/docs/).

