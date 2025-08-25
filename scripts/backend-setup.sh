#!/bin/bash
# Backend EC2 instance setup script

# Update system
yum update -y

# Install necessary packages
yum install -y httpd php php-mysqlnd mysql

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create backend API endpoints
mkdir -p /var/www/html/api

# Health check endpoint
cat > /var/www/html/index.php << 'EOF'
<?php
header('Content-Type: application/json');

$response = array(
    'status' => 'success',
    'message' => 'Backend API is running',
    'timestamp' => date('c'),
    'server_ip' => $_SERVER['SERVER_ADDR']
);

echo json_encode($response, JSON_PRETTY_PRINT);
?>
EOF

# Database connection test endpoint
cat > /var/www/html/db-test.php << EOF
<?php
header('Content-Type: application/json');

\$db_host = '${db_endpoint}';
\$db_name = '${db_name}';
\$db_user = '${db_username}';
\$db_pass = '${db_password}';

try {
    \$dsn = "mysql:host=\$db_host;dbname=\$db_name";
    \$pdo = new PDO(\$dsn, \$db_user, \$db_pass);
    \$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Test query
    \$stmt = \$pdo->query('SELECT VERSION() as version, NOW() as current_time');
    \$result = \$stmt->fetch(PDO::FETCH_ASSOC);
    
    \$response = array(
        'status' => 'success',
        'message' => 'Database connection successful',
        'database_version' => \$result['version'],
        'current_time' => \$result['current_time'],
        'endpoint' => \$db_host
    );
    
} catch(PDOException \$e) {
    \$response = array(
        'status' => 'error',
        'message' => 'Database connection failed: ' . \$e->getMessage(),
        'endpoint' => \$db_host
    );
}

echo json_encode(\$response, JSON_PRETTY_PRINT);
?>
EOF

# API endpoint for health check
cat > /var/www/html/health << 'EOF'
Backend API Health Check - OK
EOF

# Create sample data API endpoint
cat > /var/www/html/api/users.php << EOF
<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

\$db_host = '${db_endpoint}';
\$db_name = '${db_name}';
\$db_user = '${db_username}';
\$db_pass = '${db_password}';

try {
    \$dsn = "mysql:host=\$db_host;dbname=\$db_name";
    \$pdo = new PDO(\$dsn, \$db_user, \$db_pass);
    \$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Create users table if it doesn't exist
    \$pdo->exec("CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(100) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )");
    
    // Insert sample data if table is empty
    \$count = \$pdo->query("SELECT COUNT(*) FROM users")->fetchColumn();
    if (\$count == 0) {
        \$pdo->exec("INSERT INTO users (name, email) VALUES 
            ('John Doe', 'john@example.com'),
            ('Jane Smith', 'jane@example.com'),
            ('Bob Johnson', 'bob@example.com')
        ");
    }
    
    // Fetch users
    \$stmt = \$pdo->query("SELECT * FROM users ORDER BY created_at DESC");
    \$users = \$stmt->fetchAll(PDO::FETCH_ASSOC);
    
    \$response = array(
        'status' => 'success',
        'data' => \$users,
        'count' => count(\$users)
    );
    
} catch(PDOException \$e) {
    \$response = array(
        'status' => 'error',
        'message' => 'Database error: ' . \$e->getMessage()
    );
}

echo json_encode(\$response, JSON_PRETTY_PRINT);
?>
EOF

# Restart Apache
systemctl restart httpd

# Wait for database to be available
echo "Waiting for database to be available..."
until nc -z ${db_endpoint} 3306; do
    echo "Database not ready yet, waiting..."
    sleep 10
done

echo "Backend setup completed!"
EOF