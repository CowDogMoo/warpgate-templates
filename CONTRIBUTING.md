# Contributing to Warpgate Templates

Thank you for your interest in contributing to Warpgate Templates! This
document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Creating a New Template](#creating-a-new-template)
- [Template Guidelines](#template-guidelines)
- [Testing Your Template](#testing-your-template)
- [Submitting Changes](#submitting-changes)
- [Template Review Process](#template-review-process)

## Code of Conduct

This project adheres to a code of conduct that all contributors are
expected to follow. Please be respectful and constructive in all
interactions.

## Getting Started

1. **Fork the repository**

   ```bash
   gh repo fork cowdogmoo/warpgate-templates
   ```

2. **Clone your fork**

   ```bash
   git clone https://github.com/YOUR-USERNAME/warpgate-templates.git
   cd warpgate-templates
   ```

3. **Install Warpgate** (if not already installed)

   ```bash
   # See: https://github.com/cowdogmoo/warpgate#installation
   ```

4. **Create a feature branch**

   ```bash
   git checkout -b feature/my-new-template
   ```

## Creating a New Template

### 1. Use the Template Scaffold

Use Warpgate's init command to create a new template structure:

```bash
warpgate init --output ./templates/my-template
```

Or create manually:

```bash
mkdir -p templates/my-template
cd templates/my-template
```

### 2. Create `warpgate.yaml`

Define your template configuration:

```yaml
metadata:
  name: my-template
  version: 1.0.0
  description: Description of your template
  author: Your Name <your.email@example.com>
  license: MIT
  tags:
    - security
    - offensive
  requires:
    warpgate: '>=1.0.0'

name: my-template
version: latest

base:
  image: ubuntu:jammy  # Choose appropriate base image
  pull: true

provisioners:
  - type: shell
    inline:
      - apt-get update
      - apt-get install -y python3 python3-pip

  - type: ansible
    playbook_path: ${PROVISION_REPO_PATH}/playbooks/my-playbook/my-playbook.yml
    galaxy_file: ${PROVISION_REPO_PATH}/requirements.yml
    extra_vars:
      ansible_shell_executable: /bin/bash

  - type: shell
    inline:
      - apt-get clean
      - rm -rf /var/lib/apt/lists/*

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

### 3. Create `README.md`

Document your template:

```markdown
# My Template

Brief description of what this template provides.

## Features

- Feature 1
- Feature 2
- Feature 3

## Requirements

- Warpgate >= 1.0.0
- Any external dependencies

## Usage

\`\`\`bash
# Build container
warpgate build --template my-template

# Build AMI
warpgate build --template my-template --target ami
\`\`\`

## Configuration

Describe any environment variables or configuration options.

## Notes

Any important notes or caveats.

## License

Specify license (should match template metadata).
```

## Template Guidelines

### General Guidelines

1. **Base Image Selection**
   - Use official, well-maintained base images
   - Prefer specific versions over `latest` for reproducibility
   - For security tools, Kali or Ubuntu are good choices

2. **Provisioning**
   - Keep provisioners modular and well-commented
   - Use Ansible for complex provisioning when possible
   - Include cleanup steps to reduce image size
   - Set `DEBIAN_FRONTEND=noninteractive` for apt operations

3. **Metadata**
   - Use descriptive names (lowercase, hyphens)
   - Follow semantic versioning
   - Include relevant tags for discoverability
   - Specify minimum Warpgate version required

4. **Multi-Architecture Support**
   - Test on both amd64 and arm64 when possible
   - Document any architecture-specific limitations
   - Use conditional logic if needed for arch-specific steps

5. **Security**
   - Don't embed secrets or credentials
   - Use environment variables for sensitive data
   - Follow least-privilege principles
   - Document security considerations in README

### File Organization

```text
templates/my-template/
├── warpgate.yaml          # Required: template configuration
├── README.md              # Required: documentation
├── scripts/               # Optional: provisioning scripts
│   ├── setup.sh
│   └── configure.sh
└── files/                 # Optional: configuration files
    └── config.yaml
```

### Naming Conventions

- **Template names**: `lowercase-with-hyphens`
- **Tags**: lowercase, single words or hyphenated
- **Files**: lowercase, descriptive names

## Testing Your Template

### 1. Validate the Template

```bash
warpgate validate templates/my-template/warpgate.yaml
```

### 2. Build Locally

Test container build:

```bash
warpgate build \
  --file templates/my-template/warpgate.yaml \
  --arch amd64
```

Test AMI build (if you have AWS access):

```bash
warpgate build \
  --file templates/my-template/warpgate.yaml \
  --target ami \
  --region us-east-1
```

### 3. Test the Image

```bash
# For containers
docker run -it my-template:latest /bin/bash

# For AMIs
# Launch EC2 instance from created AMI
```

### 4. Test Multi-Architecture

```bash
warpgate build \
  --file templates/my-template/warpgate.yaml \
  --arch amd64 \
  --arch arm64
```

## Submitting Changes

### 1. Commit Your Changes

Follow conventional commit format:

```bash
git add templates/my-template/
git commit -m "feat: add my-template for XYZ tool"
```

Commit types:

- `feat`: New template or major feature
- `fix`: Bug fix or correction
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Test additions or changes
- `chore`: Maintenance tasks

### 2. Push to Your Fork

```bash
git push origin feature/my-new-template
```

### 3. Create Pull Request

1. Go to your fork on GitHub
2. Click "Pull Request"
3. Fill out the PR template
4. Link any related issues

### PR Checklist

- [ ] Template validated with `warpgate validate`
- [ ] Successfully built locally
- [ ] README.md included with documentation
- [ ] Metadata complete and accurate
- [ ] No secrets or credentials embedded
- [ ] Multi-arch tested (or limitations documented)
- [ ] Conventional commit messages used
- [ ] PR description explains changes

## Template Review Process

### Review Criteria

Reviewers will check:

1. **Functionality**: Template builds successfully
2. **Documentation**: Clear README with usage examples
3. **Best Practices**: Follows template guidelines
4. **Security**: No embedded secrets, follows security best practices
5. **Quality**: Code is clean, well-organized, and maintainable

### CI/CD Checks

Automated checks will:

- Validate YAML syntax
- Check metadata completeness
- Verify required files exist
- Run template validation
- Build test (if applicable)

### Feedback and Iteration

- Reviewers may request changes
- Address feedback in new commits
- Update PR description if scope changes
- Be responsive to questions

### Approval and Merge

- Requires approval from maintainer(s)
- All CI checks must pass
- Squash or rebase commits if requested
- Maintainers will merge when ready

## Getting Help

- **Questions**: Open a [Discussion](https://github.com/cowdogmoo/warpgate-templates/discussions)
- **Bugs**: Open an [Issue](https://github.com/cowdogmoo/warpgate-templates/issues)
- **Chat**: Join our community (link TBD)

## License

By contributing, you agree that your contributions will be licensed under
the same license as the project (MIT).

---

Thank you for contributing to Warpgate Templates! 🚀
