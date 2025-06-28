"""
Admin server configuration settings.
Modify these settings according to your deployment environment.
"""

ADMIN_CONFIG = {
    # Server configuration
    'host': '0.0.0.0',  # Listen on all interfaces
    'port': 5000,       # Admin server port
    'debug': False,     # Debug mode (set to False in production)
    
    # Database settings
    'database_path': 'admin.db',  # SQLite database file
    
    # Default admin user (created on first run)
    'default_username': 'admin',
    'default_password': 'changeme',  # IMPORTANT: Change this in production!
    
    # Security settings
    'session_timeout': 30,  # Session timeout in minutes
    'require_https': True,  # Require HTTPS for admin access
    
    # Network settings
    'allowed_ips': [],      # Empty list allows all IPs, add specific IPs to restrict access
    'mesh_node_port': 80,   # Port used by mesh nodes for the main application
    
    # Notification settings
    'enable_email': False,
    'smtp_server': 'smtp.example.com',
    'smtp_port': 587,
    'smtp_user': 'alerts@example.com',
    'smtp_password': '',
    'notification_emails': ['admin@example.com'],
    
    # Logging
    'log_level': 'INFO',
    'log_file': 'admin_server.log',
}

# Advanced configuration options
ADVANCED_CONFIG = {
    # Node registration
    'require_approval': True,     # Require admin approval for new nodes
    'auto_assign_ip': True,       # Automatically assign IPs to new nodes
    'ip_range': '10.0.0.0/24',    # IP range for mesh network
    
    # Monitoring
    'heartbeat_interval': 300,    # Expected heartbeat interval in seconds
    'offline_threshold': 900,     # Consider node offline after this many seconds
    
    # Performance
    'connection_pooling': True,   # Use connection pooling for database
    'max_connections': 20,        # Maximum database connections
    
    # Features
    'enable_metrics': True,       # Enable collection of performance metrics
    'enable_map_view': True,      # Enable geographic map of nodes
    'enable_bandwidth_monitoring': True,  # Monitor bandwidth usage
}

