# Rubric Mapping — Bedrock Flow + AgentCore Implementation

## Purpose

This document maps the Udacity project rubric to the implementation and evidence included in this submission.

The supplied project materials describe two related architectures:

1. The current project implementation uses the Amazon Bedrock AgentCore managed Harness, with routing and behavior implemented through `system_prompt.txt`.
2. The assessment rubric also explicitly requests an Amazon Bedrock Flow containing a classifier Prompt node, Condition-node routing, distinct paths, separate Output nodes, FAQ Prompt-node evidence, and `flow-tests.json`.

To make the submission unambiguous, both implementations are included and documented.

The Bedrock Flow provides explicit visual classification and routing evidence.

The AgentCore Harness provides the operational multi-turn chatbot, Gateway tool invocation, Lambda execution, DynamoDB persistence, and automated Bedrock Evaluation.

---

# 1. Classification and Routing

## Rubric Requirement

The project rubric requires a Bedrock Flow that:

- Classifies incoming customer messages
- Produces consistent and unambiguous classifier output
- Routes messages into distinct paths
- Uses distinct paths terminating at separate Output nodes

Required evidence includes:

- Full Flow diagram
- Classifier Prompt configuration
- Condition-node expressions

## Bedrock Flow Implementation

An Amazon Bedrock Flow named:

`customer-support-routing-flow`

was created in `us-east-1`.

The Flow contains:

- `Flow input`
- `ClassifierPrompt`
- `RoutingCondition`
- `BugReportPrompt`
- `FAQPrompt`
- `HumanHandoffPrompt`
- `BugReportOutput`
- `FAQOutput`
- `HumanHandoffOutput`

The classifier uses Amazon Nova Pro 1.0.

Its output is restricted to exactly one of:

- `BUG_REPORT`
- `PLATFORM_QUESTION`
- `OTHER`

Classifier inference settings include:

- Maximum output tokens: 20
- Temperature: 0
- Top P: 1

The classifier receives the original customer message through:

`topic`

with input expression:

`$.data`

## Classifier Behavior

The classifier routes:

### `BUG_REPORT`

Technical defects, crashes, application errors, broken functionality, and other website/software malfunctions.

Example:

`The checkout page crashes whenever I click Pay.`

### `PLATFORM_QUESTION`

Questions about the online shop, including:

- Orders
- Shipping
- Delivery
- Returns
- Refunds
- Payments
- Promotions
- Discounts
- Products
- Stock
- Accounts
- Privacy
- Shop policies

The classifier intentionally uses `PLATFORM_QUESTION` even when it is not yet known whether the FAQ contains the answer. The downstream `FAQPrompt` determines whether the question is covered.

### `OTHER`

Requests that are neither technical bugs nor questions about the online shop.

This also includes explicit requests for a human support representative.

## Classifier Validation

The classifier was manually validated before routing was added.

| Test | Expected Classification | Result |
|---|---|---|
| Checkout page crashes when Pay is clicked | `BUG_REPORT` | Passed |
| Return-window question | `PLATFORM_QUESTION` | Passed |
| Explicit request for a real person | `OTHER` | Passed |
| Payment declined at checkout | `PLATFORM_QUESTION` | Passed |

## Evidence

- `evidence/F10_bedrock-flow-full-diagram.png`
- `evidence/F11a_classifier-prompt-message.png`
- `evidence/F11b_classifier-inference-and-input.png`
- `evidence/F11c_classifier-output-configuration.png`

---

# 2. Condition-Node Routing

## Rubric Requirement

Messages must be routed into distinct paths based on classifier output.

## Implementation

`ClassifierPrompt.modelCompletion` is passed to:

`RoutingCondition.category`

The input is:

- Name: `category`
- Type: `String`
- Expression: `$.data`

The Condition node contains the following routes:

### Bug Report

Condition:

`category == "BUG_REPORT"`

Destination:

`BugReportPrompt`

