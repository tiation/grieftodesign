/**
 * Mesh Network Admin Dashboard
 * Main JavaScript for dashboard functionality
 */

// Global state
const state = {
    nodes: [],
    users: [],
    currentPage: 1,
    itemsPerPage: 10,
    selectedNodeId: null,
    selectedUsername: null,
    confirmedAction: null,
    filters: {
        nodeType: 'all',
        nodeStatus: 'all',
        userRole: 'all'
    }
};

/**
 * Dashboard Initialization
 */
document.addEventListener('DOMContentLoaded', function() {
    // Initialize common elements across all pages
    initCommonElements();
    
    // Determine current page and initialize specific functionality
    if (window.location.pathname === '/' || window.location.pathname === '/index.html') {
        initDashboard();
    } else if (window.location.pathname === '/nodes') {
        initNodeManagement();
    } el    // Setup node type change event for modal
    const nodeTypeSelect = document.getElementById('node-type');
    if (nodeTypeSelect) {
        nodeTypeSelect.addEventListener('change', function() {
            const gatewaySection = document.querySelector('.gateway-only');
            if (this.value === 'gateway') {
                gatewaySection.style.display = 'block';
            } else {
                gatewaySection.style.display = 'none';
            }
        });
    }
ements common to all pages
 */
function initCommonElements() {
    // Setup close buttons for all modals
    document.querySelectorAll('.close-btn, .cancel-btn').forEach(button => {
        button.addEventListener('click', function() {
            const modal = this.closest('.modal');
            if (modal) {
                modal.style.display = 'none';
            }
        });
    });
    
    // Close modals when clicking outside
    window.addEventListener('click', function(event) {
        if (event.target.classList.contains('modal')) {
            event.target.style.display = 'none';
        }
    });
}
            const gatewaySection = document.querySelector('.gateway-only');
            if (this.value === 'gateway') {
                gatewaySection.style.display = 'block';
            } else {
                gatewaySection.style.display = 'none';
            }
        });
    }

    // Setup pagination
    const prevPageBtn = document.getElementById('prev-page');
    const nextPageBtn = document.getElementById('next-page');
    
    if (prevPageBtn) {
        prevPageBtn.addEventListener('click', function() {
            if (state.currentPage > 1) {
                state.currentPage--;
                renderNodesTable();
            }
        });
    }
    
    if (nextPageBtn) {
        nextPageBtn.addEventListener('click', function() {
            const totalPages = Math.ceil(state.nodes.length / state.itemsPerPage);
            if (state.currentPage < totalPages) {
                state.currentPage++;
                renderNodesTable();
            }
        });
    }
}

/**
 * User Management Functionality
 */
function initUserManagement() {
    // Cache DOM elements
    const userSearch = document.getElementById('user-search');
    const userRoleFilter = document.getElementById('user-role-filter');
    const addUserBtn = document.getElementById('add-user-btn');
    const usersTable = document.getElementById('users-table');
    const saveUserBtn = document.getElementById('save-user-btn');
    
    // Fetch users data
    fetchUsersData();
    
    // Add event listeners
    if (userSearch) {
        userSearch.addEventListener('input', filterUsers);
    }
    
    if (userRoleFilter) {
        userRoleFilter.addEventListener('change', function() {
            state.filters.userRole = this.value;
            filterUsers();
        });
    }
    
    if (addUserBtn) {
        addUserBtn.addEventListener('click', showAddUserModal);
    }
    
    if (saveUserBtn) {
        saveUserBtn.addEventListener('click', saveUserData);
    }
    }
    
    if (saveUserBtn) {
        saveUserBtn.addEventListener('click', saveUserData);
    }
    
    // User table actions (edit, delete)
    if (usersTable) {
        usersTable.addEventListener('click', function(e) {
            const target = e.target.closest('button');
            if (!target) return;
            
            const username = target.dataset.username;
            if (!username) return;
            
            if (target.classList.contains('edit-btn')) {
                showEditUserModal(username);
            } else if (target.classList.contains('delete-btn')) {
                confirmDeleteUser(username);
            }
        });
    }
    
    // Setup confirmation actions for user management
    const confirmBtn = document.getElementById('confirm-btn');
    if (confirmBtn) {
        confirmBtn.addEventListener('click', function() {
            const modal = document.getElementById('confirm-modal');
            modal.style.display = 'none';
            
            if (state.confirmedAction && state.selectedUsername) {
                if (state.confirmedAction === 'delete-user') {
                    deleteUser(state.selectedUsername);
                }
            }
        });
    }
}

