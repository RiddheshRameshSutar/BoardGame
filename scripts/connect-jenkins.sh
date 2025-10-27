#!/bin/bash
cd ../terraform
JENKINS_IP=$(terraform output -raw jenkins_public_ip)
echo "Connecting to Jenkins server at $JENKINS_IP"
ssh -i ../rrskey.pub ubuntu@$JENKINS_IP
