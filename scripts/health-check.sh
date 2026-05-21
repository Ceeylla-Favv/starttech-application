#!/bin/bash
HOST=${1:-$ALB_DNS_NAME}
echo "Checking http://$HOST/health"
for i in {1..5}; do
  curl -s http://$HOST/health | jq .
  sleep 3
done