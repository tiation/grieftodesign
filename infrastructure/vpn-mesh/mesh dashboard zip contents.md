# mesh-dashboard.zip contents (starter pack)

# 1. app.py (Flask collector)
from flask import Flask, request, jsonify
import sqlite3

app = Flask(__name__)

def init_db():
    conn = sqlite3.connect('mesh.db')
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS status (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    node_id TEXT,
                    timestamp TEXT,
                    status TEXT,
                    bandwidth TEXT,
                    uptime TEXT,
                    battery TEXT
                )''')
    conn.commit()
    conn.close()

@app.route('/heartbeat', methods=['POST'])
def heartbeat():
    data = request.get_json()
    conn = sqlite3.connect('mesh.db')
    c = conn.cursor()
    c.execute("INSERT INTO status (node_id, timestamp, status, bandwidth, uptime, battery) VALUES (?, datetime('now'), ?, ?, ?, ?)",
              (data['node_id'], data['status'], data['bandwidth'], data['uptime'], data['battery']))
    conn.commit()
    conn.close()
    return "OK"

@app.route('/mesh-status', methods=['GET'])
def mesh_status():
    conn = sqlite3.connect('mesh.db')
    c = conn.cursor()
    c.execute("SELECT node_id, status, bandwidth, uptime, battery FROM status ORDER BY timestamp DESC")
    rows = c.fetchall()
    nodes = []
    for row in rows:
        node = {
            "node_id": row[0],
            "status": row[1],
            "bandwidth": row[2],
            "uptime": row[3],
            "battery": row[4]
        }
        nodes.append(node)
    return jsonify(nodes)

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=80)

# 2. static/index.html (Dashboard Webpage)
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mesh Node Status</title>
</head>
<body>
<h2>Mesh Network Status</h2>
<table border="1" id="mesh-status"></table>
<script>
async function updateTable() {
    const response = await fetch('/mesh-status');
    const nodes = await response.json();
    let html = '<tr><th>Node</th><th>Status</th><th>Bandwidth</th><th>Uptime</th><th>Battery</th></tr>';
    nodes.forEach(node => {
        html += `<tr><td>${node.node_id}</td><td>${node.status}</td><td>${node.bandwidth}</td><td>${node.uptime}</td><td>${node.battery}</td></tr>`;
    });
    document.getElementById('mesh-status').innerHTML = html;
}
setInterval(updateTable, 5000);
updateTable();
</script>
</body>
</html>

# 3. crontab snippet for each node (heartbeat sender)
*/5 * * * * /usr/bin/curl -X POST http://<collector-ip>/heartbeat -H "Content-Type: application/json" -d @/tmp/node-status.json

# 4. Example /tmp/node-status.json for node heartbeat
{
  "node_id": "jakarta-01",
  "status": "OK",
  "bandwidth": "2.5Mbps",
  "uptime": "4 days",
  "battery": "88%"
}

# 5. README.txt (Quick Start)
1. Install: sudo apt install nginx python3-flask sqlite3
2. Run app.py: sudo python3 app.py
3. Put static/index.html behind nginx or use Flask directly.
4. Setup crontabs on each node to POST heartbeats.
5. Access your dashboard at http://<collector-ip>/static/index.html.

