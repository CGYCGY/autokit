/**
 * qqq_DISPLAY_NAME Agent
 *
 * qqq_DESCRIPTION
 *
 * Uses qqq_MODEL_TIER model for qqq_MODEL_REASON.
 */

import type { AgentConfig, TaskContext } from '../core/types.js'

export const qqq_EXPORT_NAME: AgentConfig = {
  name: 'qqq_AGENT_NAME',
  description: 'qqq_DESCRIPTION',
  modelTier: 'qqq_MODEL_TIER', // haiku | sonnet | opus
  skillPatterns: [qqq_SKILL_PATTERNS], // e.g. ['*-guidelines', '*testing']

  systemPrompt: `<purpose>
qqq_PURPOSE — one sentence role definition.
</purpose>

<variables>
  <required>
    <var name="FEATURE_NAME">{featureName}</var>
    <var name="TASK_DIR">{taskDir}</var>
    <var name="TIER">{tier}</var>
  </required>
  <optional>
    <var name="ESCALATION_GUIDANCE">{escalationGuidance}</var>
    <var name="DRIFT_CONTEXT">{driftContext}</var>
  </optional>
  <inputs>
    <item>qqq_INPUT — input file or context</item>
  </inputs>
</variables>

{skills}

<instructions>
  <step>qqq_INSTRUCTION_1</step>
  <step>qqq_INSTRUCTION_2</step>
  <step>qqq_INSTRUCTION_3</step>
</instructions>

<workflow>
  1. qqq_WORKFLOW_STEP_1
  2. qqq_WORKFLOW_STEP_2
  3. qqq_WORKFLOW_STEP_3
</workflow>

<output_format>
Write to: TASK_DIR/qqq_OUTPUT_FILE.md

# qqq_OUTPUT_TITLE: FEATURE_NAME

## Summary
qqq_SUMMARY_TEMPLATE

## Status
qqq_STATUS_TEMPLATE
</output_format>`,

  tools: [qqq_TOOLS],
  temperature: 0.3, // sonnet/haiku only — remove this line for the opus tier (Opus 4.7+ rejects temperature/top_p/top_k with a 400)

  buildInitialPrompt: (context: TaskContext) => {
    let prompt = `qqq_INITIAL_PROMPT for feature: ${context.featureName}. Task dir: ${context.taskDir}.`

    if (context.escalationGuidance) {
      prompt += `\n\nEscalation guidance: ${context.escalationGuidance}`
    }
    if (context.driftContext) {
      prompt += `\n\n${context.driftContext}`
    }

    return prompt
  },
}