/**
 * Show add user modal
 */
function showAddUserModal() {
    // Reset form
    document.getElementById('user-form').reset();
    document.getElementById('user-action').value = 'add';
    document.getElementById('username-input').disabled = false;
    document.getElementById('password-input').required = true;
    document.getElementById('confirm-password-input').required = true;
    document.getElementById('user-modal-title').textContent = 'Add New User';
    
    // Show the modal
    document.getElementById('edit-user-modal').style.display = 'block';
}

/**
 * Show edit user modal with existing data
 */
function showEditUserModal(username) {
    // Find the user in the state
    const user = state.users.find(u => u.username === username);
    if (!user) return;
    
    state.selectedUsername = username;
    
    // Set form action
    document.getElementById('user-action').value = 'edit';
    document.getElementById('user-modal-title').textContent = 'Edit User';
    
    // Fill form with user data
    document.getElementById('username-input').value = user.username;
    document.getElementById('username-input').disabled = true; // Username cannot be changed
    document.getElementById('role-input').value = user.role;
    
    // Password fields optional when editing
    document.getElementById('password-input').required = false;
    document.getElementById('confirm-password-input').required = false;
    document.getElementById('password-input').value = '';
    document.getElementById('confirm-password-input').value = '';
    
    // Show the modal
    document.getElementById('edit-user-modal').style.display = 'block';
}

/**
 * Save user data from form
 */
function saveUserData() {
    const form = document.getElementById('user-form');
    if (!form.checkValidity()) {
        form.reportValidity();
        return;
    }
    
    // Check if passwords match
    const password = document.getElementById('password-input').value;
    const confirmPassword = document.getElementById('confirm-password-input').value;
    
    if (password && password !== confirmPassword) {
        alert('Passwords do not match.');
        return;
    }
    
    // Get form data
    const action = document.getElementById('user-action').value;
    const username = document.getElementById('username-input').value;
    const role = document.getElementById('role-input').value;
    
    const userData = {
        username: username,
        role: role
    };
    
    // Add password if provided (or required for new users)
    if (password || action === 'add') {
        if (!password && action === 'add') {
            alert('Password is required for new users.');
            return;
        }
        userData.password = password;
    }
    
    // Determine endpoint and method
    let url = '/api/users';
    let method = 'POST';
    
    if (action === 'edit') {
        url = `/api/user/${username}`;
        method = 'PUT';
    }
    
    // Send data to server
    fetch(url, {
        method: method,
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(userData)
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        // Close modal
        document.getElementById('edit-user-modal').style.display = 'none';
        
        // Refresh data
        fetchUsersData();
        
        // Show success message
        showNotification('User saved successfully', 'success');
    })
    .catch(error => {
        console.error('Error saving user data:', error);
        showNotification('Error saving user data: ' + error.message, 'error');
    });
}

/**
 * Confirm user deletion
 */
function confirmDeleteUser(username) {
    state.selectedUsername = username;
    state.confirmedAction = 'delete-user';
    
    const message = `Are you sure you want to delete user "${username}"?`;
    
    document.getElementById('confirm-message').textContent = message;
    document.getElementById('confirm-modal').style.display = 'block';
}

/**
 * Delete a user
 */
function deleteUser(username) {
    fetch(`/api/user/${username}`, {
        method: 'DELETE'
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        // Refresh data
        fetchUsersData();
        
        // Show success message
        showNotification(`User "${username}" deleted successfully`, 'success');
    })
    .catch(error => {
        console.error('Error deleting user:', error);
        showNotification('Error deleting user: ' + error.message, 'error');
    });
}

/**
 * Show notification/toast message
 */
