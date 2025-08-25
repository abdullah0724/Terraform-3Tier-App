#!/bin/bash
# Frontend EC2 instance setup script

# Update system
yum update -y

# Install necessary packages
yum install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create a simple HTML page that demonstrates connection to backend
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>3-Tier App Frontend</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .info {
            background: #e9ecef;
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
        }
        .backend-status {
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
        }
        .success { background-color: #d4edda; color: #155724; }
        .error { background-color: #f8d7da; color: #721c24; }
        button {
            background-color: #007bff;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin: 5px;
        }
        button:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🌐 3-Tier Application Frontend</h1>
        
        <div class="info">
            <h3>Application Architecture</h3>
            <p><strong>Tier 1 (Frontend):</strong> This EC2 instance in public subnet</p>
            <p><strong>Tier 2 (Backend):</strong> Private EC2 instance (${backend_private_ip})</p>
            <p><strong>Tier 3 (Database):</strong> Private RDS MySQL database</p>
        </div>

        <div class="info">
            <h3>Security Configuration</h3>
            <ul>
                <li>Frontend accessible from internet on ports 80/443</li>
                <li>Backend accessible only from frontend on ports 80/443</li>
                <li>Database accessible only from backend on port 3306</li>
            </ul>
        </div>

        <div id="backend-test">
            <h3>Backend Connection Test</h3>
            <button onclick="testBackend()">Test Backend Connection</button>
            <div id="backend-result"></div>
        </div>
    </div>

    <script>
        async function testBackend() {
            const resultDiv = document.getElementById('backend-result');
            resultDiv.innerHTML = '<div class="info">Testing connection to backend...</div>';
            
            try {
                const response = await fetch('/api/health');
                if (response.ok) {
                    const data = await response.text();
                    resultDiv.innerHTML = '<div class="backend-status success">✅ Backend connection successful!</div>';
                } else {
                    resultDiv.innerHTML = '<div class="backend-status error">❌ Backend connection failed</div>';
                }
            } catch (error) {
                resultDiv.innerHTML = '<div class="backend-status error">❌ Backend connection error: ' + error.message + '</div>';
            }
        }
    </script>
</body>
</html>
EOF

# Create a proxy configuration to forward /api requests to backend
cat > /etc/httpd/conf.d/proxy.conf << EOF
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so

ProxyPreserveHost On
ProxyRequests Off

# Proxy API requests to backend
ProxyPass /api/ http://${backend_private_ip}/
ProxyPassReverse /api/ http://${backend_private_ip}/
EOF

# Restart Apache to apply configuration
systemctl restart httpd

# Create a simple health check endpoint
cat > /var/www/html/health.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Frontend Health Check</title></head>
<body>
    <h1>Frontend is running!</h1>
    <p>Timestamp: <script>document.write(new Date().toISOString());</script></p>
</body>
</html>
EOF