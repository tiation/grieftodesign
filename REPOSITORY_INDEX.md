# Tiation GitHub Repository Index

This index provides a comprehensive overview and cross-reference system for all repositories in the Tiation GitHub workspace.

## 🏢 Core Business Repositories

### [19-trillion-solution](./19-trillion-solution/)
The flagship solution repository containing enterprise-grade implementations and strategic business solutions.
- **Related**: [company-intranet](./company-intranet/), [RiggerConnect-RiggerJobs-Workspace-PB](./RiggerConnect-RiggerJobs-Workspace-PB/)
- **Documentation**: [Architecture Docs](./19-trillion-solution/docs/)

### [company-intranet](./company-intranet/)
Internal company portal and employee resources management system.
- **Related**: [19-trillion-solution](./19-trillion-solution/), [workflows](./workflows/)
- **Infrastructure**: [server-configs-gae](./server-configs-gae/)

### [RiggerConnect-RiggerJobs-Workspace-PB](./RiggerConnect-RiggerJobs-Workspace-PB/)
Specialized workspace for rigging industry job matching and workforce management.
- **Mobile App**: [RiggerConnectMobileApp](./RiggerConnect-RiggerJobs-Workspace-PB/RiggerConnectMobileApp/)
- **Related**: [19-trillion-solution](./19-trillion-solution/)

## 🎨 Creative & Design Projects

### [grieftodesign](./grieftodesign/)
Creative design projects focusing on transformative experiences and emotional design.
- **Portfolio**: [TiaAstor](./TiaAstor/)
- **Related**: [ChaseWhiteRabbit](./ChaseWhiteRabbit/)

### [ChaseWhiteRabbit](./ChaseWhiteRabbit/)
Interactive storytelling and immersive experience design project.
- **Tech Stack**: [core-foundation-rs](./core-foundation-rs/)
- **Related**: [grieftodesign](./grieftodesign/)

## 🛠 Development Tools & Infrastructure

### [git-workspace](./git-workspace/)
Centralized Git workflow management and automation tools.
- **CI/CD**: [workflows](./workflows/)
- **Related**: [ubuntu-dev-setup](./ubuntu-dev-setup/), [windows-dev-setup](./windows-dev-setup/)

### [ubuntu-dev-setup](./ubuntu-dev-setup/)
Ubuntu development environment configuration and setup scripts.
- **Related**: [windows-dev-setup](./windows-dev-setup/), [server-configs-gae](./server-configs-gae/)
- **Automation**: [workflows](./workflows/)

### [windows-dev-setup](./windows-dev-setup/)
Windows development environment configuration and setup scripts.
- **Related**: [ubuntu-dev-setup](./ubuntu-dev-setup/), [git-workspace](./git-workspace/)
- **Automation**: [workflows](./workflows/)

### [workflows](./workflows/)
GitHub Actions and CI/CD workflow definitions for all projects.
- **Used By**: All repositories
- **Infrastructure**: [server-configs-gae](./server-configs-gae/)

### [server-configs-gae](./server-configs-gae/)
Google App Engine server configurations and deployment scripts.
- **Related**: [company-intranet](./company-intranet/), [19-trillion-solution](./19-trillion-solution/)
- **Documentation**: [Infrastructure Docs](./server-configs-gae/docs/)

## 🎯 Specialized Projects

### [DiceRollerSimulator](./DiceRollerSimulator/)
Advanced dice rolling simulation engine with statistical analysis.
- **Tech Stack**: [core-foundation-rs](./core-foundation-rs/)
- **Related**: Gaming and simulation projects

### [core-foundation-rs](./core-foundation-rs/)
Rust-based core foundation libraries and utilities.
- **Used By**: [DiceRollerSimulator](./DiceRollerSimulator/), [ChaseWhiteRabbit](./ChaseWhiteRabbit/)
- **Documentation**: [API Docs](./core-foundation-rs/docs/)

