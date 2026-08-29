#!/bin/bash

BUCKET=$(aws cloudformation describe-stacks \
  --stack-name bug-report-testing-stack \
  --region us-east-1 \
  --query "Stacks[0].Outputs[?OutputKey=='EvalDatasetBucketName'].OutputValue | [0]" \
  --output text)

ROLE_ARN=$(aws cloudformation describe-stacks \
  --stack-name bug-report-testing-stack \
  --region us-east-1 \
  --query "Stacks[0].Outputs[?OutputKey=='BedrockEvalRoleArn'].OutputValue | [0]" \
  --output text)

echo "Evaluation bucket:"
echo "$BUCKET"

echo
echo "Evaluation role ARN:"
echo "$ROLE_ARN"