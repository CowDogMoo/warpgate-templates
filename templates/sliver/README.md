# Sliver C2 Warp Gate Template

This template builds **Sliver C2** images using Warp Gate. It supports building both **Docker images** (for `amd64` and `arm64`) and AWS **AMIs** (Ubuntu-based EC2 images). The build provisions all required packages, sets up tools, and runs Ansible roles to configure the system for robust TTP simulation and testing workflows.

---

## Requirements

- [Warp Gate](https://github.com/l50/warpgate) installed and configured
- Docker (for building Docker images)
- AWS credentials with permissions to create AMIs (for AMI builds)
- Arsenal provisioning repository with the `ARSENAL_REPO_PATH` environment variable set
- Required Packer plugins (installed automatically via `warpgate init`):
  - `amazon`
  - `docker`
  - `ansible`

---

## Configuration

The template configuration is managed in `warpgate.yaml`. Key settings include:

- `name`: Template name (`sliver`)
- `base.image`: Base Docker image (Ubuntu 25.04)
- `provisioners`: Shell and Ansible provisioners for setup
- `targets`: Defines build targets (container images and AMIs)

Environment variables required:
- `ARSENAL_REPO_PATH`: Path to your ansible-collection-arsenal repository

---

## Building Docker Images

This builds **Sliver** Docker images for `amd64` and `arm64` architectures, installs prerequisites, and provisions using Ansible roles.

**Initialize the template:**

```bash
warpgate init sliver
```

**Build Docker images:**

```bash
export ARSENAL_REPO_PATH="${HOME}/ansible-collection-arsenal"
warpgate build sliver --only 'docker.*'
```

After the build, multi-arch Sliver Docker images will be available locally as `sliver:latest`.

---

## Building AWS AMIs

To build an AWS AMI (Ubuntu-based, via `amazon-ebs`):

```bash
export ARSENAL_REPO_PATH="${HOME}/ansible-collection-arsenal"
warpgate build sliver --only 'amazon-ebs.*'
```

> 🛡️ Ensure your AWS credentials are configured and your IAM permissions allow SSM usage and AMI creation.

---

## Pushing Docker Images to GitHub Container Registry

After building the Docker image, you can push it to GHCR:

```bash
# Tag the image
docker tag sliver:latest ghcr.io/YOUR_NAMESPACE/sliver:latest

# Authenticate with GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin

# Push the image
docker push ghcr.io/YOUR_NAMESPACE/sliver:latest
```

---

## Validating the Template

To validate the template configuration before building:

```bash
warpgate validate sliver
```

---

## Notes

- The build uses both **shell and Ansible provisioners**. Ensure your Arsenal provisioning playbooks and requirement files are available at the path specified by `ARSENAL_REPO_PATH`.
- **AMI build:**
  - Creates and tags an AMI in your AWS account.
  - Designed to use SSM (Session Manager) for connections where possible.
  - Default region: `us-east-1`
  - Default instance type: `t3.micro`
  - Default volume size: 50GB
- **Docker build:**
  - Multi-arch (`amd64` + `arm64`) and privileged for full testbed support.
  - Images are suitable for CI, local testing, or deployment in a Kubernetes cluster.
  - Default user: `sliver`
  - Working directory: `/home/sliver`
- The Sliver binaries are installed in `/opt/sliver` and added to the PATH.
- The build includes cleanup steps to remove temporary files and Ansible artifacts.

---

## Customization

To customize the build, edit the `warpgate.yaml` file:

- Modify `base.image` to use a different base image
- Add or remove provisioning steps in the `provisioners` section
- Adjust `targets` to change build platforms or AMI settings
- Update environment variables in provisioners to change Ansible behavior

For more information on Warp Gate template configuration, see the [Warp Gate documentation](https://github.com/l50/warpgate).
