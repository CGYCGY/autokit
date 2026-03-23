# System Prompt Reference

## XML Structure

```xml
<purpose>
One-sentence role definition.
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
    <item>description of input file or context</item>
  </inputs>
</variables>

{skills}

<instructions>
  <step>Actionable instruction</step>
</instructions>

<workflow>
  1. Step
  2. Step
</workflow>

<output_format>
Write to: TASK_DIR/output-file.md
# Output template
</output_format>
```

## Template Variable Replacement

Replaced at runtime by `buildAgentPrompt()` in `src/utils/prompts.ts`:
- **Required**: `{featureName}`, `{taskDir}`, `{tier}`, `{taskContent}`, `{stepMode}`
- **Optional** (replaced only if context has value): `{escalationGuidance}`, `{driftContext}`, `{planResult}`, `{buildResult}`, `{testResult}`
- **Skills**: `{skills}` replaced with loaded skill content

## Skill Integration

- `skillPatterns` are glob patterns matched against skill directory names
- Common patterns: `'*-guidelines'`, `'*testing'`, `'*codanna*'`
- 3-tier loading: project `.claude/skills/` > worker `skills/` > global `~/.claude/skills/`
- Always place `{skills}` between `</variables>` and `<instructions>`
- Framing preamble forces agent to prefer loaded skills over defaults

## Common Prompt Patterns

### Multi-Phase Instructions
When agent has distinct modes (e.g., builder has build_mode and fix_mode):
```xml
<instructions>
  <mode_name_1>
    <step>Action for this mode</step>
  </mode_name_1>
  <mode_name_2>
    <step>Action for this mode</step>
  </mode_name_2>
</instructions>
```

### Uncertainty Handling (Planner Pattern)
```xml
<uncertainty_handling>
  If confidence is below 80% on any decision:
  1. Add a PENDING section
  2. List uncertainties with recommended options
  3. Workflow pauses for user clarification
</uncertainty_handling>
```

### Drift Awareness (Builder Pattern)
```xml
<drift_awareness>
  When drift context is provided, treat deviations as ground truth.
  Use ACTUAL implementation, not the planned version.
</drift_awareness>
```

### Tier-Conditional Behavior
```xml
<trivial_tier>
  No plan exists - work directly from task.md.
  Keep changes minimal and focused.
</trivial_tier>
```

## buildInitialPrompt Patterns

### Simple (planner/tester style)
```typescript
buildInitialPrompt: (context: TaskContext) =>
  `Analyze and plan for ${context.taskDir}/task.md. Feature: ${context.featureName}.`,
```

### Conditional (builder style — mode switching)
```typescript
buildInitialPrompt: (context: TaskContext) => {
  let prompt: string
  if (context.escalationGuidance) {
    prompt = `Fix failures for: ${context.featureName}. Guidance: ${context.escalationGuidance}`
  } else if (context.tier === 'trivial') {
    prompt = `Build from ${context.taskDir}/task.md. Feature: ${context.featureName}.`
  } else {
    prompt = `Build per ${context.taskDir}/plan.md. Feature: ${context.featureName}.`
  }
  if (context.driftContext) prompt += `\n\n${context.driftContext}`
  return prompt
},
```

### With Previous Agent Results
```typescript
buildInitialPrompt: (context: TaskContext) => {
  let prompt = `Review feature: ${context.featureName}.`
  if (context.planResult) prompt += `\n\nPlan:\n${context.planResult}`
  if (context.buildResult) prompt += `\n\nBuild log:\n${context.buildResult}`
  if (context.testResult) prompt += `\n\nTest results:\n${context.testResult}`
  return prompt
},
```
