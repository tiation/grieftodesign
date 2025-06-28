
# 🛠 2. Minimal Setup Script for New Nodes (monitoring tools installed)

```bash
#!/bin/bash
# install-basic-tools.sh

echo "Installing monitoring and troubleshooting tools..."

sudo apt update
sudo apt install -y \
    batctl \
    iproute2 \
    htop \
    iftop \
    nload \
    net-tools \
    curl \
    tmux \
    batctl \
    babeld

echo "Basic mesh node tools installed!"
```

✅ Very fast.  
✅ Only standard packages (lightweight).  
✅ Ready for diagnosing any node in minutes.

---

# 📋 Extra Step: Add this into your **install.sh** for nodes if you want full automation.

---


