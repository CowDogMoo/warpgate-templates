# Building and Using Atomic Red Team with Warpgate

Complete guide to building and deploying Atomic Red Team for security control
validation using Warpgate.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Building Atomic Red Team Container](#building-atomic-red-team-container)
- [Using Atomic Red Team](#using-atomic-red-team)
  - [Running Atomic Tests](#running-atomic-tests)
  - [Testing by ATT&CK Technique](#testing-by-attck-technique)
  - [Testing by Tactic](#testing-by-tactic)
- [Common Test Scenarios](#common-test-scenarios)
- [Troubleshooting](#troubleshooting)
- [Security Considerations](#security-considerations)
- [Cleanup](#cleanup)

## Overview

This guide demonstrates how to build Atomic Red Team images using Warpgate for
validating security controls and detection capabilities.

**What is Atomic Red Team?**

Atomic Red Team is a library of simple, focused tests mapped to the MITRE
ATT&CK framework that provides:

- Pre-built attack technique tests for security validation
- MITRE ATT&CK framework alignment for coverage mapping
- Simple, focused tests that execute specific adversary behaviors
- Cross-platform support (Windows, macOS, Linux)
- Easy integration with automation and CI/CD pipelines
- Purple team collaboration between red and blue teams

**Why use Warpgate for Atomic Red Team?**

- Reproducible builds with version-controlled templates
- Multi-architecture support (amd64, arm64)
- Consistent environment across teams
- Easy deployment to container orchestration platforms
- Integration with CI/CD pipelines for continuous validation

## Prerequisites

**Required:**

- Docker or Podman installed and running
- Warpgate installed ([installation guide](../README.md#installation))
- Provisioning repository with Atomic Red Team playbooks
- Basic understanding of MITRE ATT&CK framework
- Authorization for security testing activities

**For production use:**

- Proper authorization for security testing
- Isolated test environment
- Understanding of legal and ethical boundaries
- Monitoring and logging infrastructure

## Quick Start

Get Atomic Red Team running in 5 minutes:

```bash
# Build Atomic Red Team container image
warpgate build atomic-red-team --arch amd64

# Run Atomic Red Team container
docker run -it --rm \
  --name atomic-red-team \
  atomic-red-team:latest \
  /bin/bash

# Inside container, verify installation
pwsh
Import-Module "~/AtomicRedTeam/invoke-atomicredteam/Invoke-AtomicRedTeam.psd1"

# List available atomics
Invoke-AtomicTest All -ShowDetailsBrief
```

## Building Atomic Red Team Container

### Using Warpgate Template

**Build from template name:**

```bash
# Build for amd64
warpgate build atomic-red-team --arch amd64

# Build for arm64
warpgate build atomic-red-team --arch arm64

# Build for both architectures
warpgate build atomic-red-team --arch amd64,arm64
```

**Verify the build:**

```bash
# Check image was created
docker images | grep atomic-red-team

# Expected output:
# atomic-red-team    latest    abc123def456    5 minutes ago    1.2GB
```

### Building with Custom Provision Path

If your template requires an Ansible collection:

```bash
# Build with variable override
warpgate build atomic-red-team --var PROVISION_REPO_PATH=/path/to/ansible-collection-arsenal

# Or use a variable file
cat > atomic-vars.yaml <<EOF
PROVISION_REPO_PATH: /path/to/ansible-collection-arsenal
VERSION: 1.0.0
DEBUG: true
EOF

warpgate build atomic-red-team --var-file atomic-vars.yaml
```

## Using Atomic Red Team

### Running Atomic Tests

Once inside the Atomic Red Team container, you can execute tests:

#### Step 1: Start PowerShell

```bash
# Start PowerShell
pwsh

# Import Invoke-AtomicRedTeam module
Import-Module "~/AtomicRedTeam/invoke-atomicredteam/Invoke-AtomicRedTeam.psd1"
```

#### Step 2: List Available Tests

```powershell
# Show all available atomic tests (brief)
Invoke-AtomicTest All -ShowDetailsBrief

# Show details for specific technique
Invoke-AtomicTest T1003 -ShowDetails

# Show only test names
Invoke-AtomicTest T1003 -ShowDetailsBrief
```

#### Step 3: Check Prerequisites

```powershell
# Check prerequisites for a technique
Invoke-AtomicTest T1003 -CheckPrereqs

# Get prerequisites automatically
Invoke-AtomicTest T1003 -GetPrereqs
```

#### Step 4: Execute Test

```powershell
# Run specific technique
Invoke-AtomicTest T1003

# Run specific test number
Invoke-AtomicTest T1003 -TestNumbers 1

# Run multiple tests
Invoke-AtomicTest T1003 -TestNumbers 1,2,3

# Run with custom parameters
Invoke-AtomicTest T1003 -TestNumbers 1 -InputArgs @{file_path="/tmp/test.txt"}
```

#### Step 5: Cleanup After Test

```powershell
# Cleanup after test execution
Invoke-AtomicTest T1003 -Cleanup

# Cleanup specific test
Invoke-AtomicTest T1003 -TestNumbers 1 -Cleanup
```

### Testing by ATT&CK Technique

**Discovery Techniques:**

```powershell
# T1082 - System Information Discovery
Invoke-AtomicTest T1082

# T1083 - File and Directory Discovery
Invoke-AtomicTest T1083

# T1087 - Account Discovery
Invoke-AtomicTest T1087

# T1018 - Remote System Discovery
Invoke-AtomicTest T1018
```

**Credential Access Techniques:**

```powershell
# T1003 - OS Credential Dumping
Invoke-AtomicTest T1003 -CheckPrereqs
Invoke-AtomicTest T1003

# T1552.001 - Credentials In Files
Invoke-AtomicTest T1552.001

# T1555 - Credentials from Password Stores
Invoke-AtomicTest T1555
```

**Persistence Techniques:**

```powershell
# T1053.003 - Scheduled Task/Job: Cron
Invoke-AtomicTest T1053.003

# T1098 - Account Manipulation
Invoke-AtomicTest T1098

# T1136 - Create Account
Invoke-AtomicTest T1136
```

**Defense Evasion Techniques:**

```powershell
# T1070 - Indicator Removal
Invoke-AtomicTest T1070

# T1562 - Impair Defenses
Invoke-AtomicTest T1562

# T1222 - File and Directory Permissions Modification
Invoke-AtomicTest T1222
```

### Testing by Tactic

**Run all tests for a tactic:**

```powershell
# Discovery tactic
$discoveryTechniques = @("T1082", "T1083", "T1087", "T1018", "T1016")
foreach ($technique in $discoveryTechniques) {
    Invoke-AtomicTest $technique
    Invoke-AtomicTest $technique -Cleanup
}

# Credential Access tactic
$credAccessTechniques = @("T1003", "T1552.001", "T1555")
foreach ($technique in $credAccessTechniques) {
    Invoke-AtomicTest $technique
    Invoke-AtomicTest $technique -Cleanup
}
```

## Common Test Scenarios

### Scenario 1: Basic Discovery Tests

Test if security tools detect basic system reconnaissance:

```powershell
# Import module
Import-Module "~/AtomicRedTeam/invoke-atomicredteam/Invoke-AtomicRedTeam.psd1"

# System Information Discovery
Write-Host "Testing T1082 - System Information Discovery"
Invoke-AtomicTest T1082
Start-Sleep -Seconds 5
Invoke-AtomicTest T1082 -Cleanup

# File and Directory Discovery
Write-Host "Testing T1083 - File and Directory Discovery"
Invoke-AtomicTest T1083
Start-Sleep -Seconds 5
Invoke-AtomicTest T1083 -Cleanup

# Network Service Scanning
Write-Host "Testing T1046 - Network Service Scanning"
Invoke-AtomicTest T1046
Start-Sleep -Seconds 5
Invoke-AtomicTest T1046 -Cleanup
```

### Scenario 2: Credential Access Validation

Test credential access detection capabilities:

```powershell
# Import module
Import-Module "~/AtomicRedTeam/invoke-atomicredteam/Invoke-AtomicRedTeam.psd1"

# Check prerequisites first
Write-Host "Checking prerequisites for T1003"
Invoke-AtomicTest T1003 -CheckPrereqs

# OS Credential Dumping
Write-Host "Testing T1003 - OS Credential Dumping"
Invoke-AtomicTest T1003 -TestNumbers 1
Start-Sleep -Seconds 5
Invoke-AtomicTest T1003 -TestNumbers 1 -Cleanup

# Credentials in Files
Write-Host "Testing T1552.001 - Credentials In Files"
Invoke-AtomicTest T1552.001
Start-Sleep -Seconds 5
Invoke-AtomicTest T1552.001 -Cleanup
```

### Scenario 3: Persistence Mechanism Testing

Test persistence detection:

```powershell
# Import module
Import-Module "~/AtomicRedTeam/invoke-atomicredteam/Invoke-AtomicRedTeam.psd1"

# Scheduled Task/Job: Cron
Write-Host "Testing T1053.003 - Scheduled Task/Job: Cron"
Invoke-AtomicTest T1053.003
Start-Sleep -Seconds 5
Invoke-AtomicTest T1053.003 -Cleanup

# Create Account
Write-Host "Testing T1136.001 - Create Local Account"
Invoke-AtomicTest T1136.001
Start-Sleep -Seconds 5
Invoke-AtomicTest T1136.001 -Cleanup
```

### Scenario 4: Defense Evasion Testing

Test defense evasion detection:

```powershell
# Import module
Import-Module "~/AtomicRedTeam/invoke-atomicredteam/Invoke-AtomicRedTeam.psd1"

# Clear Linux Logs
Write-Host "Testing T1070.002 - Clear Linux or Mac System Logs"
Invoke-AtomicTest T1070.002
Start-Sleep -Seconds 5
Invoke-AtomicTest T1070.002 -Cleanup

# File Deletion
Write-Host "Testing T1070.004 - File Deletion"
Invoke-AtomicTest T1070.004
Start-Sleep -Seconds 5
Invoke-AtomicTest T1070.004 -Cleanup
```

## Troubleshooting

### PowerShell Not Found

**Symptoms:**

`pwsh` command not found.

**Solutions:**

```bash
# Check if PowerShell is installed
which pwsh

# Install PowerShell if missing
apt-get update
apt-get install -y powershell

# Verify installation
pwsh --version
```

### Module Import Fails

**Symptoms:**

Cannot import Invoke-AtomicRedTeam module.

**Solutions:**

```bash
# Verify AtomicRedTeam directory exists
ls -la ~/AtomicRedTeam/

# Clone repository if missing
cd ~
git clone https://github.com/redcanaryco/atomic-red-team.git AtomicRedTeam

# In PowerShell, import with full path
pwsh
Import-Module "$HOME/AtomicRedTeam/invoke-atomicredteam/Invoke-AtomicRedTeam.psd1" -Force
```

### Test Prerequisites Not Met

**Symptoms:**

Test fails with prerequisite errors.

**Solutions:**

```powershell
# Check what prerequisites are needed
Invoke-AtomicTest T1003 -CheckPrereqs

# Automatically get prerequisites
Invoke-AtomicTest T1003 -GetPrereqs

# Manually install missing tools
# Example: Install tools needed for the test
apt-get update
apt-get install -y <required-package>
```

### Permission Denied Errors

**Symptoms:**

Tests fail with permission errors.

**Solutions:**

```bash
# Ensure running as root
whoami  # Should show 'root'

# Run container with privileged mode
docker run -it --rm --privileged atomic-red-team:latest /bin/bash

# In PowerShell, check execution policy
pwsh
Get-ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

### Cleanup Fails

**Symptoms:**

Cleanup command doesn't remove all artifacts.

**Solutions:**

```powershell
# Run cleanup with verbose output
Invoke-AtomicTest T1003 -Cleanup -Verbose

# Manual cleanup if needed
# Check what artifacts were created and remove manually
```

## Security Considerations

### Legal and Ethical Use

**CRITICAL: This tool is for authorized security testing only.**

**Before using Atomic Red Team:**

- ✅ Obtain written authorization for security testing
- ✅ Understand applicable laws in your jurisdiction
- ✅ Test only in isolated environments
- ✅ Document all testing activities
- ✅ Coordinate with blue team for detection validation

**Never:**

- ❌ Run tests on production systems without authorization
- ❌ Execute tests on systems you don't own or have permission to test
- ❌ Leave persistence mechanisms active after testing
- ❌ Skip cleanup steps after test execution

### Test Environment Isolation

**Container deployment:**

```bash
# Use isolated network
docker network create atomic-test-network
docker run -it --rm --network atomic-test-network atomic-red-team:latest

# No external network access
docker run -it --rm --network none atomic-red-team:latest
```

### Logging and Detection

**Monitor test execution:**

- Enable comprehensive logging before running tests
- Coordinate with SOC/blue team
- Document expected alerts and detections
- Compare actual vs. expected detection coverage

### Cleanup Verification

**Always verify cleanup:**

```powershell
# Run cleanup
Invoke-AtomicTest T1003 -Cleanup

# Verify artifacts removed
# Check for:
# - Created files
# - Modified permissions
# - Added accounts
# - Scheduled tasks
# - Log entries
```

## Cleanup

### Cleanup After Tests

**Clean up test artifacts:**

```powershell
# Cleanup specific test
Invoke-AtomicTest T1003 -Cleanup

# Cleanup all tests from a technique
Invoke-AtomicTest T1003 -Cleanup

# Manual verification
ls /tmp/
ps aux | grep -i atomic
```

### Container Cleanup

**Stop and remove Docker container:**

```bash
# Stop container
docker stop atomic-red-team

# Remove container
docker rm atomic-red-team

# Optional: Remove image
docker rmi atomic-red-team:latest
```

**Clean up Docker resources:**

```bash
# Remove stopped containers
docker container prune -f

# Remove unused networks
docker network prune -f
```

## Summary

**Key Takeaways:**

- Atomic Red Team provides simple, focused security control tests
- Tests map directly to MITRE ATT&CK framework
- Warpgate simplifies deployment with reproducible builds
- Support for multiple architectures (amd64, arm64)
- Always obtain authorization before security testing
- Always run cleanup after tests
- Coordinate with blue team for detection validation

**Quick Command Reference:**

```bash
# Build Atomic Red Team
warpgate build atomic-red-team --arch amd64

# Run container
docker run -it --rm atomic-red-team:latest /bin/bash

# Start PowerShell
pwsh

# Import module
Import-Module "~/AtomicRedTeam/invoke-atomicredteam/Invoke-AtomicRedTeam.psd1"

# List tests
Invoke-AtomicTest All -ShowDetailsBrief

# Run test
Invoke-AtomicTest T1003

# Cleanup
Invoke-AtomicTest T1003 -Cleanup
```

For more information about Atomic Red Team, visit the [Atomic Red Team
repository](https://github.com/redcanaryco/atomic-red-team).
