#!/bin/bash
set -e
cd "$(dirname "$0")/../frontend"
npm ci
npm run build
BUILD_DIR="build"
[ ! -d "$BUILD_DIR" ] && BUILD_DIR="dist"
aws s3 sync $BUILD_DIR s3://$S3_BUCKET_NAME --delete
aws cloudfront create-invalidation \
  --distribution-id $CLOUDFRONT_DISTRIBUTION_ID \
  --paths "/*"
echo "Done. Live at https://$CLOUDFRONT_DOMAIN"