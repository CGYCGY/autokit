# Agent Config Reference

## AgentConfig Interface

```typescript
export interface AgentConfig {
  name: string;              // kebab-case identifier
  description: string;       // one-line role description
  modelTier: ModelTier;      // 'opus' | 'sonnet' | 'haiku'
  systemPrompt: string;      // XML-structured prompt
  tools: string[];           // available tools
  skillPatterns?: string[];  // glob patterns for skill loading
  temperature?: number;      // 0.3 is standard
  buildInitialPrompt?: (context: TaskContext) => string;
}
```

## ModelTier

```typescript
export const MODEL_TIERS = {
  opus:   'claude-opus-4-6',
  sonnet: 'claude-sonnet-4-6',
  haiku:  'claude-haiku-4-5',
} as const

export type ModelTier = keyof typeof MODEL_TIERS
```

Selection guide:
- **opus**: Complex reasoning, planning, architectural decisions, diagnostics
- **sonnet**: Balanced code implementation, refactoring, multi-file changes (default)
- **haiku**: Fast/cheap — test running, reporting, single-purpose

## Tool Selection

Available: `Read`, `Write`, `Edit`, `Glob`, `Grep`, `Bash`, `RequestUserInput`

By role:
- **Read-only** (analyzers, reporters): `['Read', 'Glob', 'Grep', 'Bash', 'RequestUserInput']`
- **Write** (builders, generators): `['Read', 'Write', 'Edit', 'Glob', 'Grep', 'Bash', 'RequestUserInput']`
- **Minimal** (runners, testers): `['Read', 'Write', 'Bash', 'Glob', 'RequestUserInput']`

## TaskContext

Available in `buildInitialPrompt(context: TaskContext)`:

| Field | Type | Description |
|-------|------|-------------|
| `featureName` | `string` | Feature/task name |
| `taskDir` | `string` | `.tasks/<slug>/` directory |
| `taskContent` | `string` | Raw task.md content |
| `tier` | `Tier \| null` | trivial/small/medium/large |
| `projectPath` | `string?` | Absolute project path |
| `stepMode` | `boolean?` | Step-by-step mode flag |
| `projectConfig` | `ProjectConfig?` | Project configuration |
| `planResult` | `string?` | Output from planner |
| `buildResult` | `string?` | Output from builder |
| `testResult` | `string?` | Output from tester |
| `escalationGuidance` | `string?` | Opus diagnostic guidance |
| `driftContext` | `string?` | Deviations from plan |
| `gitBranch` | `GitBranchInfo?` | Branch isolation info |
