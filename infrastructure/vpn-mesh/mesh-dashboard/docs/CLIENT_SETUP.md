# Client Node Setup Guide

This comprehensive guide will walk you through setting up and configuring a client node for the mesh network. A client node allows end users to connect to the mesh network and access its services.

## Table of Contents

1. [Overview](#overview)
2. [Hardware Requirements](#hardware-requirements)
3. [Software Prerequisites](#software-prerequisites)
4. [Installation](#installation)
5. [Network Configuration](#network-configuration)
6. [Node Registration](#node-registration)
7. [Testing and Verification](#testing-and-verification)
8. [Troubleshooting](#troubleshooting)
9. [Maintenance](#maintenance)
10. [Getting Help](#getting-help)

## Overview

Client nodes serve as access points for end users to connect to the mesh network. They typically:

- Provide WiFi connectivity for user devices
- Forward traffic to relay or gateway nodes
- May offer local caching for improved performance
- Report status to the admin server

This guide will walk you through the entire setup process, from hardware selection to network integration.

## Hardware Requirements

### Minimum Specifications

| Component | Minimum Requirements | Recommended |
|-----------|---------------------|------------|
| CPU | Single-core 1GHz | Dual-core 1.2GHz or better |
| RAM | 512MB | 1GB or more |
| Storage | 8GB | 16GB or more |
| Network | 1× WiFi adapter | 2× WiFi adapters (one for mesh, one for clients) |
| Power | 5V/2A supply | 5V/3A with battery backup |
| Antennas | Built-in | 5-8dBi external for better range |

### Recommended Platforms

- **Raspberry Pi 3B/3B+/4B** - Good all-around performance
- **Orange Pi PC Plus** - Cost-effective alternative
- **GL.iNet GL-AR300M** - Compact, low power usage
- **PC Engines ALIX/APU** - Higher performance, multiple interfaces
- **Ubiquiti EdgeRouter X** - For advanced deployments

### Additional Components

- **Weatherproof enclosure** (if outdoor deployment)
- **External antenna** (for extended range)
- **Battery backup** (for areas with unreliable power)
- **Surge protector** (for lightning protection)

## Software Prerequisites

Before installation, ensure you have:

1. **Image Writer Software**:
   - For Windows: [Rufus](https://rufus.ie/) or [Etcher](https://www.balena.io/etcher/)
   - For macOS: [Etcher](https://www.balena.io/etcher/)
   - For Linux: `dd` command or [Etcher](https://www.balena.io/etcher/)

2. **Network Tools**:
   - SSH client
   - Network scanner (like Fing or Angry IP Scanner)
   - WiFi analyzer app (for channel selection)

3. **Admin Server Information**:
   - Admin server IP address or hostname
   - Registration credentials (if required)

## Installation

### Downloading the Image

1. Visit the mesh network website or repository
2. Download the latest client node image:
   ```bash
   wget https://meshnetwork.org/downloads/client-node-latest.img.gz
   ```

3. Verify the image integrity:
   ```bash
   sha256sum client-node-latest.img.gz
   ```
   
   Compare this with the published checksum on the website.

### Flashing the Image

1. **Extract the image**:
   ```bash
   gunzip client-node-latest.img.gz
   ```

2. **Flash to SD card/storage**:
   
   For Linux/macOS:
   ```bash
   sudo dd if=client-node-latest.img of=/dev/sdX bs=4M status=progress
   ```
   Replace `/dev/sdX` with your SD card device.
   
   For Windows:
   - Use Rufus or Etcher following the application's instructions

3. **First Boot Setup**:
   - Insert the SD card into your device
   - Connect the device to ethernet (recommended for first boot)
   - Power on the device
   - Wait 2-3 minutes for initial setup to complete

### Initial Access

1. **Find the device's IP address** using one of these methods:
   - Check your router's DHCP client list
   - Use a network scanner
   - Connect via default IP: 192.168.4.1 (if no DHCP server is available)

2. **Access options**:

   **Via SSH**:
   ```bash
   ssh mesh@<device-ip>
   ```
   Default password: `meshnetwork`

   **Via Web Interface** (if available):
   - Open browser and navigate to: `http://<device-ip>:8080`
   - Default credentials: 
     - Username: `admin`
     - Password: `meshnetwork`

3. **Change the default password immediately**:
   ```bash
   passwd
   ```

4. **Install required packages** (if not using the pre-built image):
   ```bash
   sudo apt update && sudo apt upgrade -y
   sudo apt install -y hostapd dnsmasq batctl bridge-utils curl jq
   
   # Install mesh dashboard client
   wget https://meshnetwork.org/downloads/mesh-client-installer.sh
   chmod +x mesh-client-installer.sh
   sudo ./mesh-client-installer.sh
   ```

## Network Configuration

### Basic Setup

1. Run the setup wizard:
   ```bash
   sudo mesh-setup
   ```
   This interactive wizard will guide you through the basic configuration.

2. Configure network interfaces via the web interface (if available):
   - Navigate to: `http://<device-ip>:8080`
   - Log in with your credentials
   - Go to `Network > Interfaces`

### Manual Configuration

For advanced users who prefer manual configuration:

1. Edit the network configuration file:
   ```bash
   sudo nano /etc/mesh-network/interfaces.conf
   ```

2. Configure the interfaces:
   ```
   # Uplink interface (connects to internet or mesh)
   UPLINK_IFACE="wlan0"
   UPLINK_MODE="managed"  # For connecting to existing WiFi
   
   # Service interface (provides WiFi for users)
   SERVICE_IFACE="wlan1"
   SERVICE_MODE="ap"      # Access Point mode
   SERVICE_SSID="MeshNet-Client"
   SERVICE_PASSPHRASE="your-secure-passphrase"
   ```

3. Configure the mesh settings:
   ```bash
   sudo nano /etc/mesh-network/mesh.conf
   ```

   ```
   # Mesh network settings
   MESH_NAME="MeshNetMain"
   MESH_PASSWORD="your-secure-mesh-password"
   MESH_GATEWAY="192.168.10.1"  # Primary gateway node
   MESH_BACKUP="192.168.10.2"   # Backup gateway
   ```

4. Configure the WiFi access point:
   ```bash
   sudo nano /etc/hostapd/hostapd.conf
   ```

   ```
   interface=wlan1
   driver=nl80211
   ssid=MeshNet-ClientNode
   hw_mode=g
   channel=7
   wmm_enabled=0
   macaddr_acl=0
   auth_algs=1
   wpa=2
   wpa_passphrase=your-secure-wifi-password
   wpa_key_mgmt=WPA-PSK
   wpa_pairwise=TKIP
   rsn_pairwise=CCMP
   ```

5. Apply all configurations:
   ```bash
   sudo mesh-apply-network
   sudo mesh-connect
   ```


3. **Security updates**:
   ```bash
   sudo mesh-security-check
   sudo mesh-apply-security
   ```

### Bandwidth Profile Optimization

Adjust bandwidth settings based on actual connectivity:

```bash
# Analyze current usage patterns
sudo mesh-analyze-bandwidth

# Apply recommended profile
sudo mesh-set-profile recommended
```

---

## Getting Help

If you encounter issues not covered in this guide:

- Check the community wiki
- Join the regional support group on Telegram
- Email support at client-support@meshnetwork.org

Remember: Your client node extends the network to new users. Its performance and reliability directly impact their experience.