### Platform Question

Condition:

`category == "PLATFORM_QUESTION"`

Destination:

`FAQPrompt`

### Default Outcome

If all explicit conditions are false, the Flow routes to:

`HumanHandoffPrompt`

Because the classifier is constrained to:

- `BUG_REPORT`
- `PLATFORM_QUESTION`
- `OTHER`

the default branch represents the `OTHER` route.

## Data and Conditional Connections

The Flow uses two different connection types.

### Data Connections

Solid data connections carry the actual customer message.

`Flow input.document` supplies the original message to:

- `ClassifierPrompt.topic`
- `BugReportPrompt.topic`
- `FAQPrompt.topic`
- `HumanHandoffPrompt.topic`

`ClassifierPrompt.modelCompletion` supplies the classification label to:

`RoutingCondition.category`

Each branch Prompt sends its generated response to its corresponding Flow Output.

### Conditional Connections

Conditional routing connections determine which branch executes:

`RoutingCondition` → `BugReportPrompt`

`RoutingCondition` → `FAQPrompt`

`RoutingCondition` → `HumanHandoffPrompt`

## Distinct Output Nodes

Each route terminates at its own Output node:

`BugReportPrompt` → `BugReportOutput`

`FAQPrompt` → `FAQOutput`

`HumanHandoffPrompt` → `HumanHandoffOutput`

## Evidence

- `evidence/F10_bedrock-flow-full-diagram.png`
- `evidence/F12_condition-node-expressions.png`

---

# 3. Bug Report Path — Bedrock Flow

## Rubric Intent

A technical issue must be identified as a bug report and the assistant must request the information required for a useful bug report.

## Bedrock Flow Implementation

`BugReportPrompt` requires:

1. `description`
2. `stepsToReproduce`
3. `environment`

The Prompt instructs the model to:

- Review what the customer already provided
- Ask for missing information
- Avoid inventing missing details
- Avoid claiming that a ticket exists
- Avoid inventing ticket identifiers

The Bedrock Flow bug-report path is:

`Flow input`

→ `ClassifierPrompt`

→ `RoutingCondition`

→ `BugReportPrompt`

→ `BugReportOutput`

## Manual Flow Validation

Prompt:

`The checkout page crashes whenever I click Pay.`

Result:

- Classified as `BUG_REPORT`
- Routed to `BugReportPrompt`
- Returned through `BugReportOutput`
- Requested additional bug-report information

The execution trace contained:

- `FlowInputNode`
- `ClassifierPrompt`
- `RoutingCondition`
- `BugReportPrompt`
- `BugReportOutput`

## Evidence

- `evidence/F20a_bug-report-prompt-message.png`
- `evidence/F20b_bug-report-prompt-inference-and-input.png`
- `evidence/F20c_bug-report-prompt-output.png`
- `evidence/F30a_flow-test-bug-report-response.png`
- `evidence/F30b_flow-test-bug-report-trace.png`

---

# 4. Operational Bug Report Path — AgentCore

## Rubric Requirement

The operational bug-report path must use the AgentCore managed Harness and create a real ticket through the AgentCore Gateway.

## AgentCore Implementation

The operational bug-report workflow is implemented through:

`system_prompt.txt`

The assistant collects:

- `description`
- `stepsToReproduce`
- `environment`

The system prompt includes a tool-call gate that prevents successful ticket creation until all required information has been collected.

Once all three fields are available, the Harness invokes:

`bugreports___create_bug_report`

through the Amazon Bedrock AgentCore Gateway.

The Gateway invokes:

`bug-report-tool-stack-create-bug-report`

The Lambda function persists the ticket in:

`bug-report-tool-stack-bug-reports`

in Amazon DynamoDB.

## Ticket-ID Safety

The system prompt specifies that:

- A ticket does not exist until the tool succeeds
- Ticket IDs must not be invented
- The successful tool result is the only valid source of the ticket ID
- The exact returned `ticketId` must be relayed to the customer