function showNotification(message, type = 'info') {
    // Check if notification container exists, create if not
    let container = document.getElementById('notification-container');
    if (!container) {
        container = document.createElement('div');
        container.id = 'notification-container';
        container.className = 'notification-container';
        document.body.appendChild(container);
    }
    
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
        <div class="notification-message">${message}</div>
        <button class="notification-close">&times;</button>
    `;
    
    // Add to container
    container.appendChild(notification);
    
    // Setup close button
    const closeBtn = notification.querySelector('.notification-close');
    closeBtn.addEventListener('click', function() {
        notification.classList.add('notification-hide');
        setTimeout(() => {
            notification.remove();
        }, 300);
    });
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
        notification.classList.add('notification-hide');
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, 5000);
}

/**
 * Setup WebSocket for real-time updates
 */
function setupRealtimeUpdates() {
    // Check if WebSocket is available
    if (!window.WebSocket) {
        console.warn('WebSocket not supported. Real-time updates disabled.');
        return;
    }
    
    // Get WebSocket URL (same host, different protocol)
    const protocol = location.protocol === 'https:' ? 'wss:' : 'ws:';
    const wsUrl = `${protocol}//${location.host}/ws`;
    
    // Create WebSocket connection
    const ws = new WebSocket(wsUrl);
    
    ws.onopen = function() {
        console.log('WebSocket connection established');
    };
    
    ws.onmessage = function(event) {
        try {
            const data = JSON.parse(event.data);
            
            // Handle different message types
            switch (data.type) {
                case 'node_update':
                    handleNodeUpdate(data.data);
                    break;
                case 'node_status_change':
                    handleNodeStatusChange(data.data);
                    break;
                case 'user_update':
                    handleUserUpdate(data.data);
                    break;
                case 'system_notification':
                    showNotification(data.message, data.level || 'info');
                    break;
                default:
                    console.log('Unknown WebSocket message type:', data.type);
            }
        } catch (error) {
            console.error('Error processing WebSocket message:', error);
        }
    };
    
    ws.onclose = function() {
        console.log('WebSocket connection closed');
        // Try to reconnect after 5 seconds
        setTimeout(setupRealtimeUpdates, 5000);
    };
    
    ws.onerror = function(error) {
        console.error('WebSocket error:', error);
        ws.close();
    };
    
    // Store WebSocket connection in global state
    state.websocket = ws;
}

/**
 * Handle real-time node update message
 */
function handleNodeUpdate(nodeData) {
    // Find the node in state and update it, or add if new
    const existingNodeIndex = state.nodes.findIndex(n => n.node_id === nodeData.node_id);
    
    if (existingNodeIndex >= 0) {
        state.nodes[existingNodeIndex] = nodeData;
    } else {
        state.nodes.push(nodeData);
    }
    
    // Update UI if we're on the relevant page
    if (window.location.pathname === '/nodes') {
        renderNodesTable();
    } else if (window.location.pathname === '/' || window.location.pathname === '/index.html') {
        updateDashboardStats(state.nodes);
        updateDashboardCharts(state.nodes);
        updateLatestNodes(state.nodes);
    }
    
    // Update node details modal if it's open for this node
    if (state.selectedNodeId === nodeData.node_id && document.getElementById('node-details-modal').style.display === 'block') {
        showNodeDetails(nodeData.node_id);
    }
}

/**
 * Handle real-time node status change message
 */
function handleNodeStatusChange(data) {
    // Find the node and update its status
    const node = state.nodes.find(n => n.node_id === data.node_id);
    if (node) {
        node.status = data.status;
        node.last_seen = data.timestamp;
        
        if (data.details) {
            node.details = data.details;
        }
        
        // Update UI
        if (window.location.pathname === '/nodes') {
            renderNodesTable();
        } else if (window.location.pathname === '/' || window.location.pathname === '/index.html') {
            updateDashboardStats(state.nodes);
            updateDashboardCharts(state.nodes);
            updateLatestNodes(state.nodes);
        }
        
        // Show notification for critical status changes
        if (data.status === 'error' || data.status === 'warning') {
            showNotification(`Node "${data.node_id}" is ${data.status}`, data.status === 'error' ? 'error' : 'warning');
        }
    }
}

/**
 * Handle real-time user update message
 */
function handleUserUpdate(userData) {
    // Find the user in state and update it, or add if new
    const existingUserIndex = state.users.findIndex(u => u.username === userData.username);
    
    if (existingUserIndex >= 0) {
        state.users[existingUserIndex] = userData;
    } else {
        state.users.push(userData);
    }
    
    // Update UI if we're on the users page
    if (window.location.pathname === '/users') {
        renderUsersTable();
    }
}

/**
 * Global error handler for fetch requests
 */
