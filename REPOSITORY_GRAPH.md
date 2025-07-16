# Tiation Repository Dependency Graph

This visual representation shows how all repositories in the Tiation GitHub ecosystem are interconnected.

## Repository Relationship Diagram

```mermaid
graph TB
    %% Core Business Tier
    subgraph "Core Business"
        19TS[19-trillion-solution]
        CI[company-intranet]
        RC[RiggerConnect-RiggerJobs-Workspace-PB]
    end
    
    %% Infrastructure Tier
    subgraph "Infrastructure & DevOps"
        SCG[server-configs-gae]
        WF[workflows]
        GW[git-workspace]
        UDS[ubuntu-dev-setup]
        WDS[windows-dev-setup]
    end
    
    %% Creative Projects
    subgraph "Creative & Design"
        GTD[grieftodesign]
        CWR[ChaseWhiteRabbit]
        TA[TiaAstor]
    end
    
    %% Technical Libraries
    subgraph "Technical Foundation"
        CFR[core-foundation-rs]
        DRS[DiceRollerSimulator]
    end
    
    %% Social Impact
    subgraph "Social Impact & Advocacy"
        PCA[ProtectChildrenAustralia]
        AS[AlmaStreet]
        DBC[dontbeacunt]
        CSL[Case_Study_Legal]
        DAO[awesome-decentralized-autonomous-organizations]
    end
    
    %% Organization & Personal
    subgraph "Organization"
        T[tiation]
        H[home]
    end
    
    %% Primary Dependencies
    19TS --> CI
    19TS --> RC
    19TS --> SCG
    19TS --> WF
    
    CI --> SCG
    CI --> WF
    
    %% Infrastructure Dependencies
    GW --> UDS
    GW --> WDS
    GW --> WF
    
    UDS --> WF
    WDS --> WF
    
    WF --> SCG
    
    %% Creative Dependencies
    GTD --> TA
    GTD --> CWR
    CWR --> CFR
    
    %% Technical Dependencies
    CFR --> DRS
    CFR --> CWR
    
    %% Social Impact Dependencies
    PCA --> CSL
    PCA --> AS
    PCA --> DBC
    
    CSL --> DAO
    DAO --> 19TS
    
    %% Organization Dependencies
    T --> TA
    T --> 19TS
    
    H --> UDS
    H --> WDS
    
    %% Styling
    classDef core fill:#2E86AB,stroke:#1C5577,color:#fff
    classDef infra fill:#A23B72,stroke:#6E2850,color:#fff
    classDef creative fill:#F18F01,stroke:#A86301,color:#fff
    classDef tech fill:#C73E1D,stroke:#8A2A13,color:#fff
    classDef social fill:#6A994E,stroke:#4A6B36,color:#fff
    classDef org fill:#BC4B51,stroke:#833338,color:#fff
    
    class 19TS,CI,RC core
    class SCG,WF,GW,UDS,WDS infra
    class GTD,CWR,TA creative
    class CFR,DRS tech
    class PCA,AS,DBC,CSL,DAO social
    class T,H org
```

## Dependency Matrix

| Repository | Direct Dependencies | Dependent Repositories |
|------------|-------------------|----------------------|
| **19-trillion-solution** | company-intranet, RiggerConnect, server-configs-gae, workflows | awesome-decentralized-autonomous-organizations, tiation |
| **company-intranet** | 19-trillion-solution, workflows, server-configs-gae | - |
| **RiggerConnect-RiggerJobs-Workspace-PB** | 19-trillion-solution | - |
| **server-configs-gae** | workflows | 19-trillion-solution, company-intranet |
| **workflows** | server-configs-gae | All repositories (CI/CD) |
| **git-workspace** | ubuntu-dev-setup, windows-dev-setup, workflows | - |
| **ubuntu-dev-setup** | git-workspace, workflows, server-configs-gae | home |
| **windows-dev-setup** | git-workspace, workflows, server-configs-gae | home |
| **grieftodesign** | TiaAstor, ChaseWhiteRabbit | - |
| **ChaseWhiteRabbit** | grieftodesign, core-foundation-rs | - |
| **TiaAstor** | grieftodesign, tiation | - |
| **core-foundation-rs** | - | DiceRollerSimulator, ChaseWhiteRabbit |
| **DiceRollerSimulator** | core-foundation-rs | - |
| **ProtectChildrenAustralia** | Case_Study_Legal, AlmaStreet, dontbeacunt | - |
| **AlmaStreet** | ProtectChildrenAustralia | - |
| **dontbeacunt** | ProtectChildrenAustralia | - |
| **Case_Study_Legal** | ProtectChildrenAustralia, awesome-decentralized-autonomous-organizations | - |
| **awesome-decentralized-autonomous-organizations** | Case_Study_Legal, 19-trillion-solution | - |
| **tiation** | TiaAstor, 19-trillion-solution | All repositories (parent org) |
| **home** | ubuntu-dev-setup, windows-dev-setup | - |

## Integration Points

### CI/CD Integration
All repositories integrate with the `workflows` repository for continuous integration and deployment:
- Build automation
- Test execution
- Deployment pipelines
- Security scanning

### Infrastructure Integration
Deployed projects integrate with `server-configs-gae`:
- 19-trillion-solution
- company-intranet
- ProtectChildrenAustralia (if deployed)

### Development Environment Integration
All development projects can utilize:
- ubuntu-dev-setup
- windows-dev-setup
- git-workspace

### Legal & Compliance Integration
Projects requiring legal frameworks integrate with:
- Case_Study_Legal
- awesome-decentralized-autonomous-organizations (for DAO structures)

## Repository Categories

### 🏢 Enterprise Solutions
- 19-trillion-solution (flagship)
- company-intranet
- RiggerConnect-RiggerJobs-Workspace-PB

### 🛠 Development Infrastructure
- server-configs-gae
- workflows
- git-workspace
- ubuntu-dev-setup
- windows-dev-setup

### 🎨 Creative Projects
- grieftodesign
- ChaseWhiteRabbit
- TiaAstor

### 🔧 Technical Libraries
- core-foundation-rs
- DiceRollerSimulator

### 🏛 Social Impact
- ProtectChildrenAustralia
- AlmaStreet
- dontbeacunt
- Case_Study_Legal
- awesome-decentralized-autonomous-organizations

### 🏠 Organization & Personal
- tiation
- home

---

*This diagram is automatically generated based on repository relationships defined in [REPOSITORY_INDEX.md](./REPOSITORY_INDEX.md)*