## Successful End-to-End Validation

A multi-turn conversation collected:

1. Bug description
2. Steps to reproduce
3. Environment

The assistant then invoked:

`[tool call] bugreports___create_bug_report`

The successful chatbot-created ticket ID was:

`01de0487-2147-4ff8-a964-ca7134df4b3b`

The exact same ID was independently verified in DynamoDB with status:

`OPEN`

## Evidence

- `system_prompt.txt`
- `bug-report-transcript.txt`
- `dynamodb-tickets.txt`
- `evidence/E21a_bug-report-collection.png`
- `evidence/E21b_tool-call-gate.png`
- `evidence/E22_bug-report-ticket-id-rule.png`
- `evidence/E30_bug-report-transcript.png`
- `evidence/E32_dynamodb-chatbot-ticket-table.png`
- `evidence/E33_dynamodb-chatbot-ticket-details.png`

Additional isolated backend validation:

- `evidence/E10_lambda-test-success.png`
- `evidence/E11_dynamodb-isolated-ticket.png`

---

# 5. Platform Question Path — Bedrock Flow

## Rubric Requirement

The application must:

- Answer a question when it is covered by the FAQ
- Direct the customer to human support when a platform question is not covered
- Use a Prompt node containing embedded FAQ content

## Implementation

`FAQPrompt` contains the FAQ content directly in the Flow Prompt.

It instructs the model to:

- Answer only from the embedded FAQ
- Avoid inventing shop policies
- State when requested information is not documented
- Direct unsupported requests to the documented support contact

The documented support phone number is:

`1-800-555-0147`

## Covered FAQ Validation

Prompt:

`How long do I have to return an item?`

Result:

- Classified as `PLATFORM_QUESTION`
- Routed through `FAQPrompt`
- Returned through `FAQOutput`
- Correctly stated the documented 30-day return period

Execution trace:

- `FlowInputNode`
- `ClassifierPrompt`
- `RoutingCondition`
- `FAQPrompt`
- `FAQOutput`

## Uncovered FAQ Validation

Prompt:

`Do you offer a student discount?`

Result:

- Classified as `PLATFORM_QUESTION`
- Routed through `FAQPrompt`
- Did not invent a student-discount policy
- Stated that the requested information was not documented
- Directed the customer to `1-800-555-0147`

Execution trace:

- `FlowInputNode`
- `ClassifierPrompt`
- `RoutingCondition`
- `FAQPrompt`
- `FAQOutput`

## Evidence

- `evidence/F21a_faq-prompt-message-and-embedded-content.png`
- `evidence/F21b_faq-prompt-inference-and-input.png`
- `evidence/F21c_faq-prompt-output.png`
- `evidence/F31a_flow-test-covered-faq-response.png`
- `evidence/F31b_flow-test-covered-faq-trace.png`
- `evidence/F32a_flow-test-uncovered-faq-response.png`
- `evidence/F32b_flow-test-uncovered-faq-trace.png`

AgentCore FAQ evidence:

- `online_shop_faq.md`
- `system_prompt.txt`
- `evidence/E23_platform-question-and-handoff-behavior.png`
- `evidence/E24_faq-placeholder.png`
- `evidence/E25_faq-and-handoff-live-tests.png`

---

# 6. Other Request / Human Handoff Path

## Rubric Requirement

A separate path must exist for other requests and direct the customer to human support.

## Bedrock Flow Implementation

`OTHER` requests follow the default branch of `RoutingCondition` and execute:

`HumanHandoffPrompt`

The response terminates at:

`HumanHandoffOutput`

The Prompt uses the documented customer-support number:

`1-800-555-0147`

## Manual Validation

Prompt:

`I'd like to speak to a real person.`

Result:

- Classified as `OTHER`
- Followed the default Condition branch
- Routed through `HumanHandoffPrompt`
- Returned through `HumanHandoffOutput`
- Directed the customer to `1-800-555-0147`

