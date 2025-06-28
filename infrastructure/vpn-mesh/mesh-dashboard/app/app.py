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

