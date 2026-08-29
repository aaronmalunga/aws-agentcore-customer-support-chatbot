#!/bin/bash

set -e

BUCKET=$(aws cloudformation describe-stacks \
  --stack-name bug-report-testing-stack \
  --region us-east-1 \
  --query "Stacks[0].Outputs[?OutputKey=='EvalDatasetBucketName'].OutputValue | [0]" \
  --output text)

mkdir -p eval-results-backup

echo "Backing up Bedrock evaluation results from:"
echo "s3://$BUCKET/results/"
echo

aws s3 sync \
  "s3://$BUCKET/results/" \
  ./eval-results-backup/ \
  --region us-east-1

echo
echo "Backup complete."
echo "Local folder: eval-results-backup/"