Execution trace:

- `FlowInputNode`
- `ClassifierPrompt`
- `RoutingCondition`
- `HumanHandoffPrompt`
- `HumanHandoffOutput`

## Evidence

- `evidence/F22a_human-handoff-prompt-message.png`
- `evidence/F22b_human-handoff-inference-and-input.png`
- `evidence/F22c_human-handoff-output.png`
- `evidence/F33a_flow-test-other-response.png`
- `evidence/F33b_flow-test-other-trace.png`

AgentCore handoff evidence:

- `evidence/E20b_system-prompt-routes-2-3.png`
- `evidence/E23_platform-question-and-handoff-behavior.png`
- `evidence/E25_faq-and-handoff-live-tests.png`

---

# 7. Flow Test Manifest

The submission includes:

`flow-tests.json`

It documents four manually validated Bedrock Flow scenarios:

| Test | Route |
|---|---|
| Checkout crash | Bug Report |
| Return-window FAQ | Platform Question |
| Student discount | Platform Question / uncovered FAQ |
| Explicit request for a human | Other / Human Handoff |

The corresponding response and execution-trace screenshots are included in the evidence directory.

---

# 8. AgentCore Automated Testing and Bedrock Evaluation

## Current Testing Framework

The current project Testing Framework uses:

`harness-tests.json`

The file contains six tests:

| Test ID | Scenario |
|---|---|
| `t1_bug_report_partial` | Partial bug report |
| `t2_faq_return_window` | Return-window FAQ |
| `t3_faq_guest_checkout` | Guest checkout |
| `t4_faq_missing_confirmation` | Missing confirmation email |
| `t5_unsupported_student_discount` | Unsupported discount |
| `t6_explicit_human_handoff` | Explicit human request |

The automated test script:

`generate-eval-dataset.py`

invoked the AgentCore Harness for each test and produced:

`output_eval_dataset.jsonl`

The generated dataset contained:

- 6 records
- 6 successful Harness calls
- 0 `[HARNESS_ERROR]` records

## Bedrock Evaluation

Evaluation job:

`support-chatbot-eval-run-1`

Metric:

`Builtin.Correctness`

Evaluator model:

`amazon.nova-pro-v1:0`

Result:

- Overall Correctness: **1.00**
- Total prompts: **6**
- Individual prompts scoring 1.00: **6 of 6**

The score represents correctness across the six defined evaluation scenarios.

## Testing-Artifact Clarification

The supplied project materials reference both:

`flow-tests.json`

and:

`harness-tests.json`

This submission therefore includes both.

`flow-tests.json` documents the manually validated Bedrock Flow scenarios.

`harness-tests.json` is the automated AgentCore test suite actually used by `generate-eval-dataset.py` to generate the JSONL dataset evaluated by Amazon Bedrock Evaluations.

The submission does not claim that the AgentCore evaluation JSONL was generated by invoking the visual Bedrock Flow.

## Evidence

- `flow-tests.json`
- `harness-tests.json`
- `output_eval_dataset.jsonl`
- `OBSERVATIONS.md`
- `evidence/E50_E51_eval-summary-distribution.png`
- `evidence/E52_eval-per-prompt-results.png`
- Flow response and trace screenshots `F30` through `F33`

---

# 9. AgentCore System Prompt Evidence

The operational Harness still uses prompt-based routing inside:

`system_prompt.txt`

The three operational behaviors are:

1. Bug Report
2. Platform Question
3. Human Handoff

The FAQ is supplied through:

`{{FAQ}}`

which is replaced with the contents of:

`online_shop_faq.md`

when the Harness is created.

Evidence:

