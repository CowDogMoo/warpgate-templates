# Building and Using asdf Version Manager with Warpgate

Complete guide to building and deploying the asdf version manager using
Warpgate.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Building asdf Container](#building-asdf-container)
- [Using asdf](#using-asdf)
  - [Installing Language Runtimes](#installing-language-runtimes)
  - [Managing Versions](#managing-versions)
  - [Project-Specific Versions](#project-specific-versions)
- [Popular Plugins](#popular-plugins)
- [Troubleshooting](#troubleshooting)
- [Advanced Usage](#advanced-usage)
- [Cleanup](#cleanup)

## Overview

This guide demonstrates how to build asdf version manager images using
Warpgate for managing multiple runtime versions across various programming
languages and tools.

**What is asdf?**

asdf is a CLI tool that manages multiple runtime versions with a single CLI
tool. It provides:

- Unified version management across many languages (Node.js, Python, Ruby,
  Go, etc.)
- Project-specific version configuration via `.tool-versions` files
- Extensible plugin system for adding new tools
- Simple commands for installing and switching between versions
- No language-specific version managers needed

**Why use Warpgate for asdf?**

- Reproducible builds with version-controlled templates
- Multi-architecture support (amd64, arm64)
- Consistent environment across teams and CI/CD pipelines
- Easy deployment to container orchestration platforms
- Pre-configured with common development tools

## Prerequisites

**Required:**

- Docker or Podman installed and running
- Warpgate installed ([installation guide](../README.md#installation))
- Provisioning repository with asdf playbooks
- Basic understanding of version managers

**For production use:**

- Understanding of language runtime requirements
- Disk space for multiple runtime versions
- Appropriate resource allocation for development workloads

## Quick Start

Get asdf running in 5 minutes:

```bash
# Build asdf container image
warpgate build asdf --arch amd64

# Run asdf container
docker run -it --rm \
  --name asdf-dev \
  asdf:latest \
  /bin/bash

# Inside container, check asdf is installed
asdf --version

# Add a plugin and install a runtime (example: Node.js)
asdf plugin add nodejs
asdf install nodejs 20.10.0
asdf global nodejs 20.10.0
node --version
```

## Building asdf Container

### Using Warpgate Template

**Build from template name:**

```bash
# Build for amd64
warpgate build asdf --arch amd64

# Build for arm64
warpgate build asdf --arch arm64

# Build for both architectures
warpgate build asdf --arch amd64,arm64
```

**Verify the build:**

```bash
# Check image was created
docker images | grep asdf

# Expected output:
# asdf    latest    abc123def456    2 minutes ago    500MB
```

### Building with Custom Provision Path

If your template requires an Ansible collection:

```bash
# Build with variable override
warpgate build asdf --var PROVISION_REPO_PATH=/path/to/ansible-collection-arsenal

# Or use a variable file
cat > asdf-vars.yaml <<EOF
PROVISION_REPO_PATH: /path/to/ansible-collection-arsenal
VERSION: 1.0.0
DEBUG: true
EOF

warpgate build asdf --var-file asdf-vars.yaml
```

## Using asdf

### Installing Language Runtimes

Once inside the asdf container, you can install and manage various language
runtimes:

#### Step 1: List Available Plugins

```bash
# List all available plugins
asdf plugin list all

# Search for specific plugin
asdf plugin list all | grep nodejs
asdf plugin list all | grep python
```

#### Step 2: Add a Plugin

```bash
# Add Node.js plugin
asdf plugin add nodejs

# Add Python plugin
asdf plugin add python

# Add Ruby plugin
asdf plugin add ruby

# Add Go plugin
asdf plugin add golang

# Verify plugin was added
asdf plugin list
```

#### Step 3: Install Specific Versions

```bash
# List available versions for a plugin
asdf list all nodejs

# Install specific version
asdf install nodejs 20.10.0

# Install latest version
asdf install nodejs latest

# Install multiple versions
asdf install nodejs 18.19.0
asdf install nodejs 20.10.0
asdf install nodejs 21.5.0

# Verify installations
asdf list nodejs
```

#### Step 4: Set Active Version

```bash
# Set global version (used everywhere)
asdf global nodejs 20.10.0

# Set local version (for current directory)
asdf local nodejs 18.19.0

# Set shell version (for current shell session)
asdf shell nodejs 21.5.0

# Check current version
asdf current nodejs

# Verify it works
node --version
```

### Managing Versions

**View installed versions:**

```bash
# List all installed versions for all plugins
asdf list

# List versions for specific plugin
asdf list nodejs
asdf list python
```

**Uninstall versions:**

```bash
# Uninstall specific version
asdf uninstall nodejs 18.19.0

# Verify uninstallation
asdf list nodejs
```

**Update plugin:**

```bash
# Update specific plugin
asdf plugin update nodejs

# Update all plugins
asdf plugin update --all
```

### Project-Specific Versions

Use `.tool-versions` file to lock versions for a project:

#### Step 1: Create Project Directory

```bash
# Create a new project
mkdir /workspace/my-project
cd /workspace/my-project
```

#### Step 2: Set Local Versions

```bash
# Set versions for this project
asdf local nodejs 20.10.0
asdf local python 3.11.7

# This creates a .tool-versions file
cat .tool-versions

# Expected output:
# nodejs 20.10.0
# python 3.11.7
```

#### Step 3: Auto-Switch Versions

```bash
# When you cd into the directory, asdf automatically switches versions
cd /workspace/my-project
node --version  # Shows 20.10.0

cd /workspace
node --version  # Shows global version
```

## Popular Plugins

### Node.js

```bash
# Add plugin
asdf plugin add nodejs

# Install latest LTS
asdf install nodejs lts

# Install specific version
asdf install nodejs 20.10.0

# Set global version
asdf global nodejs 20.10.0

# Verify
node --version
npm --version
```

### Python

```bash
# Add plugin
asdf plugin add python

# Install latest
asdf install python latest

# Install specific version
asdf install python 3.11.7

# Set global version
asdf global python 3.11.7

# Verify
python --version
pip --version
```

### Ruby

```bash
# Add plugin
asdf plugin add ruby

# Install specific version
asdf install ruby 3.2.2

# Set global version
asdf global ruby 3.2.2

# Verify
ruby --version
gem --version
```

### Go (Golang)

```bash
# Add plugin
asdf plugin add golang

# Install latest
asdf install golang latest

# Set global version
asdf global golang latest

# Verify
go version
```

### Terraform

```bash
# Add plugin
asdf plugin add terraform

# Install specific version
asdf install terraform 1.6.6

# Set global version
asdf global terraform 1.6.6

# Verify
terraform --version
```

### kubectl

```bash
# Add plugin
asdf plugin add kubectl

# Install latest
asdf install kubectl latest

# Set global version
asdf global kubectl latest

# Verify
kubectl version --client
```

## Troubleshooting

### Plugin Installation Fails

**Symptoms:**

Plugin fails to install with dependency errors.

**Solution:**

```bash
# Update asdf
cd ~/.asdf
git pull origin master

# Update plugin repositories
asdf plugin update --all

# Try installing again
asdf plugin add nodejs
```

### Version Installation Fails

**Symptoms:**

Runtime version fails to install due to missing dependencies.

**Solutions:**

1. **Check plugin dependencies:**

   Most plugins document required system dependencies in their README.

   ```bash
   # For Node.js on Ubuntu
   apt-get install -y build-essential libssl-dev

   # For Python on Ubuntu
   apt-get install -y build-essential libssl-dev zlib1g-dev \
     libbz2-dev libreadline-dev libsqlite3-dev curl \
     libncursesw5-dev xz-utils tk-dev libxml2-dev \
     libxmlsec1-dev libffi-dev liblzma-dev
   ```

2. **Check installation logs:**

   ```bash
   # Installation logs are usually in ~/.asdf/
   cat ~/.asdf/installs/nodejs/20.10.0/build.log
   ```

3. **Try different version:**

   ```bash
   # Some versions may have build issues
   asdf list all nodejs | head -20
   asdf install nodejs 20.9.0
   ```

### Command Not Found After Installation

**Symptoms:**

After installing a runtime, commands are not found.

**Solutions:**

1. **Reshim asdf:**

   ```bash
   asdf reshim nodejs
   ```

2. **Check current version is set:**

   ```bash
   asdf current nodejs
   # Should show active version

   # If no version set, set global version
   asdf global nodejs 20.10.0
   ```

3. **Verify asdf is in PATH:**

   ```bash
   echo $PATH | grep asdf
   # Should show ~/.asdf/shims and ~/.asdf/bin
   ```

4. **Source asdf manually:**

   ```bash
   . ~/.asdf/asdf.sh
   ```

### .tool-versions Not Working

**Symptoms:**

asdf doesn't automatically switch versions when entering directory.

**Solutions:**

1. **Verify .tool-versions format:**

   ```bash
   cat .tool-versions
   # Each line should be: <plugin> <version>
   # Example:
   # nodejs 20.10.0
   # python 3.11.7
   ```

2. **Install missing versions:**

   ```bash
   # asdf will tell you if versions are missing
   asdf install
   ```

3. **Enable legacy version file support (optional):**

   ```bash
   # Create ~/.asdfrc if it doesn't exist
   echo "legacy_version_file = yes" > ~/.asdfrc

   # This allows asdf to read .node-version, .ruby-version, etc.
   ```

### Slow Plugin Operations

**Symptoms:**

Plugin list or installation is very slow.

**Solutions:**

1. **Update plugin list cache:**

   ```bash
   rm -rf ~/.asdf/repository
   asdf plugin list all
   ```

2. **Update specific plugin:**

   ```bash
   asdf plugin update nodejs
   ```

## Advanced Usage

### Custom Plugin Repository

Install plugins from custom repositories:

```bash
# Add plugin from custom repo
asdf plugin add custom-tool https://github.com/username/asdf-custom-tool.git

# Update custom plugin
asdf plugin update custom-tool
```

### Environment Variables

Configure asdf behavior with environment variables:

```bash
# Set asdf data directory
export ASDF_DATA_DIR=/custom/path/.asdf

# Set custom plugin directory
export ASDF_CONFIG_FILE=/custom/path/.asdfrc

# Disable version file resolution
export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME=.tool-versions
```

### Integration with Shell

Add asdf to your shell for auto-completion and better integration:

**Bash:**

```bash
# Add to ~/.bashrc
. ~/.asdf/asdf.sh
. ~/.asdf/completions/asdf.bash
```

**Zsh:**

```bash
# Add to ~/.zshrc
. ~/.asdf/asdf.sh
fpath=(${ASDF_DIR}/completions $fpath)
autoload -Uz compinit
compinit
```

### Using with Docker Compose

Create a development environment with asdf:

```yaml
version: '3.8'
services:
  dev:
    image: asdf:latest
    volumes:
      - ./project:/workspace/project
    working_dir: /workspace/project
    command: /bin/bash
    stdin_open: true
    tty: true
```

### CI/CD Integration

Use asdf in CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
name: CI
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: asdf:latest
    steps:
      - uses: actions/checkout@v3
      - name: Install dependencies
        run: |
          asdf plugin add nodejs
          asdf install
          npm install
      - name: Run tests
        run: npm test
```

## Cleanup

### Remove Installed Versions

**Uninstall specific versions:**

```bash
# Remove specific version
asdf uninstall nodejs 20.10.0

# Remove all versions of a plugin
asdf list nodejs | xargs -I {} asdf uninstall nodejs {}
```

### Remove Plugins

**Remove plugin and all its versions:**

```bash
# Remove plugin
asdf plugin remove nodejs

# This also removes all installed versions
```

### Container Cleanup

**Stop and remove Docker container:**

```bash
# Stop container
docker stop asdf-dev

# Remove container
docker rm asdf-dev

# Optional: Remove image
docker rmi asdf:latest
```

**Clean up Docker volumes:**

```bash
# Remove any persistent volumes
docker volume ls
docker volume rm <volume-name>
```

## Summary

**Key Takeaways:**

- asdf provides unified version management across multiple languages and
  tools
- Warpgate simplifies asdf deployment with reproducible builds
- Support for multiple architectures (amd64, arm64)
- Project-specific version configuration with `.tool-versions`
- Extensible plugin system for adding new tools
- Ideal for development environments and CI/CD pipelines

**Quick Command Reference:**

```bash
# Build asdf container
warpgate build asdf --arch amd64

# Run container
docker run -it --rm asdf:latest /bin/bash

# Add plugin
asdf plugin add <plugin-name>

# Install version
asdf install <plugin-name> <version>

# Set global version
asdf global <plugin-name> <version>

# List installed versions
asdf list

# Check current version
asdf current <plugin-name>
```

For more information about asdf, visit the [asdf
documentation](https://asdf-vm.com/guide/getting-started.html).
