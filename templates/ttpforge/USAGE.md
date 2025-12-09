# Building and Using TTPForge with Warpgate

Complete guide to building and deploying TTPForge for adversary emulation
using Warpgate.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Building TTPForge Container](#building-ttpforge-container)
- [Using TTPForge](#using-ttpforge)
  - [Running TTPs](#running-ttps)
  - [Creating Custom TTPs](#creating-custom-ttps)
  - [TTP Repository Structure](#ttp-repository-structure)
- [Common TTPs](#common-ttps)
- [Troubleshooting](#troubleshooting)
- [Advanced Usage](#advanced-usage)
- [Cleanup](#cleanup)

## Overview

This guide demonstrates how to build TTPForge images using Warpgate for
executing Tactics, Techniques, and Procedures (TTPs) in adversary emulation
and security testing environments.

**What is TTPForge?**

TTPForge is a purple teaming framework designed to:

- Execute TTPs (Tactics, Techniques, and Procedures) in a structured format
- Support adversary emulation workflows for security testing
- Provide a declarative YAML-based syntax for defining attack procedures
- Enable reproducible security testing and validation
- Integrate with MITRE ATT&CK framework mappings
- Facilitate collaboration between red and blue teams

**Why use Warpgate for TTPForge?**

- Reproducible builds with version-controlled templates
- Multi-architecture support (amd64, arm64)
- Consistent environment across teams and CI/CD pipelines
- Easy deployment to container orchestration platforms
- Pre-configured with necessary dependencies

## Prerequisites

**Required:**

- Docker or Podman installed and running
- Warpgate installed ([installation guide](../README.md#installation))
- Provisioning repository with TTPForge playbooks
- Basic understanding of adversary emulation and TTPs
- Authorization for security testing activities

**For production use:**

- Proper authorization for security testing
- Isolated network environment
- Understanding of legal and ethical boundaries
- Appropriate logging and monitoring

## Quick Start

Get TTPForge running in 5 minutes:

```bash
# Build TTPForge container image
warpgate build ttpforge --arch amd64

# Run TTPForge container
docker run -it --rm \
  --name ttpforge \
  ttpforge:latest \
  /bin/bash

# Inside container, check TTPForge is installed
ttpforge --version

# Run a basic TTP (example)
ttpforge run /path/to/ttp.yaml
```

## Building TTPForge Container

### Using Warpgate Template

**Build from template name:**

```bash
# Build for amd64
warpgate build ttpforge --arch amd64

# Build for arm64
warpgate build ttpforge --arch arm64

# Build for both architectures
warpgate build ttpforge --arch amd64,arm64
```

**Verify the build:**

```bash
# Check image was created
docker images | grep ttpforge

# Expected output:
# ttpforge    latest    abc123def456    2 minutes ago    800MB
```

### Building with Custom Provision Path

If your template requires an Ansible collection:

```bash
# Build with variable override
warpgate build ttpforge --var PROVISION_REPO_PATH=/path/to/ansible-collection-arsenal

# Or use a variable file
cat > ttpforge-vars.yaml <<EOF
PROVISION_REPO_PATH: /path/to/ansible-collection-arsenal
VERSION: 1.0.0
DEBUG: true
EOF

warpgate build ttpforge --var-file ttpforge-vars.yaml
```

## Using TTPForge

### Running TTPs

Once inside the TTPForge container, you can execute TTPs:

#### Step 1: Prepare TTP Files

TTPForge uses YAML files to define TTPs:

```yaml
# example-ttp.yaml
---
name: Example Discovery TTP
description: Perform basic system discovery
ttps:
  - name: System Information Gathering
    steps:
      - name: Get hostname
        command: hostname
      - name: Get OS information
        command: uname -a
      - name: List network interfaces
        command: ip addr show
      - name: Check current user
        command: whoami
```

#### Step 2: Run TTP

```bash
# Execute TTP file
ttpforge run example-ttp.yaml

# Run with verbose output
ttpforge run --verbose example-ttp.yaml

# Run specific TTP by name
ttpforge run --ttp "System Information Gathering" example-ttp.yaml
```

#### Step 3: Review Results

```bash
# TTPForge outputs results to stdout
# Results include:
# - Execution status (success/failure)
# - Command output
# - Timestamps
# - Error messages (if any)
```

### Creating Custom TTPs

Create your own TTP definitions for specific adversary behaviors:

#### Basic TTP Structure

```yaml
---
name: Custom TTP Name
description: Description of what this TTP does
mitre_attack_id: T1234  # Optional MITRE ATT&CK mapping

ttps:
  - name: Tactic Name
    description: What this tactic accomplishes

    steps:
      - name: Step description
        command: |
          # Command to execute
          echo "Executing step"

      - name: Another step
        script: |
          #!/bin/bash
          # Multi-line script
          for i in {1..5}; do
            echo "Iteration $i"
          done
```

#### Advanced TTP Features

**Conditional Execution:**

```yaml
steps:
  - name: Check if file exists
    command: test -f /etc/passwd
    continue_on_error: true

  - name: Read file if exists
    command: cat /etc/passwd
    when: previous_step_succeeded
```

**Environment Variables:**

```yaml
environment:
  TARGET_HOST: 192.168.1.100
  TARGET_PORT: 8080

steps:
  - name: Connect to target
    command: nc -zv $TARGET_HOST $TARGET_PORT
```

**Cleanup Actions:**

```yaml
cleanup:
  - name: Remove artifacts
    command: rm -f /tmp/test-file
  - name: Clear logs
    command: echo "" > /var/log/custom.log
```

### TTP Repository Structure

Organize your TTPs in a structured repository:

```text
ttp-repo/
├── discovery/
│   ├── system-info.yaml
│   ├── network-enum.yaml
│   └── process-list.yaml
├── persistence/
│   ├── cron-job.yaml
│   └── systemd-service.yaml
├── credential-access/
│   ├── ssh-key-discovery.yaml
│   └── password-files.yaml
└── defense-evasion/
    ├── clear-logs.yaml
    └── timestamp-modification.yaml
```

## Common TTPs

### Discovery TTPs

**System Information Gathering:**

```yaml
---
name: System Discovery
description: Gather system information
mitre_attack_id: T1082

ttps:
  - name: Collect System Details
    steps:
      - name: OS version
        command: cat /etc/os-release
      - name: Kernel version
        command: uname -r
      - name: CPU information
        command: lscpu
      - name: Memory information
        command: free -h
```

**Network Discovery:**

```yaml
---
name: Network Discovery
description: Enumerate network configuration
mitre_attack_id: T1016

ttps:
  - name: Network Enumeration
    steps:
      - name: List interfaces
        command: ip link show
      - name: Show routing table
        command: ip route show
      - name: List open ports
        command: ss -tuln
      - name: Check DNS configuration
        command: cat /etc/resolv.conf
```

### Persistence TTPs

**Cron Job Persistence:**

```yaml
---
name: Cron Persistence
description: Create persistent cron job
mitre_attack_id: T1053.003

ttps:
  - name: Create Cron Job
    steps:
      - name: Add cron job
        command: |
          (crontab -l 2>/dev/null; echo "*/5 * * * * /tmp/persist.sh") | crontab -
      - name: Verify cron job
        command: crontab -l

cleanup:
  - name: Remove cron job
    command: crontab -r
```

### Credential Access TTPs

**SSH Key Discovery:**

```yaml
---
name: SSH Key Discovery
description: Locate SSH private keys
mitre_attack_id: T1552.004

ttps:
  - name: Find SSH Keys
    steps:
      - name: Search for SSH keys
        command: find / -name "id_rsa" -o -name "id_dsa" 2>/dev/null
      - name: Check SSH config
        command: cat ~/.ssh/config 2>/dev/null || echo "No config found"
      - name: List authorized keys
        command: cat ~/.ssh/authorized_keys 2>/dev/null || echo "No authorized keys"
```

## Troubleshooting

### TTPForge Command Not Found

**Symptoms:**

`ttpforge` command is not found after container start.

**Solutions:**

1. **Verify TTPForge installation:**

   ```bash
   # Check if TTPForge binary exists
   ls -la /opt/ttpforge/

   # Check PATH
   echo $PATH
   ```

2. **Manually add to PATH:**

   ```bash
   export PATH=/opt/ttpforge:$PATH
   ```

3. **Verify build completed successfully:**

   ```bash
   # Rebuild if necessary
   warpgate build ttpforge --arch amd64
   ```

### TTP Execution Fails

**Symptoms:**

TTP execution fails with permission errors or command not found.

**Solutions:**

1. **Run as root:**

   ```bash
   # TTPForge container runs as root by default
   # If running as different user, switch to root
   su -
   ```

2. **Check command availability:**

   ```bash
   # Ensure required commands are installed
   which nc
   which nmap
   which curl

   # Install missing tools
   apt-get update && apt-get install -y netcat nmap curl
   ```

3. **Verify file paths:**

   ```bash
   # Ensure TTP file paths are correct
   ls -la /path/to/ttp.yaml
   ```

### YAML Syntax Errors

**Symptoms:**

TTPForge fails to parse YAML file.

**Solutions:**

1. **Validate YAML syntax:**

   ```bash
   # Use yamllint if available
   yamllint example-ttp.yaml

   # Or use Python
   python3 -c "import yaml; yaml.safe_load(open('example-ttp.yaml'))"
   ```

2. **Check indentation:**

   YAML is whitespace-sensitive. Ensure consistent indentation (2 or 4 spaces).

3. **Check for special characters:**

   Quote strings containing special characters:

   ```yaml
   command: "echo 'Hello: World'"
   ```

### Container Permissions Issues

**Symptoms:**

Cannot execute certain commands or access files.

**Solutions:**

1. **Run container with additional capabilities:**

   ```bash
   docker run -it --rm --privileged ttpforge:latest /bin/bash
   ```

2. **Mount volumes with appropriate permissions:**

   ```bash
   docker run -it --rm \
     -v /host/path:/container/path:ro \
     ttpforge:latest /bin/bash
   ```

## Advanced Usage

### Integrating with CI/CD

Use TTPForge in automated security testing pipelines:

```yaml
# Example GitHub Actions workflow
name: Security Testing
on: [push]

jobs:
  run-ttps:
    runs-on: ubuntu-latest
    container:
      image: ttpforge:latest
    steps:
      - uses: actions/checkout@v3

      - name: Run Discovery TTPs
        run: ttpforge run ttps/discovery/system-info.yaml

      - name: Run Persistence TTPs
        run: ttpforge run ttps/persistence/cron-job.yaml

      - name: Upload Results
        uses: actions/upload-artifact@v3
        with:
          name: ttp-results
          path: results/
```

### Custom TTP Libraries

Create reusable TTP libraries:

```bash
# Structure
ttp-library/
├── mitre-attack/
│   ├── discovery/
│   ├── persistence/
│   ├── privilege-escalation/
│   └── defense-evasion/
└── custom/
    ├── application-specific/
    └── infrastructure-specific/
```

### Environment-Specific Variables

Use environment variables for flexible TTP execution:

```yaml
---
name: Configurable Network Scan
description: Scan target network

environment:
  TARGET_NETWORK: ${TARGET_NETWORK:-192.168.1.0/24}
  SCAN_PORTS: ${SCAN_PORTS:-22,80,443}

ttps:
  - name: Network Scan
    steps:
      - name: Scan network
        command: nmap -p $SCAN_PORTS $TARGET_NETWORK
```

Run with custom values:

```bash
TARGET_NETWORK=10.0.0.0/24 SCAN_PORTS=22,3389 ttpforge run network-scan.yaml
```

### Logging and Reporting

Configure TTPForge for detailed logging:

```bash
# Run with detailed output
ttpforge run --verbose --log-file results.log example-ttp.yaml

# Generate JSON report
ttpforge run --output-format json --output results.json example-ttp.yaml
```

## Cleanup

### Remove TTP Artifacts

**Clean up after TTP execution:**

```bash
# Remove temporary files
rm -rf /tmp/ttpforge-*

# Clear command history
history -c

# Remove test files
rm -f /tmp/test-*
```

### Container Cleanup

**Stop and remove Docker container:**

```bash
# Stop container
docker stop ttpforge

# Remove container
docker rm ttpforge

# Optional: Remove image
docker rmi ttpforge:latest
```

**Clean up Docker volumes:**

```bash
# Remove any persistent volumes
docker volume ls
docker volume rm <volume-name>
```

## Summary

**Key Takeaways:**

- TTPForge provides a structured approach to adversary emulation
- YAML-based TTP definitions enable reproducible security testing
- Warpgate simplifies TTPForge deployment with reproducible builds
- Support for multiple architectures (amd64, arm64)
- Integration with MITRE ATT&CK framework
- Always obtain authorization before security testing

**Quick Command Reference:**

```bash
# Build TTPForge container
warpgate build ttpforge --arch amd64

# Run container
docker run -it --rm ttpforge:latest /bin/bash

# Execute TTP
ttpforge run ttp-file.yaml

# Run with verbose output
ttpforge run --verbose ttp-file.yaml

# Validate YAML
yamllint ttp-file.yaml
```

For more information about TTPForge, visit the [TTPForge
repository](https://github.com/facebookincubator/TTPForge).
