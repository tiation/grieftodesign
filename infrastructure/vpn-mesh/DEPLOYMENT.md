# ChaseWhiteRabbit Mesh Network Deployment Guide

This guide provides step-by-step instructions for deploying and maintaining the ChaseWhiteRabbit mesh network, optimized for the Indonesian context with a focus on reliable connectivity in challenging environments.

## Table of Contents

1. [Pre-deployment Checklist](#1-pre-deployment-checklist)
2. [Node Installation Procedure](#2-node-installation-procedure)
3. [Network Profile Selection Guide](#3-network-profile-selection-guide)
4. [Troubleshooting Steps](#4-troubleshooting-steps)
5. [Performance Monitoring Guidelines](#5-performance-monitoring-guidelines)
6. [Staff Training Recommendations](#6-staff-training-recommendations)
7. [Success Stories](#7-success-stories)

## 1. Pre-deployment Checklist

### Site Assessment

- [ ] **Location Survey**
  - [ ] GPS coordinates recorded: _____________
  - [ ] Elevation: _______ meters
  - [ ] Terrain type: ________________
  - [ ] Photos taken of installation site
  - [ ] Line-of-sight to other nodes verified

- [ ] **Power Assessment**
  - [ ] Available power source: □ Mains □ Solar □ Generator □ Other: ________
  - [ ] Power reliability: _____ hours/day
  - [ ] Voltage fluctuations measured: _______ V
  - [ ] UPS/battery backup required: □ Yes □ No
  - [ ] Battery capacity needed: ______ Ah

- [ ] **Network Assessment**
  - [ ] Uplink options available: □ Fiber □ DSL □ 4G □ 3G □ Satellite
  - [ ] Signal strength measurements taken
  - [ ] Bandwidth baseline test performed: _____ Mbps Down / _____ Mbps Up
  - [ ] Latency baseline test performed: _____ ms
  - [ ] Packet loss baseline test performed: _____ %

- [ ] **Physical Security**
  - [ ] Equipment enclosure needs: □ Waterproof □ Lockable □ Ventilated
  - [ ] Site security assessment: □ Low risk □ Medium risk □ High risk
  - [ ] Security measures required: _____________________

### Equipment Preparation

- [ ] **Hardware Inventory**
  - [ ] Node computer (e.g., Raspberry Pi 4)
  - [ ] WiFi adapters (minimum 2)
  - [ ] Antennas and cables
  - [ ] Power supply and backup battery
  - [ ] Weatherproof enclosure
  - [ ] Mounting hardware
  - [ ] Tools required

- [ ] **Software Preparation**
  - [ ] Latest system image downloaded
  - [ ] Configuration files customized for site
  - [ ] Network profiles selected
  - [ ] Credentials and encryption keys generated
  - [ ] Offline documentation loaded

- [ ] **Community Engagement**
  - [ ] Local stakeholders identified and briefed
  - [ ] Site access permission obtained
  - [ ] Local point of contact assigned
  - [ ] Community benefits explained
  - [ ] Usage policies established

## 2. Node Installation Procedure

### Physical Installation

1. **Mounting the Node**
   - Choose optimal location with good line-of-sight to other nodes
   - Secure the weatherproof enclosure to a stable structure
   - Ensure proper grounding to protect against lightning
   - Position antennas for maximum coverage
   - Secure all cables with proper strain relief

   > **Success Tip**: For challenging mounting situations, the "Jakarta Method" using reinforced PVC pipe has proven effective in monsoon conditions.

2. **Power Setup**
   - Install UPS/battery backup system
   - Connect power supply with proper surge protection
   - Verify stable power output
   - Label all power connections
   - Setup automatic restart capabilities

   > **Remember**: In areas with frequent power issues, configuring proper shutdown scripts saves node repair time!

3. **Network Connections**
   - Connect uplink interface (WLAN0 or Ethernet)
   - Connect mesh interface (WLAN1)
   - Connect client service interface (WLAN2)
   - Secure all antennas and coaxial cables
   - Weatherproof external connections

### Software Configuration

1. **Basic System Setup**
   ```bash
   # Update the installed image
   sudo apt update && sudo apt upgrade -y
   
   # Set system hostname using standardized format
   sudo hostnamectl set-hostname node-ID-LOCATION-XX
   
   # Configure timezone appropriate for region
   sudo timedatectl set-timezone Asia/Jakarta
   
   # Enable essential services
   sudo systemctl enable mesh-network
   sudo systemctl enable bandwidth-monitor
   sudo systemctl enable node-watchdog
   ```

2. **Node Configuration**
   ```bash
   # Copy the appropriate node config
   sudo cp /opt/mesh-network/templates/node-config.conf /etc/mesh-network/node.conf
   
   # Edit the configuration with site-specific details
   sudo nano /etc/mesh-network/node.conf
   
   # Verify configuration
   sudo mesh-config-check
   
   # Apply configuration
   sudo systemctl restart mesh-network
   ```

3. **Network Profile Setup**
   ```bash
   # Copy the appropriate bandwidth profile
   sudo cp /opt/mesh-network/profiles/bandwidth-[PROFILE].conf /etc/mesh-network/bandwidth.conf
   
   # Apply network profile
   sudo mesh-apply-profile
   
   # Verify profile is active
   sudo mesh-profile-status
   ```

4. **Initial Testing**
   ```bash
   # Check node status
   sudo mesh-node-status
   
   # Test mesh connectivity
   sudo mesh-ping [NEIGHBORING-NODE]
   
   # Test bandwidth
   sudo mesh-bandwidth-test
   
   # Verify services are running
   sudo mesh-service-check
   ```

## 3. Network Profile Selection Guide

Choose the appropriate network profile based on available bandwidth, deployment context, and use case priorities.

### Profile Selection Matrix

| Profile | Bandwidth | Typical Use Cases | Recommended Regions |
|---------|-----------|-------------------|---------------------|
| extremely_limited | <64 Kbps | Emergency services, critical text comms | Remote Papua, disaster recovery |
| very_limited | 64-256 Kbps | Basic messaging, health data, limited web | Remote areas, outer islands |
| limited | 256-1024 Kbps | Standard usage, limited media | Rural Java/Sumatra, most of Sulawesi |
| moderate | 1-4 Mbps | Good all-around performance | Urban outskirts, small cities |
| good | 4-10 Mbps | Full service including video | Urban centers, Java main corridor |
| excellent | >10 Mbps | Maximum capacity | Jakarta, Surabaya, other major cities |

### Selection Procedure

1. **Measure Actual Connectivity**
   ```bash
   # Run the comprehensive network assessment
   sudo mesh-network-assess --full
   
   # Record the results
   Downlink: _____ Kbps
   Uplink: _____ Kbps
   Latency: _____ ms
   Packet Loss: _____ %
   Jitter: _____ ms
   ```

2. **Consider Environmental Factors**
   - Factor in time-based variations (business hours vs. night)
   - Consider seasonal changes (monsoon periods may reduce bandwidth)
   - Assess user density and expected load
   - Account for power reliability (lower profile may extend battery life)

3. **Apply the Appropriate Profile**
   ```bash
   # Apply the selected profile
   sudo mesh-set-profile [PROFILE_NAME]
   
   # Enable adaptive mode if conditions vary significantly
   sudo mesh-adaptive-enable
   
   # Schedule periodic reassessment
   sudo mesh-schedule-assessment --daily
   ```

> **Staff Tip**: When in doubt, start with a more conservative profile, then gradually increase capabilities as stability is confirmed.

## 4. Troubleshooting Steps

### Connectivity Issues

| Symptom | First Steps | Advanced Troubleshooting |
|---------|-------------|--------------------------|
| Node completely offline | Check power, physical connections, reboot | Check system logs, verify hardware functionality |
| Mesh connection lost | Check mesh interface, restart mesh service | Verify encryption keys, check for interference |
| Intermittent connectivity | Check signal strength, verify antenna positioning | Run interference scan, check for bandwidth congestion |
| Poor performance | Run bandwidth test, verify current profile | Analyze traffic patterns, check for resource bottlenecks |

### Common Issues and Solutions

1. **Cannot Connect to Mesh Network**
   ```bash
   # Check mesh interface status
   ip addr show wlan1
   
   # Restart mesh network service
   sudo systemctl restart mesh-network
   
   # Check for interface conflicts
   sudo mesh-debug interfaces
   
   # Verify mesh encryption key
   sudo mesh-verify-keys
   ```

2. **Poor Performance**
   ```bash
   # Check current bandwidth usage
   sudo mesh-bandwidth-usage
   
   # Check for resource bottlenecks
   htop
   
   # Check for interference on WiFi channels
   sudo iwlist wlan1 scan | grep Channel
   
   # Switch to a less congested channel
   sudo mesh-set-channel wlan1 [CHANNEL]
   ```

3. **Node Frequently Rebooting**
   ```bash
   # Check system logs
   sudo journalctl -b -1 -e
   
   # Check power supply stability
   sudo mesh-power-monitor
   
   # Check temperature issues
   sudo sensors
   
   # Enable enhanced stability mode
   sudo mesh-stability-mode enable
   ```

### Escalation Procedure

1. Attempt standard troubleshooting steps
2. Consult the offline documentation
3. Check the community knowledge base (when online)
4. Contact regional support coordinator:
   - Jakarta Region: +62-xxx-xxxx
   - Sumatra Region: +62-xxx-xxxx
   - Other Regions: +62-xxx-xxxx
5. For urgent issues, use the emergency SMS gateway

## 5. Performance Monitoring Guidelines

### Daily Monitoring Tasks

1. **Basic System Check**
   ```bash
   # Run the daily health check
   sudo mesh-health-check
   
   # Review output for any warnings
   
   # Check system resource usage
   sudo mesh-resource-usage
   ```

2. **Network Performance Verification**
   ```bash
   # Check mesh connections
   sudo mesh-connections
   
   # Verify bandwidth profile is appropriate
   sudo mesh-profile-status
   
   # Check error rates
   sudo mesh-error-statistics
   ```

3. **Service Health Verification**
   ```bash
   # Verify all services are running
   sudo mesh-service-check
   
   # Check local caching effectiveness
   sudo mesh-cache-stats
   
   # Verify DNS resolution is working
   dig @localhost google.com
   ```

### Weekly Maintenance Tasks

1. **System Updates**
   ```bash
   # Update package lists
   sudo apt update
   
   # Apply security patches
   sudo apt upgrade -y
   
   # Update mesh software if available
   sudo mesh-update --check-only
   sudo mesh-update --apply-if-safe
   ```

2. **Performance Optimization**
   ```bash
   # Run the optimization wizard
   sudo mesh-optimize
   
   # Clean up logs and temporary files
   sudo mesh-cleanup
   
   # Analyze traffic patterns and adjust profiles
   sudo mesh-analyze-traffic
   sudo mesh-adjust-profile --auto
   ```

3. **Security Verification**
   ```bash
   # Check for unauthorized access attempts
   sudo mesh-security-check
   
   # Verify integrity of configuration files
   sudo mesh-verify-configs
   
   # Rotate encryption keys if needed
   sudo mesh-rotate-keys --if-older-than 30d
   ```

### Performance Data Collection

- Use the monitoring dashboard when connected to the network
- Collect daily performance snapshots:
  ```bash
  sudo mesh-stats-collect --daily
  ```
- Use the data export tool for offline analysis:
  ```bash
  sudo mesh-export-stats --last 7d --format csv > weekly-stats.csv
  ```

## 6. Staff Training Recommendations

### Core Training Modules

1. **Basic Installation and Maintenance (2 Days)**
   - Hardware familiarization
   - Basic installation procedures
   - Routine maintenance tasks
   - Basic troubleshooting

2. **Advanced Configuration (2 Days)**
   - Custom network profiles
   - Performance optimization
   - Advanced troubleshooting
   - Security hardening

3. **Community Engagement (1 Day)**
   - Explaining network benefits
   - Basic user training
   - Gathering feedback
   - Community-based maintenance

### Self-Paced Learning

Utilize the offline learning resources included on each node:
- `/opt/mesh-network/docs/tutorials/` - Step-by-step guides
- `/opt/mesh-network/docs/videos/` - Visual demonstrations
- `/opt/mesh-network/docs/cheatsheets/` - Quick reference guides

### Peer Learning

Establish regional knowledge sharing sessions:
- Monthly virtual meetups when connectivity allows
- Quarterly in-person regional training
- "Node Champion" program to recognize expertise
- WhatsApp/Signal groups for regional teams

### Progress Tracking

Track and celebrate personal development:
- Maintenance completion record
- Problem resolution log
- Skill certification program
- "Mesh Master" recognition program

## 7. Success Stories

### Jakarta Urban Mesh

The Jakarta Urban Mesh deployment connected 15 community centers despite challenging signal environments. Key success factors:
- Strategic placement on rooftops
- Innovative antenna mounts to avoid interference
- Community volunteer involvement in maintenance
- Adaptive bandwidth profiles during peak hours

### Sulawesi Rural Deployment

The team in Sulawesi successfully maintained connectivity through monsoon season with:
- Enhanced weatherproofing techniques
- Solar + battery backup systems
- Store-and-forward message system during outages
- Creative mounting solutions using local materials

### Staff Spotlight: Budi's Remote Island Solution

Budi from the Maluku team developed an innovative relay mounting system using fishing boats to create a dynamic mesh network that adapts to tidal patterns. His solution now serves as a model for other island communities.

---

## Remember

- **Every node matters** - Each connection expands our community
- **Adapt and overcome** - Local innovation is our greatest strength
- **Document your solutions** - Your insights help the entire team
- **Celebrate progress** - Share success stories and recognize achievements

*This guide is continually improved based on field experiences. Share your feedback and suggestions with the team.*

