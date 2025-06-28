# Network Topology Design Principles

This document outlines the key principles for designing the ChaseWhiteRabbit mesh network topology, optimized for Indonesian deployment scenarios with unreliable connectivity.

## Core Design Principles

### 1. Resilience Through Redundancy

The network is designed with multiple redundant paths to ensure continuous operation even when individual nodes or links fail:

- **Minimum 3-Way Connectivity**: Each node should connect to at least three other nodes when possible
- **Geographic Distribution**: Nodes should connect to others in different physical locations
- **Power Source Diversity**: Nodes should be distributed across different power grids
- **Carrier Diversity**: Connect through different ISPs or cellular providers when possible

### 2. Layered Architecture

The network is organized in three functional layers:

```
┌─────────────────────────────────────────────────────┐
│                  GATEWAY LAYER                      │
│  ┌───────────┐    ┌───────────┐    ┌───────────┐   │
│  │  Gateway  │    │  Gateway  │    │  Gateway  │   │
│  │  Jakarta  │◄►  │  Surabaya │◄►  │   Medan   │   │
│  └─────┬─────┘    └─────┬─────┘    └─────┬─────┘   │
└────────┼───────────────┼───────────────┼───────────┘
         ▼               ▼               ▼
┌─────────────────────────────────────────────────────┐
│                    RELAY LAYER                      │
│  ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐ │
│  │ Relay │ │ Relay │ │ Relay │ │ Relay │ │ Relay │ │
│  └───┬───┘ └───┬───┘ └───┬───┘ └───┬───┘ └───┬───┘ │
└──────┼─────────┼─────────┼─────────┼─────────┼──────┘
       ▼         ▼         ▼         ▼         ▼
┌─────────────────────────────────────────────────────┐
│                    NODE LAYER                       │
│  ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐  │
│  │ N │ │ N │ │ N │ │ N │ │ N │ │ N │ │ N │ │ N │  │
│  └───┘ └───┘ └───┘ └───┘ └───┘ └───┘ └───┘ └───┘  │
└─────────────────────────────────────────────────────┘
```

- **Gateway Layer**: Internet-connected nodes with reliable power and connectivity
- **Relay Layer**: Intermediate nodes that strengthen the mesh and extend coverage
- **Node Layer**: Edge nodes serving end users and local applications

### 3. Dynamic Path Selection

The network autonomously adapts to changing conditions:

- **Latency-Based Routing**: Traffic automatically routed through fastest available path
- **Congestion Awareness**: Nodes monitor and avoid congested paths
- **Signal Strength Adaptation**: Wireless links adjust based on signal quality
- **Load Balancing**: Traffic distributed across multiple paths when available

### 4. Indonesian-Specific Considerations

Special considerations for Indonesian deployment:

- **Island Hopping**: Inter-island connections through multiple technologies (undersea cable, satellite, long-range WiFi)
- **Monsoon Resilience**: Node placement accounting for seasonal weather patterns
- **Power Instability**: All nodes equipped with UPS systems sized to local power reliability
- **Remote Areas**: Tiered bandwidth allocation giving priority to essential services

## Regional Network Design

### Java Region

```
                 [SINGAPORE]
                      │
                      ▼
┌──────────────┐   ┌─────┐   ┌───────────┐
│ Jakarta DC 1 │◄►│ GW1 │◄►│ Jakarta DC2 │
└──────┬───────┘   └─────┘   └─────┬─────┘
       │                           │
       ▼                           ▼
    ┌─────┐                     ┌─────┐
┌───┤ RL1 ├───┐             ┌───┤ RL2 ├───┐
│   └─────┘   │             │   └─────┘   │
▼             ▼             ▼             ▼
[N1]...[N4]  [N5]...[N8]   [N9]...[N12]  [N13]...[N16]
```

### Sumatra Region

```
          [SINGAPORE]
                │
                ▼
            ┌────────┐         ┌────────┐
            │Medan GW│◄───────►│Padang GW│
            └───┬────┘         └────┬───┘
                │                   │
          ┌─────┴─────┐       ┌────┴────┐
          ▼           ▼       ▼         ▼
       ┌─────┐     ┌─────┐  ┌─────┐   ┌─────┐
       │ RL1 │     │ RL2 │  │ RL3 │   │ RL4 │
       └──┬──┘     └──┬──┘  └──┬──┘   └──┬──┘
          │           │        │         │
          ▼           ▼        ▼         ▼
      [N1]...[N4]  [N5]...[N8] [N9]...[N12] [N13]...[N15]
```

## Deployment Guidelines

### Node Placement Principles

1. **Line of Sight**: Prioritize clear line of sight between wireless nodes
2. **Elevation**: Place nodes at highest practical point for maximum coverage
3. **Physical Security**: Secure nodes against unauthorized access and environmental hazards
4. **Power Access**: Ensure reliable power with backup options
5. **Maintenance Access**: Allow for safe physical access for maintenance

### Density Recommendations

| Environment | Node Density | Coverage Radius |
|-------------|--------------|----------------|
| Urban       | 1 per 500m   | 250-300m       |
| Suburban    | 1 per 1km    | 500-700m       |
| Rural       | 1 per 3-5km  | 1.5-2.5km      |
| Remote      | Strategic    | Up to 20km     |

### Scaling Strategy

1. **Core First**: Establish stable gateway and relay nodes before expanding
2. **Island Strategy**: Create fully-functional "islands" of connectivity then bridge them
3. **Gradual Densification**: Start with minimal viable mesh, then add nodes to increase reliability and bandwidth
4. **Priority Corridors**: Establish connectivity along high-traffic corridors first

## Fault Tolerance Mechanisms

1. **Automatic Rerouting**: Traffic automatically redirects around failed nodes or links
2. **Store-and-Forward**: Data buffered during connectivity interruptions
3. **Graceful Degradation**: Service quality reduces rather than fails during disruptions
4. **Offline Operation**: Core services continue functioning even when isolated from larger network

## Diagram Conventions

All network diagrams should use these standard conventions:

- **Gateways**: Rectangle with double border
- **Relays**: Hexagon
- **Nodes**: Circle
- **Stable Links**: Solid line
- **Intermittent Links**: Dashed line
- **High-Capacity Links**: Thick line
- **Backup/Emergency Links**: Dotted line

## Implementation Phases

1. **Phase 1: Core Infrastructure** - Gateway nodes and central relays
2. **Phase 2: Regional Coverage** - Extended relay network
3. **Phase 3: Edge Deployment** - Node layer for end-user connectivity
4. **Phase 4: Optimization** - Performance tuning and capacity upgrades

---

Refer to the `/node_config_templates` directory for specific configuration examples for each node type.