function handleApiError(error, context = '') {
    console.error(`API Error${context ? ' (' + context + ')' : ''}:`, error);
    
    // Show user-friendly error message
    showNotification(
        `Error${context ? ' ' + context : ''}: ${error.message || 'Unknown error occurred'}`, 
        'error'
    );
    
    // Log to server if it's a critical error
    if (error.status === 500) {
        fetch('/api/log-error', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                error: error.message,
                context: context,
                time: new Date().toISOString(),
                url: window.location.href
            })
        }).catch(e => console.error('Error logging to server:', e));
    }
}
            const gatewaySection = document.querySelector('.gateway-only');
            if (this.value === 'gateway') {
                gatewaySection.style.display = 'block';
            } else {
                gatewaySection.style.display = 'none';
            }
        });
    }
    
    // Setup pagination
    const prevPageBtn = document.getElementById('prev-page');
    const nextPageBtn = document.getElementById('next-page');
    
    if (prevPageBtn) {
        prevPageBtn.addEventListener('click', function() {
            if (state.currentPage > 1) {
                state.currentPage--;
                renderNodesTable();
            }
        });
    }
    
    if (nextPageBtn) {
        nextPageBtn.addEventListener('click', function() {
            const totalPages = Math.ceil(state.nodes.length / state.itemsPerPage);
            if (state.currentPage < totalPages) {
                state.currentPage++;
                renderNodesTable();
            }
        });
    }
}

/**
 * Fetch users data
 */
function fetchUsersData() {
    fetch('/api/users')
        .then(response => response.json())
        .then(data => {
            state.users = data.users || [];
            renderUsersTable();
        })
        .catch(error => {
            console.error('Error fetching users data:', error);
        });
}

/**
 * Filter users based on search query and role filter
 */
function filterUsers() {
    const searchQuery = document.getElementById('user-search').value.toLowerCase();
    
    const filteredUsers = state.users.filter(user => {
        // Apply text search
        const matchesSearch = user.username.toLowerCase().includes(searchQuery);
        
        // Apply role filter
        const matchesRole = 
            state.filters.userRole === 'all' || 
            user.role === state.filters.userRole;
        
        return matchesSearch && matchesRole;
    });
    
    renderUsersTable(filteredUsers);
}

/**
 * Render users table
 */
function renderUsersTable(users = state.users) {
    const tbody = document.querySelector('#users-table tbody');
    if (!tbody) return;
    
    let html = '';
    if (users.length === 0) {
        html = '<tr><td colspan="5">No users found</td></tr>';
    } else {
        users.forEach(user => {
            html += `
                <tr data-username="${user.username}">
                    <td>${user.username}</td>
                    <td>${capitalizeFirst(user.role)}</td>
                    <td>${formatDate(user.created_at)}</td>
                    <td>${user.last_login ? formatDate(user.last_login) : 'Never'}</td>
                    <td class="actions">
                        <button class="action-btn edit-btn" title="Edit User" data-username="${user.username}">
                            <i class="icon-edit"></i>
                        </button>
                        <button class="action-btn delete-btn" title="Delete User" data-username="${user.username}">
                            <i class="icon-delete"></i>
                        </button>
                    </td>
                </tr>
            `;
        });
    }
    
    tbody.innerHTML = html;
}

/**
 * Helper function to capitalize first letter
 */
function capitalizeFirst(str) {
    if (!str) return '';
    return str.charAt(0).toUpperCase() + str.slice(1);
}

/**
 * Format date for display
 */
function formatDate(dateStr) {
    if (!dateStr) return 'N/A';
    
    const date = new Date(dateStr);
    if (isNaN(date.getTime())) return dateStr;
    
    // If it's today, show time only
    const today = new Date();
    const isToday = date.getDate() === today.getDate() && 
                     date.getMonth() === today.getMonth() && 
                     date.getFullYear() === today.getFullYear();
    
    if (isToday) {
        return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    }
    
    // Otherwise show date and time
    return date.toLocaleString([], { 
        year: 'numeric', 
        month: 'short', 
        day: 'numeric',
        hour: '2-digit', 
        minute: '2-digit'
    });
}
            const gatewaySection = document.querySelector('.gateway-only');
            if (this.value === 'gateway') {
                gatewaySection.style.display = 'block';
            } else {
                gatewaySection.style.display = 'none';
            }
        });
    }
    
    // Setup form submission
    const saveNodeBtn = document.getElementById('save-node-btn');
    if (saveNodeBtn) {
        saveNodeBtn.addEventListener('click', saveNodeData);
    }
    
    // Setup node restart button
    const restartNodeBtn = document.getElementById('restart-node-btn');
    if (restartNodeBtn) {
        restartNodeBtn.addEventListener('click', function() {
            if (state.selectedNodeId) {
                restartNode(state.selectedNodeId);
            }
        });
    }
    
    // Setup confirmation actions
    const confirmBtn = document.getElementById('confirm-btn');
    if (confirmBtn) {
        confirmBtn.addEventListener('click', function() {
            const modal = document.getElementById('confirm-modal');
            modal.style.display = 'none';
            
            if (state.confirmedAction && state.selectedNodeId) {
                if (state.confirmedAction === 'delete') {
                    deleteNode(state.selectedNodeId);
                }
            }
        });
    }
}

