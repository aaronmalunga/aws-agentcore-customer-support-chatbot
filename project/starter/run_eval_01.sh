#!/bin/bash

set -e

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

DATASET_URI="s3://$BUCKET/output_eval_dataset.jsonl"
RESULTS_URI="s3://$BUCKET/results/run-01/"

python - <<PY
import json

with open("eval-config.json") as f:
    eval_config = json.load(f)
eval_config["automated"]["datasetMetricConfigs"][0]["dataset"]["datasetLocation"]["s3Uri"] = "$DATASET_URI"
with open("eval-config-run-01.json", "w") as f:
    json.dump(eval_config, f, indent=2)

with open("output-config.json") as f:
    output_config = json.load(f)
output_config["s3Uri"] = "$RESULTS_URI"
with open("output-config-run-01.json", "w") as f:
    json.dump(output_config, f, indent=2)
PY

echo "Dataset:"
echo "$DATASET_URI"
echo
echo "Results:"
echo "$RESULTS_URI"
echo
echo "Creating Bedrock Evaluation Run 1..."

aws bedrock create-evaluation-job \
  --job-name support-chatbot-eval-run-1 \
  --role-arn "$ROLE_ARN" \
  --evaluation-config file://eval-config-run-01.json \
  --inference-config file://inference-config.json \
  --output-data-config file://output-config-run-01.json \
  --region us-east-1