### [awesome-decentralized-autonomous-organizations](./awesome-decentralized-autonomous-organizations/)
Curated list and resources for DAO development and governance.
- **Related**: [Case_Study_Legal](./Case_Study_Legal/)
- **Implementation**: [19-trillion-solution](./19-trillion-solution/)

## 🏛 Social Impact & Advocacy

### [ProtectChildrenAustralia](./ProtectChildrenAustralia/)
Child protection advocacy and resource platform.
- **Legal Framework**: [Case_Study_Legal](./Case_Study_Legal/)
- **Public Site**: [Website](https://protectchildrenaustralia.org) *(if applicable)*

### [AlmaStreet](./AlmaStreet/)
Community development and urban planning initiatives.
- **Related**: [ProtectChildrenAustralia](./ProtectChildrenAustralia/)
- **Resources**: [Community Docs](./AlmaStreet/docs/)

### [dontbeacunt](./dontbeacunt/)
Social awareness campaign for positive online behavior.
- **Related**: [ProtectChildrenAustralia](./ProtectChildrenAustralia/)
- **Resources**: [Campaign Materials](./dontbeacunt/materials/)

## 📚 Documentation & Legal

### [Case_Study_Legal](./Case_Study_Legal/)
Legal case studies and documentation templates.
- **Used By**: [ProtectChildrenAustralia](./ProtectChildrenAustralia/), [awesome-decentralized-autonomous-organizations](./awesome-decentralized-autonomous-organizations/)
- **Templates**: [Legal Templates](./Case_Study_Legal/templates/)

## 🏠 Personal & Portfolio

### [TiaAstor](./TiaAstor/)
Personal portfolio and professional showcase.
- **Projects**: Links to all major projects
- **Contact**: [Contact Info](./TiaAstor/contact/)

### [tiation](./tiation/)
Main organizational repository and brand resources.
- **Brand Guidelines**: [Brand Docs](./tiation/brand/)
- **Related**: All repositories

### [home](./home/)
Personal home directory configurations and dotfiles.
- **Dev Setup**: [ubuntu-dev-setup](./ubuntu-dev-setup/), [windows-dev-setup](./windows-dev-setup/)
- **Configs**: [Dotfiles](./home/dotfiles/)

## 🔗 Repository Relationships

### Primary Dependencies
```
19-trillion-solution
├── company-intranet
├── RiggerConnect-RiggerJobs-Workspace-PB
├── server-configs-gae
└── workflows

git-workspace
├── ubuntu-dev-setup
├── windows-dev-setup
└── workflows

core-foundation-rs
├── DiceRollerSimulator
└── ChaseWhiteRabbit
```

### Cross-Project Integrations
- **Infrastructure**: `server-configs-gae` → All deployed projects
- **CI/CD**: `workflows` → All repositories
- **Development**: `ubuntu-dev-setup`, `windows-dev-setup` → All development projects
- **Legal/Compliance**: `Case_Study_Legal` → `ProtectChildrenAustralia`, `awesome-decentralized-autonomous-organizations`

## 📋 Quick Links

- [Development Setup Guide](./ubuntu-dev-setup/README.md)
- [Deployment Documentation](./server-configs-gae/README.md)
- [Workflow Templates](./workflows/README.md)
- [Legal Templates](./Case_Study_Legal/README.md)
- [Brand Guidelines](./tiation/README.md)

## 🚀 Getting Started

1. Clone the repositories you need:
   ```bash
   git clone https://github.com/tiation/[repository-name].git
   ```

2. Follow the setup guides:
   - [Ubuntu Setup](./ubuntu-dev-setup/README.md)
   - [Windows Setup](./windows-dev-setup/README.md)

3. Check workflow templates in [workflows](./workflows/)

4. Review infrastructure configs in [server-configs-gae](./server-configs-gae/)

---

*Last Updated: July 2025*
*Maintained by: Tia Astor*