/**
 * Fetch all nodes data from the API
 */
function fetchNodesData() {
    fetch('/api/nodes')
        .then(response => response.json())
        .then(data => {
            state.nodes = data.nodes || [];
            renderNodesTable();
        })
        .catch(error => {
            console.error('Error fetching nodes data:', error);
        });
}

/**
 * Filter nodes based on search query and filters
 */
function filterNodes() {
    const searchQuery = document.getElementById('node-search').value.toLowerCase();
    
    const filteredNodes = state.nodes.filter(node => {
        // Apply text search
        const matchesSearch = 
            node.node_id.toLowerCase().includes(searchQuery) || 
            node.location.toLowerCase().includes(searchQuery);
        
        // Apply type filter
        const matchesType = 
            state.filters.nodeType === 'all' || 
            node.node_type === state.filters.nodeType;
        
        // Apply status filter
        const matchesStatus = 
            state.filters.nodeStatus === 'all' || 
            node.status === state.filters.nodeStatus;
        
        return matchesSearch && matchesType && matchesStatus;
    });
    
    renderNodesTable(filteredNodes);
}

/**
 * Render the nodes table with the provided data
 */
function renderNodesTable(nodes = state.nodes) {
    const tbody = document.querySelector('#nodes-table tbody');
    if (!tbody) return;
    
    // Calculate pagination
    const totalPages = Math.ceil(nodes.length / state.itemsPerPage);
    const startIndex = (state.currentPage - 1) * state.itemsPerPage;
    const endIndex = startIndex + state.itemsPerPage;
    const pageNodes = nodes.slice(startIndex, endIndex);
    
    // Update pagination UI
    document.getElementById('current-page').textContent = state.currentPage;
    document.getElementById('total-pages').textContent = totalPages;
    document.getElementById('prev-page').disabled = state.currentPage <= 1;
    document.getElementById('next-page').disabled = state.currentPage >= totalPages;
    
    // Generate table rows
    let html = '';
    if (pageNodes.length === 0) {
        html = '<tr><td colspan="6">No nodes found</td></tr>';
    } else {
        pageNodes.forEach(node => {
            const statusClass = `status-${node.status.toLowerCase()}`;
            html += `
                <tr data-node-id="${node.node_id}">
                    <td>${node.node_id}</td>
                    <td>${capitalizeFirst(node.node_type)}</td>
                    <td>${node.location}</td>
                    <td>
                        <span class="status-badge ${statusClass}">
                            ${node.status}
                        </span>
                    </td>
                    <td>${formatDate(node.last_seen)}</td>
                    <td class="actions">
                        <button class="action-btn view-btn" title="View Details" data-node-id="${node.node_id}">
                            <i class="icon-view"></i>
                        </button>
                        <button class="action-btn edit-btn" title="Edit Node" data-node-id="${node.node_id}">
                            <i class="icon-edit"></i>
                        </button>
                        <button class="action-btn delete-btn" title="Delete Node" data-node-id="${node.node_id}">
                            <i class="icon-delete"></i>
                        </button>
                    </td>
                </tr>
            `;
        });
    }
    
    tbody.innerHTML = html;
}

/**
 * Show node details modal
 */
function showNodeDetails(nodeId) {
    // Find the node in the state
    const node = state.nodes.find(n => n.node_id === nodeId);
    if (!node) return;
    
    state.selectedNodeId = nodeId;
    
    // Populate node details
    document.getElementById('detail-node-id').textContent = node.node_id;
    document.getElementById('detail-node-type').textContent = capitalizeFirst(node.node_type);
    document.getElementById('detail-location').textContent = node.location;
    document.getElementById('detail-ip-address').textContent = node.ip_address;
    document.getElementById('detail-registration-date').textContent = formatDate(node.registration_date);
    document.getElementById('detail-last-seen').textContent = formatDate(node.last_seen);
    
    const statusEl = document.getElementById('detail-status');
    statusEl.textContent = node.status;
    statusEl.className = '';
    statusEl.classList.add(`status-${node.status.toLowerCase()}`);
    
    // Populate metrics if available
    const details = node.details ? (typeof node.details === 'string' ? JSON.parse(node.details) : node.details) : {};
    
    if (details) {
        document.getElementById('metric-cpu').textContent = details.cpu_load || 'N/A';
        document.getElementById('metric-ram').textContent = details.ram_usage || 'N/A';
        document.getElementById('metric-disk').textContent = details.disk_usage || 'N/A';
        document.getElementById('metric-uptime').textContent = details.uptime || 'N/A';
    }
    
    // Fetch and display node history
    fetch(`/api/node/${nodeId}`)
        .then(response => response.json())
        .then(data => {
            if (data.history) {
                renderNodeHistory(data.history);
            }
        })
        .catch(error => {
            console.error('Error fetching node history:', error);
        });
    
    // Display the modal
    document.getElementById('node-details-modal').style.display = 'block';
}

