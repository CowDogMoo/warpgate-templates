# asdf Version Manager Warp Gate Template

This template builds **asdf version manager** images using Warp Gate. It supports building both **Docker images** (for `amd64` and `arm64`) and AWS **AMIs** (Ubuntu-based EC2 images). The build provisions a minimal container image with asdf installed, enabling easy management of multiple runtime versions for various programming languages and tools.

---

## Requirements

- [Warp Gate](https://github.com/l50/warpgate) installed and configured
- Docker (for building Docker images)
- AWS credentials with permissions to create AMIs (for AMI builds)
- Provisioning repository with the `PROVISION_REPO_PATH` environment variable set
- Required Packer plugins (installed automatically via `warpgate init`):
  - `amazon`
  - `docker`
  - `ansible`

---

## Configuration

The template configuration is managed in `warpgate.yaml`. Key settings include:

- `name`: Template name (`asdf`)
- `base.image`: Base Docker image (Ubuntu 22.04)
- `provisioners`: Shell and Ansible provisioners for setup
- `targets`: Defines build targets (container images and AMIs)

Environment variables required:

- `PROVISION_REPO_PATH`: Path to your provisioning repository

---

## Building Docker Images

This builds **asdf** Docker images for `amd64` and `arm64` architectures, installs prerequisites, and provisions using Ansible roles.

**Initialize the template:**

```bash
warpgate init asdf
```

**Build Docker images:**

```bash
export PROVISION_REPO_PATH="${HOME}/ansible-collections"
warpgate build asdf --only 'docker.*'
```

After the build, multi-arch asdf Docker images will be available locally as `asdf:latest`.

---

## Building AWS AMIs

To build an AWS AMI (Ubuntu-based, via `amazon-ebs`):

```bash
export PROVISION_REPO_PATH="${HOME}/ansible-collections"
warpgate build asdf --only 'amazon-ebs.*'
```

> 🛡️ Ensure your AWS credentials are configured and your IAM permissions allow SSM usage and AMI creation.

---

## Pushing Docker Images to GitHub Container Registry

After building the Docker image, you can push it to GHCR:

```bash
# Tag the image
docker tag asdf:latest ghcr.io/YOUR_NAMESPACE/asdf:latest

# Authenticate with GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin

# Push the image
docker push ghcr.io/YOUR_NAMESPACE/asdf:latest
```

The template includes a post-processor that automatically tags images as `ghcr.io/cowdogmoo/asdf`.

---

## Validating the Template

To validate the template configuration before building:

```bash
warpgate validate asdf
```

---

## Notes

- The build uses both **shell and Ansible provisioners**. Ensure your provisioning playbooks and requirement files are available at the path specified by `PROVISION_REPO_PATH`.
- **AMI build:**
  - Creates and tags an AMI in your AWS account.
  - Designed to use SSM (Session Manager) for connections where possible.
  - Default region: `us-east-1`
  - Default instance type: `t3.micro`
  - Default volume size: 50GB
- **Docker build:**
  - Multi-arch (`amd64` + `arm64`) suitable for various development workflows.
  - Images are ideal for CI/CD pipelines, local development, or as base images for other projects.
  - Default user: `asdf` (non-root user with sudo access)
  - Working directory: `/workspace`
  - Default shell: `/bin/bash`
- The asdf version manager is installed in `/home/asdf/.asdf` and added to the PATH.
- Environment variables configured:
  - `ASDF_DIR=/home/asdf/.asdf`
  - `ASDF_DATA_DIR=/home/asdf/.asdf`
  - `PATH` includes asdf shims and bin directories
- The build includes cleanup steps to remove temporary files and Ansible artifacts via `/tmp/post_ansible_cleanup.sh`.

---

## Using asdf in the Container

Once inside the container, you can use asdf to manage tool versions:

```bash
# List all available plugins
asdf plugin list all

# Add a plugin (e.g., Node.js)
asdf plugin add nodejs

# Install a specific version
asdf install nodejs 20.10.0

# Set global version
asdf global nodejs 20.10.0

# Verify installation
node --version
```

---

## Customization

To customize the build, edit the `warpgate.yaml` file:

- Modify `base.image` to use a different base image
- Add or remove provisioning steps in the `provisioners` section
- Adjust `targets` to change build platforms or AMI settings
- Update environment variables in provisioners to change Ansible behavior
- Modify user settings to change the default user from `asdf` to another username

For more information on Warp Gate template configuration, see the [Warp Gate documentation](https://github.com/l50/warpgate).

---

## About asdf

asdf is a CLI tool that manages multiple runtime versions with a single CLI tool. It provides a unified interface for version management across many languages and tools, eliminating the need for language-specific version managers. For more information, visit the [asdf website](https://asdf-vm.com/).
