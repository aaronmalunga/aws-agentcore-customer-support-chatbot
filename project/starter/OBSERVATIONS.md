# Evaluation Observations

## Project

Customer Support Chatbot with Amazon Bedrock AgentCore

## Evaluation Objective

The purpose of this evaluation was to verify that the customer support chatbot correctly routes customer requests, remains grounded in the supplied FAQ content, requests the information required for bug reports, invokes the bug-report tool only when appropriate, and routes unsupported requests to human support.

The implementation uses Amazon Bedrock AgentCore with routing behavior defined in `system_prompt.txt`. The bug-report path integrates with the AgentCore Gateway, which invokes an AWS Lambda function that persists bug reports to Amazon DynamoDB.

---

## Automated Evaluation

### Test Dataset

The automated evaluation dataset contains six test prompts covering the main chatbot behaviors:

- Partial bug-report request
- Product return-window FAQ
- Guest-checkout FAQ
- Missing order-confirmation FAQ
- Unsupported student-discount question
- Explicit request for human support

The test cases were defined in:

`harness-tests.json`

The evaluation dataset was generated using:

`generate-eval-dataset.py`

This produced:

`output_eval_dataset.jsonl`

All six harness calls completed successfully and no `[HARNESS_ERROR]` entries were present in the generated dataset.

---

## Bedrock Evaluation Run 1

The generated evaluation dataset was uploaded to Amazon S3 and evaluated using Amazon Bedrock Evaluations.

Evaluation job:

`support-chatbot-eval-run-1`

Metric:

`Builtin.Correctness`

Evaluator model:

`amazon.nova-pro-v1:0`

### Results

The evaluation completed successfully with:

- Overall Correctness score: **1.00**
- Total prompts evaluated: **6**
- Individual prompts scoring 1.00: **6 of 6**

The score distribution showed that all six evaluated prompts received a correctness score of 1.00.

### Interpretation

The result demonstrates that the chatbot satisfied the expected behavior for all six defined baseline evaluation scenarios.

The score should not be interpreted as evidence that the chatbot will perform perfectly for every possible user request. It demonstrates correctness against the specific routing, FAQ, bug-report, and human-handoff cases represented in the evaluation dataset.

---

## Behavior Observations

### Bug-Report Routing

When a customer indicates that they are experiencing a technical problem, the chatbot recognizes the request as a bug-report scenario.

For incomplete bug reports, the chatbot requests the missing information instead of claiming that a ticket has already been created.

The required information is:

- `description`
- `stepsToReproduce`
- `environment`

The system prompt instructs the chatbot to collect missing information before invoking the bug-report tool.

---

## Manual End-to-End Bug-Report Validation

A multi-turn bug-report conversation was tested manually using `chat.py`.

The interaction followed this sequence:

1. The customer reported a technical problem.
2. The chatbot requested a description of the issue.
3. The customer supplied the description.
4. The chatbot requested the steps required to reproduce the issue.
5. The customer supplied the reproduction steps.
6. The chatbot requested environment information.
7. The customer supplied the environment.
8. The chatbot invoked the AgentCore Gateway tool:

`bugreports___create_bug_report`

9. The backend successfully created the bug report.
10. The chatbot returned the ticket ID supplied by the tool.

The successful chatbot-generated ticket ID was:

`01de0487-2147-4ff8-a964-ca7134df4b3b`

The same ticket ID was independently verified in the DynamoDB table:

`bug-report-tool-stack-bug-reports`

The stored record contained the expected bug description, reproduction steps, environment information, and an `OPEN` status.

This validates the complete operational path:

Customer conversation → AgentCore Harness → AgentCore Gateway → Lambda → DynamoDB

---

## Lambda and DynamoDB Validation

The Lambda function was also tested independently before relying on the chatbot workflow.

The Lambda function:

`bug-report-tool-stack-create-bug-report`

successfully accepted a direct test event containing:

- `description`
- `stepsToReproduce`
- `environment`

The function returned a ticket ID and an `OPEN` status.

The corresponding ticket was then verified in DynamoDB.

This isolated test confirmed that the backend bug-report tool functioned correctly independently of the conversational agent.

---

## FAQ Grounding

The chatbot was tested against multiple questions covered by `online_shop_faq.md`.

Examples included:

- Return-window policy
- Guest checkout
- Missing order-confirmation email

The automated evaluation scored all FAQ test cases at 1.00.

The chatbot correctly identified the documented 30-day return period and correctly stated that customers may place orders using guest checkout.

The missing-confirmation scenario also produced the expected guidance based on the supplied FAQ.

The FAQ document was extended with a customer-support phone number:

`1-800-555-0147`

This allows unsupported questions and explicit handoff requests to provide a concrete support path grounded in the project FAQ rather than using an invented contact number.

---

## Unsupported Requests and Human Handoff

The chatbot was tested with the question:

`Do you offer a student discount?`

The supplied FAQ does not define a student-discount policy.

The chatbot did not invent a discount and instead directed the customer to the documented human-support channel.

The chatbot was also tested with an explicit request to speak to a real person.

Both cases received a correctness score of 1.00 during the automated evaluation.

---

## Prompt and Tool-Safety Controls

The system prompt includes explicit controls for bug-report creation.

The chatbot is instructed not to invoke `create_bug_report` until all three required bug-report fields are available.

It is also instructed that a bug report does not exist until the tool has successfully returned a result.

The only valid source of a ticket ID is the successful `create_bug_report` tool response.

After a successful tool result, the chatbot must relay the exact returned `ticketId` without modifying it.

These controls were added to reduce the risk of premature tool calls or fabricated ticket identifiers.

---

## Known Observation: Streamed Thinking Content

During some manual AgentCore/Nova Pro terminal tests, `<thinking>...</thinking>` content was visible in the streamed development output.

Customer-facing output rules were added to `system_prompt.txt` instructing the model not to expose internal reasoning, route labels, classification rationale, or `<thinking>` tags.

The final successful bug-report workflow still contained a short streamed thinking block before the successful tool invocation.

This did not prevent the required workflow from completing:

- All required bug-report fields had been collected.
- The actual Gateway tool was invoked.
- The backend returned a real ticket ID.
- The same ticket was verified in DynamoDB.

This behavior is therefore recorded as a known observation rather than omitted from the evaluation evidence.

---

## Memory Configuration

Persistent AgentCore memory was disabled for this evaluation harness.

This was done to prevent information from previous conversations from affecting later evaluation cases and to keep each automated test isolated.

This is particularly important because each evaluation prompt is intended to represent an independent customer interaction.

---

## Conclusion

The baseline implementation successfully demonstrated the required customer-support behaviors.

Bedrock Evaluation Run 1 achieved an overall correctness score of **1.00 across all six defined evaluation prompts**, with every individual prompt receiving a score of **1.00**.

Manual testing additionally demonstrated the complete bug-report integration from conversational information collection through AgentCore Gateway, Lambda execution, ticket creation, and DynamoDB persistence.

The evaluation provides evidence that the implementation satisfies the defined baseline scenarios for:

- Bug-report routing and information collection
- Tool-backed ticket creation
- FAQ-grounded responses
- Unsupported-question handling
- Human-support handoff
- Backend persistence and ticket verification

Further adversarial and edge-case testing would be appropriate for a production deployment, but the current evaluation establishes a successful baseline for the project requirements.