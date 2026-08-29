# Evidence Index

## Customer Support Chatbot with Amazon Bedrock AgentCore

This directory index maps the project requirements to the corresponding implementation artifacts and screenshots.

The submission contains two complementary evidence groups:

- **E-series:** Amazon Bedrock AgentCore operational implementation and automated evaluation
- **F-series:** Amazon Bedrock Flow classification, routing, Prompt-node, Output-node, and Flow-test evidence

Screenshots should be stored under:

`evidence/`

---

# Primary Rubric Evidence

For a quick review, the highest-priority screenshots are:

| Evidence | Demonstrates |
|---|---|
| `evidence/F10_bedrock-flow-full-diagram.png` | Complete Bedrock Flow with three branches and separate outputs |
| `evidence/F11a_classifier-prompt-message.png` | Classifier Prompt configuration |
| `evidence/F12_condition-node-expressions.png` | Condition expressions and downstream routes |
| `evidence/F21a_faq-prompt-message-and-embedded-content.png` | FAQ Prompt with embedded FAQ content |
| `evidence/F30a_flow-test-bug-report-response.png` | Bug Flow response |
| `evidence/F31a_flow-test-covered-faq-response.png` | Covered FAQ Flow response |
| `evidence/F32a_flow-test-uncovered-faq-response.png` | Uncovered FAQ Flow response |
| `evidence/F33a_flow-test-other-response.png` | Other/Human Handoff Flow response |
| `evidence/E30_bug-report-transcript.png` | AgentCore multi-turn bug report and real tool invocation |
| `evidence/E33_dynamodb-chatbot-ticket-details.png` | Matching chatbot-created DynamoDB ticket |
| `evidence/E50_E51_eval-summary-distribution.png` | Bedrock Evaluation correctness 1.00 |
| `evidence/E52_eval-per-prompt-results.png` | All six evaluation prompts scored 1.00 |
| `evidence/E40_architecture-diagram.png` | AgentCore runtime architecture |

---

# A. Bedrock Flow Evidence

## F10 — Full Bedrock Flow

**File:**

`evidence/F10_bedrock-flow-full-diagram.png`

Shows the complete visual Flow containing:

- Flow input
- ClassifierPrompt
- RoutingCondition
- BugReportPrompt
- FAQPrompt
- HumanHandoffPrompt
- BugReportOutput
- FAQOutput
- HumanHandoffOutput

The screenshot also shows the three conditional branches and separate Flow outputs.

---

## F11 — Classifier Prompt Configuration

### F11a

`evidence/F11a_classifier-prompt-message.png`

Shows:

- Node name `ClassifierPrompt`
- Nova Pro 1.0
- Three valid labels:
  - `BUG_REPORT`
  - `PLATFORM_QUESTION`
  - `OTHER`
- Classification rules

### F11b

`evidence/F11b_classifier-inference-and-input.png`

Shows:

- Maximum output tokens: 20
- Temperature: 0
- Top P: 1
- Input `topic`
- Type `String`
- Expression `$.data`

### F11c

`evidence/F11c_classifier-output-configuration.png`

Shows:

- `modelCompletion`
- Output type `String`
- Classifier connection configuration

---

# B. Condition-Node Evidence

## F12 — Routing Condition

**File:**

`evidence/F12_condition-node-expressions.png`

Shows the `RoutingCondition` configuration, including:

### Input

- Name: `category`
- Type: `String`
- Expression: `$.data`

### BugReport Condition

Condition:

`category == "BUG_REPORT"`

Go to:

`BugReportPrompt`

### PlatformQuestion Condition

Condition:

`category == "PLATFORM_QUESTION"`

Go to:

`FAQPrompt`

### Default Condition

If all explicit conditions are false:

`HumanHandoffPrompt`

Because `ClassifierPrompt` is constrained to output only:

- `BUG_REPORT`
- `PLATFORM_QUESTION`
- `OTHER`

the default branch represents the `OTHER` / Human Handoff route.

This single screenshot provides the Condition-node expression and routing evidence for all three paths.

---

# C. Bedrock Flow Bug Report Prompt

## F20a

`evidence/F20a_bug-report-prompt-message.png`

Shows `BugReportPrompt` and its instructions to collect:

- `description`
- `stepsToReproduce`
- `environment`

It also shows instructions not to invent missing information or falsely claim a ticket exists.

## F20b

`evidence/F20b_bug-report-prompt-inference-and-input.png`

Shows:

- Nova Pro 1.0
- Maximum output tokens: 256
- Temperature: 0
- Top P: 1
- Input `topic`
- Expression `$.data`

## F20c

`evidence/F20c_bug-report-prompt-output.png`

Shows:

