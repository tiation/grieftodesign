from flask import Flask, request, jsonify, render_template
import sqlite3
import os
import json
import datetime
import logging

# Import local configuration
from config import ADMIN_CONFIG

app = Flask(__name__, template_folder='templates')

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('admin_server.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger('admin_server')

def init_admin_db():
    """Initialize the admin database with required tables."""
    conn = sqlite3.connect(ADMIN_CONFIG['database_path'])
    c = conn.cursor()
    
    # Users table for admin authentication
    c.execute('''CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT UNIQUE,
                password_hash TEXT,
                role TEXT,
                created_at TEXT,
                last_login TEXT
            )''')
    
    # Registered nodes table
    c.execute('''CREATE TABLE IF NOT EXISTS nodes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                node_id TEXT UNIQUE,
                node_type TEXT,
                location TEXT,
                contact TEXT,
                ip_address TEXT,
                registration_date TEXT,
                last_seen TEXT,
                status TEXT,
                profile TEXT,
                details TEXT
            )''')
    
    # Node connection history
    c.execute('''CREATE TABLE IF NOT EXISTS node_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                node_id TEXT,
                timestamp TEXT,
                event_type TEXT,
                details TEXT
            )''')
    
    # Create default admin user if none exists
    c.execute("SELECT COUNT(*) FROM users WHERE role='admin'")
    if c.fetchone()[0] == 0:
        import hashlib
        default_password = hashlib.sha256(ADMIN_CONFIG['default_password'].encode()).hexdigest()
        c.execute("INSERT INTO users (username, password_hash, role, created_at) VALUES (?, ?, ?, datetime('now'))",
                  (ADMIN_CONFIG['default_username'], default_password, 'admin'))
        logger.info(f"Created default admin user: {ADMIN_CONFIG['default_username']}")
    
    conn.commit()
    conn.close()
    logger.info("Admin database initialized")

@app.route('/')
def admin_dashboard():
    """Render the main admin dashboard."""
    return render_template('dashboard.html')

@app.route('/nodes')
def node_management():
    """Render the node management interface."""
    conn = sqlite3.connect(ADMIN_CONFIG['database_path'])
    c = conn.cursor()
    c.execute("SELECT node_id, node_type, location, status, last_seen FROM nodes ORDER BY last_seen DESC")
    nodes = [{'node_id': row[0], 
              'node_type': row[1], 
              'location': row[2], 
              'status': row[3], 
              'last_seen': row[4]} for row in c.fetchall()]
    conn.close()
    return render_template('nodes.html', nodes=nodes)

@app.route('/users')
def user_management():
    """Render the user management interface."""
    conn = sqlite3.connect(ADMIN_CONFIG['database_path'])
    c = conn.cursor()
    c.execute("SELECT username, role, created_at, last_login FROM users ORDER BY username")
    users = [{'username': row[0], 
              'role': row[1], 
              'created_at': row[2], 
              'last_login': row[3]} for row in c.fetchall()]
    conn.close()
    return render_template('users.html', users=users)

@app.route('/api/register-node', methods=['POST'])
def register_node():
    """API endpoint to register a new node in the network."""
    data = request.get_json()
    
    required_fields = ['node_id', 'node_type', 'location', 'ip_address']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'Missing required field: {field}'}), 400
    
    conn = sqlite3.connect(ADMIN_CONFIG['database_path'])
    c = conn.cursor()
    
    try:
        c.execute("SELECT COUNT(*) FROM nodes WHERE node_id = ?", (data['node_id'],))
        if c.fetchone()[0] > 0:
            return jsonify({'error': 'Node ID already registered'}), 409
        
        c.execute("""
            INSERT INTO nodes 
            (node_id, node_type, location, ip_address, registration_date, status, profile, details) 
            VALUES (?, ?, ?, ?, datetime('now'), 'registered', 'default', ?)
        """, (
            data['node_id'], 
            data['node_type'], 
            data['location'], 
            data['ip_address'],
            json.dumps(data.get('details', {}))
        ))
        
        # Record the registration event
        c.execute("""
            INSERT INTO node_history 
            (node_id, timestamp, event_type, details) 
            VALUES (?, datetime('now'), 'registration', ?)
        """, (
            data['node_id'],
            f"Node registered from {request.remote_addr}"
        ))
        
        conn.commit()
        logger.info(f"New node registered: {data['node_id']} ({data['node_type']})")
        return jsonify({'success': True, 'message': 'Node registered successfully'}), 201
    
    except Exception as e:
        conn.rollback()
        logger.error(f"Error registering node: {str(e)}")
        return jsonify({'error': f'Registration failed: {str(e)}'}), 500
    
    finally:
        conn.close()

