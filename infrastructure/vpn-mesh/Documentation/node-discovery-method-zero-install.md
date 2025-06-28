# 8. Node Discovery Method (Zero-Configuration Access)

## Local DNS Setup (Optional but Recommended)

Install `dnsmasq` on Admin Server to provide mesh-wide DNS:

```bash
sudo apt install -y dnsmasq

# Basic config for dnsmasq
cat <<EOL | sudo tee /etc/dnsmasq.d/mesh.conf
domain-needed
bogus-priv
no-resolv
interface=mesh0
bind-interfaces
address=/admin.mesh/10.10.10.1
EOL

# Restart dnsmasq
sudo systemctl restart dnsmasq
```

- `admin.mesh` will automatically resolve to Admin Server IP (e.g., 10.10.10.1).
- No manual IP lookup needed on user devices.
- Users simply type `http://admin.mesh/` into browsers.


## Backup Manual Discovery (If DNS Fails)

Optional static info page hosted at a fixed IP (admin server nginx root):

1. Create a very simple `/var/www/html/index.html`:

```html
<html>
<head><title>Welcome to Mesh Network</title></head>
<body>
<h2>Mesh Local Services</h2>
<ul>
  <li><a href="/pulse/">Pulse Dashboard</a></li>
  <li><a href="/theia/">Theia IDE (Coding)</a></li>
  <li><a href="/git/">Git Server (Code Repositories)</a></li>
  <li><a href="/files/">File Library (VMs, ISOs)</a></li>
</ul>
</body>
</html>
```

- Even if DNS isn't working, if user connects by IP (e.g., `http://10.10.10.1/`), they will see this page and can navigate.

## Device Configuration

- Nodes can have a hosts file entry optionally:

```bash
echo "10.10.10.1 admin.mesh" | sudo tee -a /etc/hosts
```

(For static environments where auto-DNS isn't used.)


# ✅ Summary
- Install dnsmasq on Admin Server.
- Configure `admin.mesh` to resolve automatically.
- Provide a static portal page if needed.
- Users discover services easily without knowing technical details.

(Local first, fast, resilient inside the mesh.)

