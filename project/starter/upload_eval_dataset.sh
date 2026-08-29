#!/bin/bash

BUCKET=$(aws cloudformation describe-stacks \
  --stack-name bug-report-testing-stack \
  --region us-east-1 \
  --query "Stacks[0].Outputs[?OutputKey=='EvalDatasetBucketName'].OutputValue | [0]" \
  --output text)

echo "Uploading evaluation dataset to:"
echo "s3://$BUCKET/output_eval_dataset.jsonl"

aws s3 cp \
  output_eval_dataset.jsonl \
  "s3://$BUCKET/output_eval_dataset.jsonl" \
  --region us-east-1