@app.route('/api/node-heartbeat', methods=['POST'])
def node_heartbeat():
    """API endpoint to receive node heartbeats and status updates."""
    data = request.get_json()
    
    if 'node_id' not in data:
        return jsonify({'error': 'Missing node_id'}), 400
    
    conn = sqlite3.connect(ADMIN_CONFIG['database_path'])
    c = conn.cursor()
    
    try:
        # Update the node's last_seen timestamp and status
        c.execute("""
            UPDATE nodes 
            SET last_seen = datetime('now'), 
                status = ?, 
                details = ?
            WHERE node_id = ?
        """, (
            data.get('status', 'unknown'),
            json.dumps(data.get('details', {})),
            data['node_id']
        ))
        
        # Record significant status changes
        if data.get('status') in ['error', 'warning', 'offline', 'maintenance']:
            c.execute("""
                INSERT INTO node_history 
                (node_id, timestamp, event_type, details) 
                VALUES (?, datetime('now'), 'status_change', ?)
            """, (
                data['node_id'],
                f"Status changed to {data.get('status')}: {data.get('message', 'No message')}"
            ))
        
        conn.commit()
        return jsonify({'success': True}), 200
    
    except Exception as e:
        conn.rollback()
        logger.error(f"Error processing heartbeat: {str(e)}")
        return jsonify({'error': f'Heartbeat processing failed: {str(e)}'}), 500
    
    finally:
        conn.close()

@app.route('/api/nodes', methods=['GET'])
def get_nodes():
    """API endpoint to get a list of all registered nodes."""
    conn = sqlite3.connect(ADMIN_CONFIG['database_path'])
    conn.row_factory = sqlite3.Row
    c = conn.cursor()
    
    c.execute("""
        SELECT node_id, node_type, location, ip_address, 
               registration_date, last_seen, status, profile 
        FROM nodes
        ORDER BY last_seen DESC
    """)
    
    nodes = [dict(row) for row in c.fetchall()]
    conn.close()
    
    return jsonify({'nodes': nodes}), 200

@app.route('/api/node/<node_id>', methods=['GET'])
def get_node_details(node_id):
    """API endpoint to get detailed information about a specific node."""
    conn = sqlite3.connect(ADMIN_CONFIG['database_path'])
    conn.row_factory = sqlite3.Row
    c = conn.cursor()
    
    # Get node details
    c.execute("SELECT * FROM nodes WHERE node_id = ?", (node_id,))
    node = c.fetchone()
    
    if node is None:
        return jsonify({'error': 'Node not found'}), 404
    
    # Get node history
    c.execute("""
        SELECT timestamp, event_type, details 
        FROM node_history 
        WHERE node_id = ? 
        ORDER BY timestamp DESC 
        LIMIT 20
    """, (node_id,))
    
    history = [dict(row) for row in c.fetchall()]
    node_dict = dict(node)
    
    # Parse the JSON-stored details
    if 'details' in node_dict and node_dict['details']:
        try:
            node_dict['details'] = json.loads(node_dict['details'])
        except json.JSONDecodeError:
            node_dict['details'] = {}
    
    conn.close()
    
    return jsonify({
        'node': node_dict,
        'history': history
    }), 200

if __name__ == '__main__':
    init_admin_db()
    app.run(
        host=ADMIN_CONFIG.get('host', '0.0.0.0'),
        port=ADMIN_CONFIG.get('port', 5000),
        debug=ADMIN_CONFIG.get('debug', False)
    )

