#!/bin/bash
set -e
TAG=${1:?Usage: ./rollback.sh <image-tag>}
echo "Rolling back to $TAG..."
INSTANCES=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=starttech-backend" \
            "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances[*].InstanceId" --output text)
for ID in $INSTANCES; do
  aws ssm send-command \
    --instance-ids "$ID" \
    --document-name "AWS-RunShellScript" \
    --parameters commands="[
      'docker pull $ECR_REPOSITORY_URL:$TAG',
      'docker stop backend || true',
      'docker rm backend || true',
      'docker run -d --name backend --restart always -p 8080:8080 $ECR_REPOSITORY_URL:$TAG'
    ]"
  echo "Rolled back $ID"
  sleep 20
  done