- `modelCompletion`
- Output type `String`
- Output connection configuration

---

# D. Bedrock Flow FAQ Prompt

## F21a

`evidence/F21a_faq-prompt-message-and-embedded-content.png`

Shows:

- `FAQPrompt`
- Instructions to answer only from the supplied FAQ
- Embedded FAQ content
- Unsupported-question behavior
- Documented support information

## F21b

`evidence/F21b_faq-prompt-inference-and-input.png`

Shows:

- Maximum output tokens: 256
- Temperature: 0
- Top P: 1
- Input `topic`
- Expression `$.data`

## F21c

`evidence/F21c_faq-prompt-output.png`

Shows the FAQ Prompt output configuration.

---

# E. Bedrock Flow Human Handoff Prompt

## F22a

`evidence/F22a_human-handoff-prompt-message.png`

Shows:

- `HumanHandoffPrompt`
- Human-support behavior
- Documented support number:
  `1-800-555-0147`
- Instructions not to invent unsupported information

## F22b

`evidence/F22b_human-handoff-inference-and-input.png`

Shows:

- Maximum output tokens: 128
- Temperature: 0
- Top P: 1
- Input `topic`
- Expression `$.data`

## F22c

`evidence/F22c_human-handoff-output.png`

Shows the Human Handoff Prompt output configuration.

---

# F. Bedrock Flow Test Evidence

## F30 — Bug Report Flow Test

### Response

`evidence/F30a_flow-test-bug-report-response.png`

Prompt:

`The checkout page crashes whenever I click Pay.`

Demonstrates:

- `BugReportOutput`
- Customer-facing request for missing bug details

### Trace

`evidence/F30b_flow-test-bug-report-trace.png`

Shows execution through:

- FlowInputNode
- ClassifierPrompt
- RoutingCondition
- BugReportPrompt
- BugReportOutput

---

## F31 — Covered FAQ Flow Test

### Response

`evidence/F31a_flow-test-covered-faq-response.png`

Prompt:

`How long do I have to return an item?`

Demonstrates:

- `FAQOutput`
- Grounded 30-day return answer

### Trace

`evidence/F31b_flow-test-covered-faq-trace.png`

Shows execution through:

- FlowInputNode
- ClassifierPrompt
- RoutingCondition
- FAQPrompt
- FAQOutput

---

## F32 — Uncovered FAQ Flow Test

### Response

`evidence/F32a_flow-test-uncovered-faq-response.png`

Prompt:

`Do you offer a student discount?`

Demonstrates:

- `FAQOutput`
- No invented student-discount policy
- Handoff to documented support
- `1-800-555-0147`

### Trace

`evidence/F32b_flow-test-uncovered-faq-trace.png`

Shows execution through:

- FlowInputNode
- ClassifierPrompt
- RoutingCondition
- FAQPrompt
- FAQOutput

---

## F33 — Other / Human Handoff Flow Test

### Response

`evidence/F33a_flow-test-other-response.png`

Prompt:

`I'd like to speak to a real person.`

Demonstrates:

- `HumanHandoffOutput`
- Human-support response
- Correct support number:
  `1-800-555-0147`

### Trace

`evidence/F33b_flow-test-other-trace.png`

Shows execution through:

- FlowInputNode
- ClassifierPrompt
- RoutingCondition
- HumanHandoffPrompt
- HumanHandoffOutput

---

# G. AgentCore Backend Validation

## E10 — Lambda Test Success

**File:**

`evidence/E10_lambda-test-success.png`

Shows successful direct execution of:

`bug-report-tool-stack-create-bug-report`

including:

- generated ticket ID
- `OPEN` status

---

## E11 — DynamoDB Isolated Ticket

**File:**

`evidence/E11_dynamodb-isolated-ticket.png`

Shows the ticket created by the isolated Lambda test persisted in:

`bug-report-tool-stack-bug-reports`

The ID matches the Lambda response.

---

# H. AgentCore System Prompt Evidence

## E20a

`evidence/E20a_system-prompt-route-1-bug-report.png`

Shows the operational Bug Report routing definition in `system_prompt.txt`.

## E20b

`evidence/E20b_system-prompt-routes-2-3.png`

Shows the operational:

- Platform Question
- Human Handoff

routing definitions.

## E21a

`evidence/E21a_bug-report-collection.png`

Shows required bug-report information collection.

## E21b

`evidence/E21b_tool-call-gate.png`

Shows the rule preventing tool execution until the required bug-report information is available.

## E22

`evidence/E22_bug-report-ticket-id-rule.png`

Shows:

- ticket creation rules
- successful-tool requirement
- no fabricated ticket IDs
- exact `ticketId` relay

## E23