- `evidence/E20a_system-prompt-route-1-bug-report.png`
- `evidence/E20b_system-prompt-routes-2-3.png`
- `evidence/E21a_bug-report-collection.png`
- `evidence/E21b_tool-call-gate.png`
- `evidence/E22_bug-report-ticket-id-rule.png`
- `evidence/E23_platform-question-and-handoff-behavior.png`
- `evidence/E24_faq-placeholder.png`

---

# 10. Course-Supplied Script Modification Disclosure

`create_harness.py` was intentionally modified to disable persistent AgentCore memory:

`memory={"disabled": {}}`

This was done to isolate automated evaluation sessions and prevent earlier conversations from influencing later tests.

No attempt is made to conceal this modification.

The operational behavior and reason for the change are also documented in:

`OBSERVATIONS.md`

---

# 11. Architecture Evidence

Two complementary architecture views are included.

## Bedrock Flow Architecture

`evidence/F10_bedrock-flow-full-diagram.png`

shows:

`Flow input`

→ `ClassifierPrompt`

→ `RoutingCondition`

→ three conditional routes

→ three Prompt nodes

→ three separate Flow Output nodes

## AgentCore Runtime Architecture

`ARCHITECTURE.md`

and:

`evidence/E40_architecture-diagram.png`

show the operational runtime:

Customer

→ `chat.py`

→ AgentCore Harness

→ routing behavior

→ FAQ / handoff

or:

→ AgentCore Gateway

→ Lambda

→ DynamoDB

The two diagrams represent complementary parts of the submission rather than conflicting implementations.

---

# 12. Requirement Summary

| Rubric Area | Implementation | Status |
|---|---|---|
| Bedrock Flow | Actual Bedrock Flow created | Complete |
| Classifier | `ClassifierPrompt` | Complete |
| Consistent classifier output | `BUG_REPORT`, `PLATFORM_QUESTION`, `OTHER` | Complete |
| Condition routing | `RoutingCondition` | Complete |
| Distinct paths | Three branches | Complete |
| Separate Output nodes | Three Flow Outputs | Complete |
| Bug Prompt | `BugReportPrompt` | Complete |
| FAQ Prompt with embedded FAQ | `FAQPrompt` | Complete |
| Other/Handoff Prompt | `HumanHandoffPrompt` | Complete |
| Covered FAQ Flow test | 30-day return question | Passed |
| Uncovered FAQ Flow test | Student discount | Passed |
| Other-request Flow test | Human request | Passed |
| Bug Flow test | Checkout crash | Passed |
| AgentCore Harness | Operational implementation | Complete |
| Gateway tool invocation | `bugreports___create_bug_report` | Complete |
| Lambda | Bug-report backend | Complete |
| DynamoDB | Ticket persistence | Complete |
| Real chatbot ticket | Matching ticket ID verified | Complete |
| `flow-tests.json` | Flow validation manifest | Complete |
| `harness-tests.json` | Automated Harness tests | Complete |
| JSONL dataset | 6 records, no Harness errors | Complete |
| Bedrock Evaluation | Run 1 | Complete |
| Correctness | 1.00 across 6 prompts | Complete |
| Written observations | `OBSERVATIONS.md` | Complete |

---

# Conclusion

The submission implements both the explicit Bedrock Flow requested by the rubric and the Amazon Bedrock AgentCore managed Harness described by the current project implementation.

The Bedrock Flow demonstrates:

- Explicit classification
- Condition-node routing
- Three distinct paths
- Three separate Output nodes
- Embedded FAQ grounding
- Covered FAQ behavior
- Uncovered FAQ behavior
- Human handoff
- Bug-report information collection

The AgentCore implementation demonstrates:

- Multi-turn conversation handling
- Prompt-based operational routing
- AgentCore Gateway tool invocation
- Lambda execution
- DynamoDB persistence
- Exact ticket-ID verification
- Automated testing
- Amazon Bedrock Evaluations
- Overall correctness of **1.00 across six defined evaluation prompts**

Together, the artifacts provide direct evidence for both forms of implementation described in the supplied project materials.