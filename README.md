# Warp Gate Templates

Official template repository for
[Warp Gate](https://github.com/cowdogmoo/warpgate) - a robust, automatable
engine for building security labs, golden images, and multi-architecture containers.

## Overview

Warp Gate is a powerful infrastructure-as-code platform built on modular Packer
templates and Taskfile-driven workflows. This repository provides pre-built
templates that spin up rapidly for use in security labs, cyber ranges, DevOps CI,
and immutable infrastructure deployments.

All templates support both **multi-architecture container images** (amd64/arm64)
and **AWS AMIs**, enabling consistent environments across development, testing,
and production.

## Available Templates

| Template | Description | Base Image | Platforms |
| -------- | ----------- | ---------- | --------- |
| [attack-box](./templates/attack-box) | Full-featured penetration testing toolkit | Kali Linux | Container, AMI |
| [sliver](./templates/sliver) | Sliver C2 server and client | Ubuntu 25.04 | Container, AMI |
| [atomic-red-team](./templates/atomic-red-team) | Atomic Red Team testing framework | Ubuntu 22.04 | Container, AMI |

## Quick Start

### Prerequisites

- [Warp Gate](https://github.com/cowdogmoo/warpgate) CLI tool (`>= 1.0.0`)
- [Packer](https://www.packer.io/) (`>= 1.9.0`) - underlying build engine
- [Task](https://taskfile.dev/) - workflow automation (optional but recommended)
- For container builds: Docker or Podman
- For AMI builds: AWS account with appropriate permissions

### Building a Template

```bash
# List available templates
warpgate templates list

# Get template info
warpgate templates info attack-box

# Build container image from template
warpgate build --template attack-box

# Build container and push to registry
warpgate build --template attack-box --push --registry ghcr.io/yourorg

# Build AWS AMI
warpgate build --template attack-box --target ami --region us-east-1
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

## Support

- **Issues**: [GitHub Issues](https://github.com/cowdogmoo/warpgate-templates/issues)
- **Discussions**: [GitHub Discussions](https://github.com/cowdogmoo/warpgate-templates/discussions)
- **Documentation**: [Warpgate Docs](https://github.com/cowdogmoo/warpgate/docs)

## Architecture

Warp Gate leverages:

- **Packer** - Industry-standard tool for creating identical machine images
  across multiple platforms
- **Taskfile** - Modern task runner for automating complex build workflows
- **Modular Templates** - Reusable, composable configurations for rapid
  deployment
- **Multi-arch Support** - Native builds for amd64 and arm64 architectures

This architecture enables reproducible, version-controlled infrastructure that
can be automated in CI/CD pipelines or used locally for development.

## Related Projects

- [Warp Gate](https://github.com/cowdogmoo/warpgate) - The core build engine
- [ansible-collection-arsenal](https://github.com/l50/ansible-collection-arsenal)
  \- Ansible roles for security tooling provisioning
- [ansible-collection-workstation](https://github.com/CowDogMoo/ansible-collection-workstation)
  \- Ansible roles for workstation setup

---

**Status**: Active Development

**Version**: 1.0.0

**Maintained by**: [CowDogMoo](https://github.com/CowDogMoo)
