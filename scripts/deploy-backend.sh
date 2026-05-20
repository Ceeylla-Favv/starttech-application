#!/bin/bash
set -e
IMAGE_TAG=${1:-latest}
cd "$(dirname "$0")/../backend"
docker build -t $ECR_REPOSITORY_URL:$IMAGE_TAG .
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $ECR_REPOSITORY_URL
docker push $ECR_REPOSITORY_URL:$IMAGE_TAG
echo "Pushed $ECR_REPOSITORY_URL:$IMAGE_TAG"