`evidence/E23_platform-question-and-handoff-behavior.png`

Shows platform-question and human-handoff behavior.

## E24

`evidence/E24_faq-placeholder.png`

Shows:

`{{FAQ}}`

and the FAQ grounding section of `system_prompt.txt`.

---

# I. AgentCore Live FAQ and Handoff Test

## E25

`evidence/E25_faq-and-handoff-live-tests.png`

Shows live `chat.py` behavior for:

- Covered FAQ question
- Unsupported FAQ question
- Explicit human-handoff request

---

# J. AgentCore End-to-End Bug Report

## E30 — Successful Chat Transcript

**File:**

`evidence/E30_bug-report-transcript.png`

Shows the multi-turn conversation collecting:

- description
- steps to reproduce
- environment

and the successful:

`[tool call] bugreports___create_bug_report`

The returned chatbot ticket ID is:

`01de0487-2147-4ff8-a964-ca7134df4b3b`

Text transcript:

`bug-report-transcript.txt`

---

## E32 — DynamoDB Table

**File:**

`evidence/E32_dynamodb-chatbot-ticket-table.png`

Shows the chatbot-created ticket in the DynamoDB table.

---

## E33 — DynamoDB Ticket Details

**File:**

`evidence/E33_dynamodb-chatbot-ticket-details.png`

Shows the full chatbot-created record, including:

- matching ticket ID
- description
- steps to reproduce
- environment
- `OPEN` status

Reviewer-friendly ticket scan:

`dynamodb-tickets.txt`

---

# K. AgentCore Architecture

## E40

**File:**

`evidence/E40_architecture-diagram.png`

Shows:

Customer

→ `chat.py`

→ Amazon Bedrock AgentCore Harness

→ Amazon Nova Pro

→ request behavior

with:

### Bug route

AgentCore Gateway

→ AWS Lambda

→ Amazon DynamoDB

### Platform route

Embedded FAQ

### Human handoff

Documented support path

Editable architecture documentation:

`ARCHITECTURE.md`

---

# L. Automated Testing and Evaluation

## E50 / E51 — Evaluation Summary

**File:**

`evidence/E50_E51_eval-summary-distribution.png`

Shows the completed Bedrock Evaluation job with:

- Overall Correctness: **1.00**
- Total prompts: **6**
- Score distribution

---

## E52 — Per-Prompt Results

**File:**

`evidence/E52_eval-per-prompt-results.png`

Shows all six evaluation prompts individually.

Result:

**6 of 6 prompts scored 1.00**

---

# M. Test and Evaluation Artifacts

## `flow-tests.json`

Documents four manually validated Bedrock Flow scenarios:

- Bug report
- Covered FAQ
- Uncovered FAQ
- Other / Human Handoff

## `harness-tests.json`

Contains six automated AgentCore Harness test cases covering all three operational routes.

## `output_eval_dataset.jsonl`

Contains six Harness-generated evaluation records.

Validation:

- 6 records
- no `[HARNESS_ERROR]` entries

This is the dataset used for the completed Amazon Bedrock Evaluation job.

---

# N. Supporting Documentation

## `README.md`

Provides the reviewer-facing overview of the dual Bedrock Flow + AgentCore implementation.

## `RUBRIC_MAP.md`

Maps each assessment criterion to the actual implementation and evidence.

## `OBSERVATIONS.md`

Documents:

- automated evaluation scope
- correctness results
- manual validation
- FAQ behavior
- human handoff
- tool-safety controls
- memory isolation
- known streamed-thinking observation

## `ARCHITECTURE.md`

Documents the AgentCore operational architecture.

## `bug-report-transcript.txt`

Text record of the successful AgentCore multi-turn bug-report scenario.

## `dynamodb-tickets.txt`

Contains persisted ticket IDs and status values, including the matching chatbot-created ticket.

---

# Final Evidence Summary

## Bedrock Flow

- Classifier Prompt: complete
- Deterministic categories: complete
- Condition node: complete
- Three distinct routes: complete
- Three separate outputs: complete
- Bug Prompt: complete
- Embedded FAQ Prompt: complete
- Human Handoff Prompt: complete
- Bug Flow test: passed
- Covered FAQ Flow test: passed
- Uncovered FAQ Flow test: passed
- Other-request Flow test: passed

## AgentCore

- Operational system prompt: complete
- Multi-turn bug collection: complete
- AgentCore Gateway invocation: complete
- Lambda execution: complete
- DynamoDB persistence: complete
- Exact ticket-ID verification: complete
- FAQ grounding: complete
- Human handoff: complete
- Automated test suite: complete
- Bedrock Evaluation: complete
- Overall Correctness: **1.00**
- Individual prompt results: **6/6 at 1.00**