/**
 * Render node history table
 */
function renderNodeHistory(history) {
    const tbody = document.querySelector('#node-history-table tbody');
    if (!tbody) return;
    
    let html = '';
    if (history.length === 0) {
        html = '<tr><td colspan="3">No history available</td></tr>';
    } else {
        history.forEach(event => {
            html += `
                <tr>
                    <td>${formatDate(event.timestamp)}</td>
                    <td>${event.event_type}</td>
                    <td>${event.details}</td>
                </tr>
            `;
        });
    }
    
    tbody.innerHTML = html;
}

/**
 * Show add node modal
 */
function showAddNodeModal() {
    // Reset form
    document.getElementById('node-form').reset();
    document.getElementById('node-action').value = 'add';
    document.getElementById('node-id').value = '';
    document.getElementById('edit-modal-title').textContent = 'Add New Node';
    
    // Hide gateway-specific fields
    document.querySelector('.gateway-only').style.display = 'none';
    
    // Show the modal
    document.getElementById('edit-node-modal').style.display = 'block';
}

/**
 * Show edit node modal with existing data
 */
function showEditNodeModal(nodeId) {
    // Find the node in the state
    const node = state.nodes.find(n => n.node_id === nodeId);
    if (!node) return;
    
    // Set form action and node ID
    document.getElementById('node-action').value = 'edit';
    document.getElementById('node-id').value = nodeId;
    document.getElementById('edit-modal-title').textContent = 'Edit Node';
    
    // Fill form with node data
    document.getElementById('node-id-input').value = node.node_id;
    document.getElementById('node-type').value = node.node_type;
    document.getElementById('location').value = node.location;
    document.getElementById('ip-address').value = node.ip_address;
    
    // Parse details if available
    const details = node.details ? (typeof node.details === 'string' ? JSON.parse(node.details) : node.details) : {};
    
    if (details) {
        document.getElementById('contact-name').value = details.contact_name || '';
        document.getElementById('contact-email').value = details.contact_email || '';
        document.getElementById('contact-phone').value = details.contact_phone || '';
        document.getElementById('gps-coords').value = details.gps_coordinates || '';
        document.getElementById('notes').value = details.additional_info || '';
        
        // Set gateway-specific fields
        if (node.node_type === 'gateway') {
            document.getElementById('bandwidth').value = details.bandwidth_available || '';
            document.getElementById('connection-reliability').value = details.connection_reliability || 'reliable';
            document.querySelector('.gateway-only').style.display = 'block';
        } else {
            document.querySelector('.gateway-only').style.display = 'none';
        }
    }
    
    // Show the modal
    document.getElementById('edit-node-modal').style.display = 'block';
}

/**
 * Save node data from form
 */
function saveNodeData() {
    const form = document.getElementById('node-form');
    if (!form.checkValidity()) {
        form.reportValidity();
        return;
    }
    
    // Get form data
    const formData = new FormData(form);
    const nodeData = {
        node_id: formData.get('node_id'),
        node_type: formData.get('node_type'),
        location: formData.get('location'),
        ip_address: formData.get('ip_address'),
        details: {
            contact_name: formData.get('contact_name'),
            contact_email: formData.get('contact_email'),
            contact_phone: formData.get('contact_phone'),
            gps_coordinates: formData.get('gps_coords'),
            additional_info: formData.get('notes')
        }
    };
    
    // Add gateway-specific details
    if (nodeData.node_type === 'gateway') {
        nodeData.details.bandwidth_available = formData.get('bandwidth');
        nodeData.details.connection_reliability = formData.get('connection_reliability');
    }
    
    // Determine if this is an add or edit operation
    const action = document.getElementById('node-action').value;
    const nodeId = document.getElementById('node-id').value;
    
    let url = '/api/nodes';
    let method = 'POST';
    
    if (action === 'edit' && nodeId) {
        url = `/api/node/${nodeId}`;
        method = 'PUT';
    }
    
    // Send data to server
    fetch(url, {
        method: method,
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(nodeData)
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        // Close modal
        document.getElementById('edit-node-modal').style.display = 'none';
        
        // Refresh data
        fetchNodesData();
    })
    .catch(error => {
        console.error('Error saving node data:', error);
        alert('There was an error saving the node data. Please try again.');
    });
}

