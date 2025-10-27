#!/bin/bash
cd ../terraform
JENKINS_IP=$(terraform output -raw jenkins_public_ip)
echo "Getting Jenkins initial admin password..."
ssh -i ../rrskey.pub ubuntu@$JENKINS_IP "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
