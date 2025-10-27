#!/bin/bash
cd ../terraform
MON_IP=$(terraform output -raw monitoring_public_ip)
echo "Connecting to Monitoring server at $MON_IP"
ssh -i ../rrskey.pub ubuntu@$MON_IP
