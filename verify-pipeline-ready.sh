#!/bin/bash
echo "=== Pre-Flight Checks ==="

# Check Jenkins
JENKINS_IP=$(cd terraform && terraform output -raw jenkins_public_ip)
echo -n "1. Jenkins (port 8080): "
timeout 5 bash -c "echo > /dev/tcp/$JENKINS_IP/8080" && echo "✓ OK" || echo "✗ FAILED"

# Check SonarQube
echo -n "2. SonarQube (port 9000): "
timeout 5 bash -c "echo > /dev/tcp/$JENKINS_IP/9000" && echo "✓ OK" || echo "✗ FAILED"

# Check App Server
APP_IP=$(cd terraform && terraform output -raw app_server_public_ip)
echo -n "3. App Server SSH: "
timeout 5 bash -c "echo > /dev/tcp/$APP_IP/22" && echo "✓ OK" || echo "✗ FAILED"

# Check Monitoring
MON_IP=$(cd terraform && terraform output -raw monitoring_public_ip)
echo -n "4. Prometheus (port 9090): "
timeout 5 bash -c "echo > /dev/tcp/$MON_IP/9090" && echo "✓ OK" || echo "✗ FAILED"

echo -n "5. Grafana (port 3000): "
timeout 5 bash -c "echo > /dev/tcp/$MON_IP/3000" && echo "✓ OK" || echo "✗ FAILED"

# Check if project has pom.xml
echo -n "6. Maven project (pom.xml): "
if [ -f "BoardGame/pom.xml" ]; then
    echo "✓ OK"
else
    echo "✗ NOT FOUND"
fi

# Check Jenkinsfile
echo -n "7. Jenkinsfile: "
if [ -f "BoardGame/Jenkinsfile" ]; then
    echo "✓ OK"
else
    echo "✗ NOT FOUND"
fi

# Check Dockerfile
echo -n "8. Dockerfile: "
if [ -f "BoardGame/Dockerfile" ]; then
    echo "✓ OK"
else
    echo "✗ NOT FOUND"
fi

echo ""
echo "=== Checks Complete ==="
