# Customer Support Chatbot with Amazon Bedrock AgentCore

## Project Overview

This project implements an AI customer-support chatbot for an online shop using Amazon Bedrock services.

The solution supports three customer-request behaviors:

1. Technical bug reports
2. Platform / FAQ questions
3. Human-support handoff

The project includes both an Amazon Bedrock Flow and an Amazon Bedrock AgentCore managed Harness.

---

## Implementation Note

The supplied project materials contain two related implementation descriptions.

The current project instructions use the Amazon Bedrock AgentCore managed Harness for the operational chatbot, including prompt-based routing, multi-turn bug-report collection, AgentCore Gateway tool invocation, Lambda execution, DynamoDB persistence, and Bedrock Evaluations.

The assessment rubric also explicitly requests an Amazon Bedrock Flow containing a classifier, Condition-node routing, Prompt nodes, separate Output nodes, and Flow test evidence.

To satisfy both requirements clearly, this submission implements both.

### Amazon Bedrock Flow

The Bedrock Flow provides explicit visual classification and routing.

Flow structure:

- Flow Input
- ClassifierPrompt
- RoutingCondition
- BugReportPrompt
- FAQPrompt
- HumanHandoffPrompt
- BugReportOutput
- FAQOutput
- HumanHandoffOutput

The classifier produces exactly one of:

- `BUG_REPORT`
- `PLATFORM_QUESTION`
- `OTHER`

The RoutingCondition maps these outcomes to three distinct branches.

`OTHER` is handled through the Condition node's default branch.

### Amazon Bedrock AgentCore Harness

The AgentCore Harness is the operational chatbot implementation.

It provides:

- Multi-turn conversation handling
- Prompt-based routing
- FAQ grounding using `{{FAQ}}`
- Bug-report information collection
- AgentCore Gateway tool invocation
- AWS Lambda integration
- DynamoDB ticket persistence
- Exact ticket-ID relay
- Automated evaluation using Amazon Bedrock Evaluations

---

# Architecture

## Bedrock Flow

```text
Flow Input
    |
    v
ClassifierPrompt
    |
    v
RoutingCondition
    |
    +-- BUG_REPORT ----------> BugReportPrompt -------> BugReportOutput
    |
    +-- PLATFORM_QUESTION ---> FAQPrompt -------------> FAQOutput
    |
    +-- Default / OTHER -----> HumanHandoffPrompt ---> HumanHandoffOutput