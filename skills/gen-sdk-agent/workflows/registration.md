# Agent Registration Checklist

## 1. Import in index.ts

Add import in alphabetical order among existing imports:

```typescript
import { <exportName>Agent } from './<agent-name>.js'
```

## 2. Add to agents record

Add entry in alphabetical order:

```typescript
export const agents: Record<string, AgentConfig> = {
  // ... existing agents ...
  '<agent-name>': <exportName>Agent,
}
```

## 3. Add to re-exports

Add to the re-export block at bottom of index.ts:

```typescript
export {
  // ... existing exports ...
  <exportName>Agent,
}
```

## 4. Tier Constants (pipeline agents only)

In `src/shared/tier-constants.ts`:

### tierAgentFlows
Add agent name to relevant tier arrays in correct execution order:
```typescript
export const tierAgentFlows: Record<Tier, string[]> = {
  trivial: ['planner', 'builder'],           // add here if trivial-capable
  small: ['planner', 'builder', 'tester'],   // add in correct order
  medium: ['planner', 'builder', 'tester'],
  large: ['planner', 'builder', 'tester'],
}
```

### tierAllAgents
Mirror changes from tierAgentFlows.

### agentDisplayNames
```typescript
'<agent-name>': '<Display Name>',
```

### hookTimings
```typescript
'<agent-name>': 'post-<agent-name>',
```

### agentSkillPatterns
```typescript
'<agent-name>': ['*-guidelines'],  // adjust patterns
```
