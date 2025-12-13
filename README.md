# Warp Gate Templates

**Ready-to-use templates for building security labs, golden images, and multi-architecture containers.**

[![License](https://img.shields.io/github/license/CowDogMoo/warpgate-templates?label=License&style=flat&color=blue&logo=github)](https://github.com/CowDogMoo/warpgate-templates/blob/main/LICENSE)
[![Release](https://img.shields.io/github/v/release/CowDogMoo/warpgate-templates?label=Release&logo=github)](https://github.com/CowDogMoo/warpgate-templates/releases)

[![Pre-Commit](https://github.com/CowDogMoo/warpgate-templates/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/CowDogMoo/warpgate-templates/actions/workflows/pre-commit.yaml)
[![Validate Templates](https://github.com/CowDogMoo/warpgate-templates/actions/workflows/validate-templates.yaml/badge.svg)](https://github.com/CowDogMoo/warpgate-templates/actions/workflows/validate-templates.yaml)
[![Build and Push](https://github.com/CowDogMoo/warpgate-templates/actions/workflows/build-and-push-templates.yaml/badge.svg)](https://github.com/CowDogMoo/warpgate-templates/actions/workflows/build-and-push-templates.yaml)

---

## Overview

Official template repository for [Warp Gate](https://github.com/cowdogmoo/warpgate) -
a robust, automatable engine for building security labs, golden images, and
multi-architecture containers.

This repository provides production-ready templates that enable rapid deployment of:

- **Security testing environments** - Red team tooling, C2 infrastructure, attack platforms
- **Golden images** - Standardized base images for consistent deployments
- **Multi-arch containers** - Native builds for amd64 and arm64 architectures
- **AWS AMIs** - Cloud-ready images for EC2 deployment

All templates are built using declarative YAML configurations and support both
container and cloud infrastructure targets.

## Quick Start

```bash
# Install warpgate
go install github.com/CowDogMoo/warpgate/cmd/warpgate@latest

# List available templates
warpgate templates list

# Build a security template
warpgate build attack-box --arch amd64 \
  --var PROVISION_REPO_PATH=$HOME/ansible-collection-arsenal

# Build a simple container template
warpgate build printer-monitor --arch amd64 --push
```

## Available Templates

### Provisioner-Based Templates

Advanced templates using Ansible/shell provisioners:

| Template | Description | Base Image | Platforms |
| -------- | ----------- | ---------- | --------- |
| [attack-box](./templates/attack-box) | Full-featured penetration testing toolkit | Kali Linux | Container, AMI |
| [sliver](./templates/sliver) | Sliver C2 server and client | Ubuntu 25.04 | Container, AMI |
| [atomic-red-team](./templates/atomic-red-team) | Atomic Red Team testing framework | Ubuntu 22.04 | Container, AMI |
| [ttpforge](./templates/ttpforge) | TTP Forge testing framework | Ubuntu 25.04 | Container, AMI |

### Dockerfile-Based Templates

Simple templates using existing Dockerfiles:

| Template | Description | Type | Platforms |
| -------- | ----------- | ---- | --------- |
| [printer-monitor](./templates/printer-monitor) | Brother printer health monitoring | Utility | Container |
| [guacamole-provisioner](./templates/guacamole-provisioner) | Apache Guacamole connection provisioner | Utility | Container |
| [atomic-red-dockerfile](./templates/atomic-red-dockerfile) | Atomic Red Team (Dockerfile variant) | Security | Container |

## Features

### Template Capabilities

| Feature | Description |
| ------- | ----------- |
| **Multi-Architecture** | Build for amd64 and arm64 simultaneously |
| **Dual Output** | Create both container images and AWS AMIs |
| **Provisioner Support** | Ansible playbooks, shell scripts, and custom provisioners |
| **Variable Substitution** | Use environment variables and CLI flags |
| **Registry Integration** | Push directly to container registries |
| **Modular Design** | Reusable, composable configurations |
| **CI/CD Ready** | Automated validation and builds |
| **Version Control** | Semantic versioning with compatibility checks |

## Usage Guide

### Prerequisites

- [Warp Gate](https://github.com/cowdogmoo/warpgate) CLI tool (`>= 1.0.0`)
- For container builds: Docker or Podman
- For AMI builds: AWS account with appropriate permissions
- For provisioner-based templates: Provisioning repository (e.g., ansible-collection-arsenal)

### Building Templates

#### Building Provisioner-Based Templates

Templates with complex provisioning (Ansible/shell):

```bash
# Build with provisioners (requires PROVISION_REPO_PATH)
warpgate build templates/attack-box/warpgate.yaml \
  --arch amd64 \
  --registry ghcr.io/l50 \
  --var PROVISION_REPO_PATH=$HOME/ansible-collection-arsenal

# Build for ARM64
warpgate build templates/ttpforge/warpgate.yaml \
  --arch arm64 \
  --registry ghcr.io/l50 \
  --var PROVISION_REPO_PATH=$HOME/ansible-collection-arsenal \
  --verbose

# Build and push to registry
warpgate build templates/sliver/warpgate.yaml \
  --arch amd64 \
  --registry ghcr.io/l50 \
  --var PROVISION_REPO_PATH=$HOME/ansible-collection-arsenal \
  --push
```

#### Building Dockerfile-Based Templates

Simple templates with existing Dockerfiles (no vars needed):

```bash
# Build from Dockerfile
warpgate build templates/printer-monitor/warpgate.yaml --arch amd64

# Build with custom registry
warpgate build templates/guacamole-provisioner/warpgate.yaml \
  --arch amd64 \
  --registry ghcr.io/l50 \
  --verbose

# Build for ARM64 and push
warpgate build templates/printer-monitor/warpgate.yaml \
  --arch arm64 \
  --registry ghcr.io/l50 \
  --push

# Build with custom build args
warpgate build templates/atomic-red-dockerfile/warpgate.yaml \
  --arch amd64 \
  --build-arg BASE_IMAGE_ARCH=amd64
```

### Using Templates Locally

You can also clone this repository and build directly from local files:

```bash
git clone https://github.com/cowdogmoo/warpgate-templates.git
cd warpgate-templates/templates/attack-box
warpgate build --file warpgate.yaml
```

## Template Structure

Each template directory contains:

```text
template-name/
├── warpgate.yaml          # Main template configuration
├── README.md              # Template-specific documentation
└── scripts/               # Optional: provisioning scripts
```

### Template Configuration Format

Templates use YAML format with the following structure:

```yaml
metadata:
  name: template-name
  version: 1.0.0
  description: Description of what this template provides
  author: Your Name <email@example.com>
  license: MIT
  tags:
    - security
    - red-team
  requires:
    warpgate: ">=1.0.0"

name: template-name
version: latest

base:
  image: base/image:tag
  pull: true

provisioners:
  - type: shell
    inline:
      - apt-get update
      - apt-get install -y package-name

  - type: ansible
    playbook_path: ${PROVISION_REPO_PATH}/playbooks/playbook.yml
    galaxy_file: ${PROVISION_REPO_PATH}/requirements.yml
    extra_vars:
      ansible_shell_executable: /bin/bash

targets:
  - type: container
    platforms:
      - linux/amd64
      - linux/arm64
    tags:
      - latest

  - type: ami
    region: us-east-1
    instance_type: t3.micro
    volume_size: 50
```

## Environment Variables

Many templates use environment variables for paths to provisioning code:

- `PROVISION_REPO_PATH` - Path to ansible-collection-arsenal or similar
  provisioning repos

Set these before building:

```bash
export PROVISION_REPO_PATH="${HOME}/ansible-collection-arsenal"
warpgate build --template attack-box
```

## Contributing

We welcome contributions! See [CONTRIBUTING.md](./CONTRIBUTING.md) for
guidelines on:

- Creating new templates
- Improving existing templates
- Reporting issues
- Submitting pull requests

### Template Validation

Before submitting a template, validate it:

```bash
warpgate validate warpgate.yaml
```

## Template Versioning

Templates follow [Semantic Versioning](https://semver.org/):

- `MAJOR.MINOR.PATCH`
- Breaking changes increment MAJOR version
- New features increment MINOR version
- Bug fixes increment PATCH version

Each template specifies minimum required Warpgate version in metadata.

## Repository Structure

```text
warpgate-templates/
├── templates/              # All template definitions
│   ├── attack-box/
│   ├── sliver/
│   └── atomic-red-team/
├── ansible/                # Shared Ansible roles/playbooks
├── scripts/                # Shared provisioning scripts
│   └── common/
├── docs/                   # Additional documentation
├── .github/
│   └── workflows/          # CI/CD for template validation
├── README.md               # This file
├── CONTRIBUTING.md         # Contribution guidelines
├── LICENSE                 # Repository license
└── .warpgate-version       # Warpgate compatibility info
```

## License

This repository is licensed under the MIT License - see [LICENSE](./LICENSE)
file for details.

Individual templates may have specific licensing requirements - check each
template's README.md.

## Documentation

### Core Documentation

- **[Warp Gate Installation](https://github.com/cowdogmoo/warpgate/blob/main/docs/installation.md)** - Install the Warp Gate CLI
- **[Usage Guide](https://github.com/cowdogmoo/warpgate/blob/main/docs/usage-guide.md)** - Common workflows and examples
- **[Template Reference](https://github.com/cowdogmoo/warpgate/blob/main/docs/template-reference.md)** - Complete YAML syntax reference
- **[Troubleshooting](https://github.com/cowdogmoo/warpgate/blob/main/docs/troubleshooting.md)** - Common issues and solutions

### Template Development

- **[Contributing Guide](./CONTRIBUTING.md)** - How to create and submit templates
- **[Template Repositories](https://github.com/cowdogmoo/warpgate/blob/main/docs/template-repositories.md)** - Repository management

## Support

Need help or want to contribute?

- **Issues**: [Report bugs or request features](https://github.com/cowdogmoo/warpgate-templates/issues)
- **Discussions**: [Ask questions and share ideas](https://github.com/cowdogmoo/warpgate-templates/discussions)
- **Main Project**: [Warp Gate Repository](https://github.com/cowdogmoo/warpgate)

## Built With

This project leverages industry-standard tools:

- **[Warp Gate](https://github.com/cowdogmoo/warpgate)** - Template build engine
- **[Packer](https://www.packer.io/)** - Multi-platform image builder
- **[Ansible](https://www.ansible.com/)** - Configuration management and provisioning
- **[BuildKit](https://github.com/moby/buildkit)** - Container image builds
- **[GitHub Actions](https://github.com/features/actions)** - CI/CD automation

## Related Projects

- **[Warp Gate](https://github.com/cowdogmoo/warpgate)** - Core build engine and CLI
- **[ansible-collection-arsenal](https://github.com/l50/ansible-collection-arsenal)** - Security tooling provisioning roles
- **[ansible-collection-workstation](https://github.com/CowDogMoo/ansible-collection-workstation)** - Workstation configuration roles

---

**Maintained by [CowDogMoo](https://github.com/CowDogMoo)** | **License: [MIT](./LICENSE)**