/**
 * Confirm node deletion
 */
function confirmDeleteNode(nodeId) {
    state.selectedNodeId = nodeId;
    state.confirmedAction = 'delete';
    
    const node = state.nodes.find(n => n.node_id === nodeId);
    const message = `Are you sure you want to delete the node "${node ? node.node_id : nodeId}"?`;
    
    document.getElementById('confirm-message').textContent = message;
    document.getElementById('confirm-modal').style.display = 'block';
}

/**
 * Delete a node
 */
function deleteNode(nodeId) {
    fetch(`/api/node/${nodeId}`, {
        method: 'DELETE'
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        // Refresh data
        fetchNodesData();
    })
    .catch(error => {
        console.error('Error deleting node:', error);
        alert('There was an error deleting the node. Please try again.');
    });
}

/**
 * Restart a node
 */
function restartNode(nodeId) {
    fetch(`/api/node/${nodeId}/restart`, {
        method: 'POST'
    })
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        alert(`Node "${nodeId}" restart command sent successfully.`);
    })
    .catch(error => {
        console.error('Error restarting node:', error);
        alert('There was an error restarting the node. Please try again.');
    });
}

/**
 * User Management Functionality
 */
function initUserManagement() {
    // Cache DOM elements
    const userSearch = document.getElementById('user-search');
    const userRoleFilter = document.getElementById('user-role-filter');
    const addUserBtn = document.getElementById('add-user-btn');
    const usersTable = document.getElementById('users-table');
    
    // Fetch users data
    fetchUsersData();
    
    // Add event listeners
    if (userSearch) {
        
            if (modal) {
                modal.style.display = 'none';
            }
        });
    });
    
    // Close modals when clicking outside
    window.addEventListener('click', function(event) {
        if (event.target.classList.contains('modal')) {
            event.target.style.display = 'none';
        }
    });
}

/**
 * Initialize main dashboard page
 */
function initDashboard() {
    // Fetch dashboard data
    fetchDashboardData();
    
    // Setup refresh interval (every 30 seconds)
    setInterval(fetchDashboardData, 30000);
}

/**
 * Fetch dashboard data from API
 */
function fetchDashboardData() {
    // Fetch nodes data
    fetch('/api/nodes')
        .then(response => response.json())
        .then(data => {
            updateDashboardStats(data.nodes);
            updateDashboardCharts(data.nodes);
            updateLatestNodes(data.nodes);
        })
        .catch(error => {
            console.error('Error fetching dashboard data:', error);
        });
    
    // Fetch recent activity
    fetch('/api/activity')
        .then(response => response.json())
        .then(data => {
            updateActivityFeed(data.activities);
        })
        .catch(error => {
            console.error('Error fetching activity data:', error);
        });
}

/**
 * Update dashboard statistics
 */
function updateDashboardStats(nodes) {
    if (!nodes) return;
    
    const totalNodes = nodes.length;
    const activeNodes = nodes.filter(node => node.status === 'OK').length;
    const warningNodes = nodes.filter(node => node.status === 'warning').length;
    const offlineNodes = nodes.filter(node => node.status === 'error').length;
    
    document.getElementById('total-nodes').textContent = totalNodes;
    document.getElementById('active-nodes').textContent = activeNodes;
    document.getElementById('warning-nodes').textContent = warningNodes;
    document.getElementById('offline-nodes').textContent = offlineNodes;
}

/**
 * Update dashboard charts
 */
