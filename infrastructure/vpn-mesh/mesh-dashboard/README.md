# Mesh Dashboard

A simple, lightweight dashboard for monitoring mesh network nodes.

## Features

- Collects heartbeats from mesh nodes
- Displays real-time node status
- Tracks bandwidth, uptime, and battery levels
- Stores historical data in SQLite database

## Installation

1. Install required dependencies:
```bash
sudo apt install nginx python3-flask sqlite3
pip install -r requirements.txt
```

2. Setup the collector server:
```bash
cd app
sudo python3 app.py
```

3. Configure nginx (optional for production):
```bash
# Example nginx configuration
server {
    listen 80;
    server_name your-server-name;

    location / {
        proxy_pass http://127.0.0.1:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Node Configuration

1. Copy the example node status template:
```bash
cp examples/node-status.json /tmp/node-status.json
```

2. Customize the JSON file for each node:
```json
{
  "node_id": "your-node-id",
  "status": "OK",
  "bandwidth": "2.5Mbps",
  "uptime": "4 days",
  "battery": "88%"
}
```

3. Setup the cron job on each node (modify the collector IP):
```bash
# Add to crontab
*/5 * * * * /usr/bin/curl -X POST http://<collector-ip>/heartbeat -H "Content-Type: application/json" -d @/tmp/node-status.json
```

## Usage

1. Start the Flask application:
```bash
cd app
sudo python3 app.py
```

2. Access your dashboard:
```
http://<collector-ip>/static/index.html
```

3. The dashboard will automatically refresh every 5 seconds with the latest node data.

## Directory Structure

```
mesh-dashboard/
├── app/
│   └── app.py              # Flask collector application
├── static/
│   └── index.html          # Dashboard webpage
├── examples/
│   ├── crontab.example     # Example crontab configuration
│   └── node-status.json    # Example node status JSON
├── README.md               # Installation and usage guide
└── requirements.txt        # Python dependencies
```

## License

MIT

