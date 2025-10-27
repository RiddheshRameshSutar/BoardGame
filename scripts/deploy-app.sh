#!/bin/bash
set -e

echo "=== Deploying BoardGame Application ==="

# Get app server IP
cd ../terraform
APP_IP=$(terraform output -raw app_server_public_ip)

echo "Deploying to: $APP_IP"

# Copy JAR file
scp -i ../rrskey.pub ../app-source/target/*.jar ubuntu@$APP_IP:/opt/boardgame-app/boardgame.jar

# Deploy application
ssh -i ../rrskey.pub ubuntu@$APP_IP << 'ENDSSH'
    cd /opt/boardgame-app
    
    # Stop existing process
    pkill -f boardgame.jar || true
    
    # Start application
    nohup java -jar boardgame.jar > app.log 2>&1 &
    
    echo "Application started"
    sleep 5
    
    # Check if running
    if curl -f http://localhost:2255; then
        echo "✓ Application is running"
    else
        echo "✗ Application failed to start"
        exit 1
    fi
ENDSSH

echo "=== Deployment Complete ==="