function updateDashboardCharts(nodes) {
    if (!nodes || !window.Chart) return;
    
    // Node status chart
    const statusCtx = document.getElementById('node-status-chart');
    if (statusCtx) {
        const statusData = {
            labels: ['Online', 'Warning', 'Offline', 'Unknown'],
            datasets: [{
                data: [
                    nodes.filter(node => node.status === 'OK').length,
                    nodes.filter(node => node.status === 'warning').length,
                    nodes.filter(node => node.status === 'error').length,
                    nodes.filter(node => node.status === 'unknown').length
                ],
                backgroundColor: [
                    '#2ecc71', // Green
                    '#f39c12', // Yellow
                    '#e74c3c', // Red
                    '#bdc3c7'  // Gray
                ]
            }]
        };
        
        if (window.statusChart) {
            window.statusChart.data = statusData;
            window.statusChart.update();
        } else {
            window.statusChart = new Chart(statusCtx, {
                type: 'doughnut',
                data: statusData,
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    legend: {
                        display: false
                    }
                }
            });
        }
    }
    
    // Node types chart
    const typesCtx = document.getElementById('node-types-chart');
    if (typesCtx) {
        const typeData = {
            labels: ['Client', 'Relay', 'Gateway'],
            datasets: [{
                data: [
                    nodes.filter(node => node.node_type === 'client').length,
                    nodes.filter(node => node.node_type === 'relay').length,
                    nodes.filter(node => node.node_type === 'gateway').length
                ],
                backgroundColor: [
                    '#3498db', // Blue
                    '#9b59b6', // Purple
                    '#1abc9c'  // Teal
                ]
            }]
        };
        
        if (window.typeChart) {
            window.typeChart.data = typeData;
            window.typeChart.update();
        } else {
            window.typeChart = new Chart(typesCtx, {
                type: 'pie',
                data: typeData,
                options: {
                    responsive: true,
                    maintainAspectRatio: false
                }
            });
        }
    }
}

/**
 * Update latest nodes list
 */
function updateLatestNodes(nodes) {
    if (!nodes) return;
    
    const tableBody = document.getElementById('latest-nodes');
    if (!tableBody) return;
    
    // Get 5 most recently seen nodes
    const latestNodes = [...nodes]
        .sort((a, b) => new Date(b.last_seen) - new Date(a.last_seen))
        .slice(0, 5);
    
    let html = '';
    if (latestNodes.length === 0) {
        html = '<tr><td colspan="4">No nodes found</td></tr>';
    } else {
        latestNodes.forEach(node => {
            const statusClass = `status-${node.status.toLowerCase()}`;
            html += `
                <tr>
                    <td>${node.node_id}</td>
                    <td>${capitalizeFirst(node.node_type)}</td>
                    <td><span class="status-indicator ${statusClass}"></span> ${node.status}</td>
                    <td>${formatDate(node.last_seen)}</td>
                </tr>
            `;
        });
    }
    
    tableBody.innerHTML = html;
}

/**
 * Update activity feed
 */
function updateActivityFeed(activities) {
    if (!activities) return;
    
    const activityFeed = document.getElementById('activity-feed');
    if (!activityFeed) return;
    
    let html = '';
    if (activities.length === 0) {
        html = `
            <li class="activity-item">
                <span class="timestamp">Now</span>
                <span class="activity-message">No recent activity</span>
            </li>
        `;
    } else {
        activities.forEach(activity => {
            html += `
                <li class="activity-item">
                    <span class="timestamp">${formatDate(activity.timestamp)}</span>
                    <span class="activity-message">${activity.message}</span>
                </li>
            `;
        });
    }
    
    activityFeed.innerHTML = html;
}

/**
 * Node Management Functionality
 */
function initNodeManagement() {
    // Cache DOM elements
    const nodeSearch = document.getElementById('node-search');
    const nodeTypeFilter = document.getElementById('node-type-filter');
    const nodeStatusFilter = document.getElementById('node-status-filter');
    const addNodeBtn = document.getElementById('add-node-btn');
    const nodesTable = document.getElementById('nodes-table');
    
    // Fetch nodes data
    fetchNodesData();
    
    // Add event listeners
    if (nodeSearch) {
        nodeSearch.addEventListener('input', filterNodes);
    }
    
    if (nodeTypeFilter) {
        nodeTypeFilter.addEventListener('change', function() {
            state.filters.nodeType = this.value;
            filterNodes();
        });
    }
    
    if (nodeStatusFilter) {
        nodeStatusFilter.addEventListener('change', function() {
            state.filters.nodeStatus = this.value;
            filterNodes();
        });
    }
    
    if (addNodeBtn) {
        addNodeBtn.addEventListener('click', showAddNodeModal);
    }
    
    if (nodesTable) {
        nodesTable.addEventListener('click', function(e) {
            const target = e.target.closest('button');
            if (!target) return;
            
            const nodeId = target.dataset.nodeId;
            if (!nodeId) return;
            
            if (target.classList.contains('view-btn')) {
                showNodeDetails(nodeId);
            } else if (target.classList.contains('edit-btn')) {
                showEditNodeModal(nodeId);
            } else if (target.classList.contains('delete-btn')) {
                confirmDeleteNode(nodeId);
            }
        });
    }
    
    // Setup node type change event for modal
    const nodeTypeSelect = document.getElementById('node-type');
    if (nodeTypeSelect) {
        nodeTypeSelect.addEventListener

