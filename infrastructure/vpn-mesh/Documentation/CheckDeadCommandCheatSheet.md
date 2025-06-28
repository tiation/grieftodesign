---

# 🛠 1. Command Cheat Sheet: "Failure Recovery 101"

When you think a node or link might have failed:

| Step | Command | Purpose |
|:---|:---|:---|
| 1 | `ping <neighbor-ip>` | See if the node can reach a neighbor. |
| 2 | `batctl o` | Check the originator table (is the neighbor still listed?). |
| 3 | `batctl n` | Check neighbor quality (packet loss, signal strength). |
| 4 | `ip addr` and `ip link` | Check if mesh interfaces are up and have IPs. |
| 5 | `systemctl status networking` | Make sure network services are running. |
| 6 | `iftop -i mesh0` | See if any traffic is happening at all. |
| 7 | `journalctl -u networking` | Look for errors if network services are failing. |
| 8 | `reboot` | If everything seems stuck, a clean reboot often fixes weird issues.

✅ **If after reboot nothing improves, escalate to hardware (radio/cable/power) check.**

----
