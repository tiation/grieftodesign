# mesh-dashboard.zip contents (starter pack)

# 1. app.py (Flask collector)
<same as before>

# 2. static/index.html (Dashboard Webpage)
<same as before>

# 3. crontab snippet for each node (heartbeat sender)
<same as before>

# 4. Example /tmp/node-status.json for node heartbeat
<same as before>

# 5. README.txt (Quick Start)
<same as before>

# 6. Admin Server Setup Script (install-admin-server.sh)
<same as before>

# 7. Mesh Network Logical Map
<same as before>

# 8. Node Discovery Method (Zero-Configuration Access)
<same as before>

# 9. Admin Server Maintenance Cheat Sheet

| Task | Command |
|:---|:---|
| Restart nginx web server | `sudo systemctl restart nginx` |
| Restart Pulse Flask server | `sudo systemctl restart pulse-dashboard` (if service setup) or `tmux attach -t pulse` if running manually |
| Restart Theia IDE server (Docker) | `sudo docker restart theia` |
| Restart Gitea Git server (Docker) | `sudo docker restart gitea` |
| Check nginx logs | `sudo journalctl -u nginx` or `sudo tail -f /var/log/nginx/access.log` |
| Check disk space | `df -h` |
| Monitor network usage live | `iftop -i mesh0` |
| Monitor system load | `htop` |
| Backup database | `sqlite3 mesh.db ".backup mesh-backup.db"` |
| Full server reboot | `sudo reboot` |

# 10. Client Node Setup Quick Guide

| Step | Command |
|:---|:---|
| Install mesh packages | `sudo apt install -y batctl babeld iproute2` |
| Connect to Mesh WiFi | Use `nmtui` or `iwctl` to join mesh SSID |
| Set static IP or DHCP | Edit `/etc/netplan/*.yaml` then `sudo netplan apply` |
| Verify IP address | `ip addr show mesh0` |
| Verify mesh link quality | `batctl o` and `batctl n` |
| Optional: Add admin.mesh to hosts | `echo "10.10.10.1 admin.mesh" | sudo tee -a /etc/hosts` |
| Test access to Admin Server | `ping admin.mesh` or open `http://admin.mesh/` in browser |
| Enable optional heartbeat monitoring | Add crontab line for heartbeat script (if monitoring opted-in) |

# ✅ Summary
- Admin server can be easily maintained with core service restarts and basic commands.
- Client nodes can be quickly joined to mesh, assigned IPs, and discover services.
- Optional: nodes can optionally heartbeat status to Admin Server if desired.

(Mesh-first, Local-first, Minimal stress.)

