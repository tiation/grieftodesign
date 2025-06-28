# Volunteer Node Operator Guide

This guide is for volunteers who want to contribute to the mesh network by operating relay or gateway nodes, which form the backbone of the network infrastructure.

## Table of Contents

1. [Introduction](#introduction)
2. [Volunteer Roles & Responsibilities](#volunteer-roles--responsibilities)
3. [Hardware Requirements](#hardware-requirements)
4. [Software Setup](#software-setup)
5. [Network Configuration](#network-configuration)
6. [Node Registration](#node-registration)
7. [Monitoring & Maintenance](#monitoring--maintenance)
8. [Troubleshooting](#troubleshooting)
9. [Best Practices](#best-practices)

## Introduction

Volunteer nodes form the backbone of our mesh network. Unlike client nodes that primarily consume network services, volunteer nodes actively contribute to network infrastructure by:

- **Relaying traffic** between other nodes
- **Extending network coverage** to underserved areas
- **Providing internet connectivity** to the entire mesh
- **Improving network resilience** through redundant paths
- **Enhancing overall network capacity** with strategic placement

Volunteer node operators are essential partners in our mission to provide reliable connectivity in challenging environments. Your contribution makes a direct impact on community access to information, education, and emergency services.

## Volunteer Roles & Responsibilities

There are two primary types of volunteer nodes:

### Relay Nodes

Relay nodes extend the mesh network's reach and create redundant communication paths. They:

- Connect multiple parts of the mesh network together
- Extend coverage to areas without direct line-of-sight to gateway nodes
- Provide multiple network paths to increase reliability
- Optimize traffic routing through strategic placement

**Responsibilities:**
- Maintain at least 95% uptime
- Monitor and report network issues
- Position equipment optimally
- Perform regular software updates
- Coordinate with network administrators

### Gateway Nodes

Gateway nodes provide internet connectivity to the entire mesh. They:

- Act as bridges between the mesh network and the internet
- Share bandwidth with the entire network
- Serve as primary connection points
- Provide DNS, local caching, and other services
- Handle network address translation (NAT)

**Additional Responsibilities:**
- Ensure stable internet connectivity
- Manage bandwidth allocation fairly
- Implement security measures to protect the network
- Monitor traffic for anomalies
- Maintain critical services

## Hardware Requirements

### Basic Requirements (All Volunteer Nodes)

| Component | Minimum Specs | Recommended Specs |
|-----------|---------------|-------------------|
| Processor | Dual-core 1GHz | Quad-core 1.5GHz or better |
| RAM | 1GB | 2GB or more |
| Storage | 16GB | 32GB or more |
| Network | 2× WiFi adapters | 3× WiFi adapters (for gateway) |
| Antennas | 5dBi omnidirectional | 8-12dBi directional for backhaul |
| Power | 5V/3A with surge protection | UPS or battery backup system |
| Enclosure | Weather-resistant | Waterproof with thermal management |

### Gateway Node Additional Hardware

| Component | Requirements |
|-----------|--------------|
| Ethernet | Gigabit NIC for internet uplink |
| CPU | Higher performance for routing/NAT |
| RAM | Additional 1GB for caching services |
| Storage | Additional 32GB+ for local content |
| Power backup | Minimum 4-hour runtime |

### Recommended Hardware Platforms

1. **Standard Deployment:**
   - Raspberry Pi 4 (4GB/8GB RAM)
   - Orange Pi PC Plus
   - ODROID-XU4

2. **High-Performance Deployment:**
   - PC Engines APU2
   - Intel NUC
   - Small form factor PC with low power consumption

3. **Antennas and WiFi:**
   - TP-Link N300 (entry-level)
   - Ubiquiti NanoStation (directional)
   - MikroTik wAP ac (high-performance)

### Environmental Considerations

- **Outdoor Installations:**
  - Use proper grounding for lightning protection
  - UV-resistant and waterproof enclosures
  - Temperature management (ventilation or fans)
  - Proper cable protection and strain relief

- **Power Considerations:**
  - Solar power options for remote sites
  - Deep cycle batteries for backup
  - Surge protection for all connections
  - Low-voltage disconnect to protect batteries

## Software Setup

### Base System Installation

1. **Download the volunteer node image:**
   ```bash
   wget https://meshnetwork.org/downloads/volunteer-node-v1.2.img.gz
   ```

2. **Flash the image to SD card/storage:**
   ```bash
   # Linux/Mac
   gunzip -c volunteer-node-v1.2.img.gz | sudo dd of=/dev/sdX bs=4M status=progress
   
   # Windows
   # Use Etcher or similar tool
   ```

3. **First Boot Configuration:**
   - Connect to the device via Ethernet or console
   - Login with default credentials: user `mesh`, password `volunteer`
   - Immediately change the default password
   ```bash
   passwd
   ```

4. **Update the system:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   sudo apt install mesh-tools curl jq speedtest-cli htop iperf3 -y
   ```

### Node Type Configuration

Run the node configuration wizard to set up the device according to its role:

```bash
sudo mesh-node-setup
```

The wizard will guide you through:
- Selecting node type (relay or gateway)
- Setting geographic coordinates
- Configuring network interfaces
- Setting up security parameters
- Creating monitoring accounts

### Gateway-Specific Setup

For gateway nodes, additional configuration is required:

1. **Internet Connection Sharing:**
   ```bash
   sudo mesh-gateway-setup
   ```

2. **Bandwidth Management:**
   ```bash
   sudo mesh-qos-setup
   ```
   This will configure Quality of Service rules to allocate bandwidth fairly.

3. **Local Caching (Optional but recommended):**
   ```bash
   sudo mesh-cache-setup
   ```
   This sets up a local content cache to reduce external bandwidth usage.

## Network Configuration

### Interface Configuration

Volunteer nodes require careful network interface configuration:

#### Relay Node Interfaces

1. **Management Interface:** 
   - For administration and device management
   - Usually eth0 or wlan0 in managed mode
   - Connected to your local network

2. **Mesh Interfaces:**
   - At least one dedicated for mesh communication
   - Typically wlan1 in 802.11s or ad-hoc mode
   - Optimized for mesh protocol operation

Example configuration:
```bash
sudo nano /etc/mesh-network/interfaces.conf
```

```
# Management interface
MGMT_IFACE="eth0"
MGMT_IP="192.168.1.10/24"
MGMT_GW="192.168.1.1"

# Mesh interface
MESH_IFACE="wlan1"
MESH_MODE="802.11s"  # Mesh mode
MESH_CHANNEL="6"     # WiFi channel
MESH_SSID="MeshNet-Backbone"
MESH_KEY="strong-mesh-password"
```

#### Gateway Node Interfaces

Gateway nodes need an additional interface for internet connectivity:

```
# Management interface
MGMT_IFACE="eth0"
MGMT_IP="192.168.1.10/24"
MGMT_GW="192.168.1.1"

# Internet uplink interface
WAN_IFACE="eth1"
WAN_MODE="dhcp"      # or static

# Mesh interface
MESH_IFACE="wlan1"
MESH_MODE="802.11s"  # Mesh mode
MESH_CHANNEL="6"     # WiFi channel
MESH_SSID="MeshNet-Backbone"
MESH_KEY="strong-mesh-password"
```

### Mesh Network Configuration

Configure the mesh network settings:

```bash
sudo nano /etc/mesh-network/mesh.conf
```

Example configuration:
```
# Mesh network settings
MESH_ID="IndonesiaMesh"
MESH_PROTOCOL="batman-adv"  # Mesh routing protocol
MESH_ROUTING="dynamic"      # Dynamic routing enabled
MESH_METRIC="etx"           # Expected transmission count metric

# For gateway nodes only
IS_GATEWAY=true
ANNOUNCE_GATEWAY=true
BANDWIDTH_UP="5000"         # Kbps upload to offer
BANDWIDTH_DOWN="20000"      # Kbps download to offer
```

Apply the mesh configuration:
```bash
sudo mesh-config-apply
```

## Node Registration

### Preparing for Registration

Before registering your node, gather the following information:

1. Your GPS coordinates (use a smartphone app for accuracy)
2. A description of the node's physical location
3. Commitment level (hours per week for maintenance)
4. Your contact information
5. Internet connection details (for gateway nodes)

### Using the Registration Script

The easiest way to register is using our provided script:

```bash
cd /opt/mesh-dashboard
./scripts/add-volunteer.sh
```

The interactive script will:
1. Collect required information
2. Generate a unique node ID
3. Submit registration to the admin server
4. Configure automatic heartbeats

### Manual Registration Process

If the script isn't available, you can manually register:

1. **Generate node information file:**
   ```bash
   sudo mesh-info > node-info.json
   ```

2. **Edit the file to include required details:**
   ```bash
   nano node-info.json
   ```

3. **Submit registration:**
   ```bash
   curl -X POST http://admin-server:5000/api/register-node \
     -H "Content-Type: application/json" \
     -d @node-info.json
   ```

### Post-Registration

After successful registration:

1. Note your assigned node ID
2. Set up heartbeat monitoring
3. Configure any authentication tokens
4. Test connectivity with other mesh nodes

## Monitoring & Maintenance

### Daily Monitoring

Set up your node to automatically report status:

```bash
sudo mesh-heartbeat-setup
```

This creates a cron job to send regular status updates to the admin server.

### Regular Maintenance Tasks

#### Weekly Maintenance

1. **Software updates:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   sudo mesh-update
   ```

2. **Log rotation and cleanup:**
   ```bash
   sudo mesh-cleanup
   ```

3. **Performance check:**
   ```bash
   sudo mesh-performance-test
   ```

#### Monthly Maintenance

1. **Physical inspection:**
   - Check cables and connections
   - Clean dust from vents and enclosures
   - Verify antenna alignment
   - Check for water intrusion or damage

2. **Security audit:**
   ```bash
   sudo mesh-security-check
   ```

3. **Full diagnostic:**
   ```bash
   sudo mesh-diagnostic --full
   ```

### Performance Optimization

1. **Analyze current performance:**
   ```bash
   sudo mesh-analyze
   ```

2. **Adjust channel settings based on interference:**
   ```bash
   sudo mesh-channel-scan
   sudo mesh-set-channel optimal
   ```

3. **Optimize antenna positioning:**
   ```bash
   sudo mesh-signal-monitor
   ```
   Run this while adjusting antenna position to find optimal signal.

## Troubleshooting

### Common Issues

| Issue | Symptoms | Troubleshooting Steps |
|-------|----------|----------------------|
| Connectivity Loss | Mesh node unreachable | Check power, reboot device, verify interface status |
| Poor Performance | Slow speeds, high latency | Run mesh-diagnostic, check interference, verify antenna positioning |
| Gateway Issues | No internet access | Check WAN connection, verify routing tables, restart gateway services |
| Overheating | Random restarts, throttling | Check ventilation, clean dust, add cooling if needed |
| Power Problems | Intermittent operation | Verify power supply, check input voltage, add UPS |

### Diagnostic Commands

```bash
# Check mesh status
sudo mesh-status

# View connection quality to neighbors
sudo mesh-neighbors

# Test bandwidth within mesh
sudo iperf3 -c [other-node-ip]

# Check for interference
sudo mesh-wifi-analyzer

# View system resource usage
sudo htop
```

### Recovery Procedures

#### Basic Recovery

1. Reboot the system:
   ```bash
   sudo reboot
   ```

2. Reset mesh service:
   ```bash
   sudo systemctl restart mesh-network
   ```

#### Advanced Recovery

1. Factory reset (preserves registration):
   ```bash
   sudo mesh-factory-reset --preserve-registration
   ```

2. Recovery mode for severe issues:
   ```bash
   sudo mesh-recovery
   ```
   Follow the guided recovery process.

## Best Practices

### Strategic Placement

1. **Height is Crucial**
   - Place nodes at the highest practical location
   - Clear line-of-sight improves mesh performance dramatically
   - Avoid dense foliage or metal obstructions

2. **Coverage Planning**
   - Use the mesh coverage visualization tool:
     ```bash
     sudo mesh-coverage-map
     ```
   - Aim for 30-40% overlap between node coverage areas
   - Consider seasonal changes (foliage, weather)

### Security

1. **Regular Updates**
   - Set automatic updates for security patches
     ```bash
     sudo mesh-auto-update --security-only
     ```

2. **Access Control**
   - Use strong passwords
   - Enable SSH key authentication only
   - Restrict management interface access
     ```bash
     sudo mesh-restrict-access
     ```

3. **Network Isolation**
   - Separate mesh traffic from management
   - Use VLANs where possible
   - For gateways, implement proper firewall rules

### Community Engagement

1. **Document Your Setup**
   - Record antenna heights, orientations
   - Document power considerations
   - Share your setup with other volunteers

2. **Join Regional Support Groups**
   - Participate in monthly volunteer calls
   - Join the regional Telegram/Signal group
   - Share knowledge and solutions

3. **Train a Backup Person**
   - Ensure someone else knows basics
   - Document access information securely
   - Share emergency procedures

---

## Getting Help

- **Technical Support:** volunteer-support@meshnetwork.org
- **Emergency Issues:** +62-xxx-xxxx (24/7 hotline)
- **Knowledge Base:** https://wiki.meshnetwork.org/volunteer/
- **Community Forum:** https://community.meshnetwork.org/volunteer/

Remember: Your volunteer node is a critical part of our community network. Your dedication helps keep communities connected during normal times and emergencies alike.

