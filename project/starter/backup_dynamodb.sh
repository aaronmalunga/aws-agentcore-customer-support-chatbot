#!/bin/bash

set -e

aws dynamodb scan \
  --table-name bug-report-tool-stack-bug-reports \
  --region us-east-1 \
  --output json \
  > dynamodb-tickets.json

echo "DynamoDB backup complete."
echo "Saved to dynamodb-tickets.json"