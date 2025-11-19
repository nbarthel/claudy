---
name: rails-pattern-recognition
description: Adaptive learning system that tracks implementation patterns, success rates, and performance metrics to suggest proven solutions for future tasks.
version: 1.0
---

# Rails Pattern Recognition

Adaptive learning system for Rails workflows.

## Usage

```python
# Suggest patterns
patterns = invoke_skill("rails-pattern-recognition", mode="suggest", context_tags=["rails", "auth"])

# Update metrics
invoke_skill("rails-pattern-recognition", mode="update", metrics={
  "pattern_used": "Devise Auth",
  "success": true,
  "duration_minutes": 15
})
```

## Implementation

This skill manages a JSON database of implementation patterns and their performance metrics.

### Data Structure (`.claude/data/rails-patterns.json`)

```json
{
  "patterns": {
    "Devise Auth": {
      "tags": ["rails", "auth", "devise"],
      "uses": 10,
      "successes": 9,
      "avg_duration": 12.5,
      "last_used": "2023-10-27T10:00:00Z"
    }
  }
}
```

### Modes

#### 1. Suggest (`mode="suggest"`)
- **Input**: `context_tags` (list of strings)
- **Logic**:
  - Filter patterns matching at least one tag
  - Calculate confidence score: `(successes / uses) * log(uses + 1)`
  - Sort by confidence
- **Output**: List of patterns with confidence scores

#### 2. Update (`mode="update"`)
- **Input**: `metrics` (dict)
  - `pattern_used` (string)
  - `success` (boolean)
  - `duration_minutes` (float)
- **Logic**:
  - Update `uses`, `successes`
  - Recalculate `avg_duration`
  - Update `last_used`
- **Output**: Confirmation

## Standalone Operation

This skill operates entirely within the project's `.claude/` directory, ensuring portability and independence from global system state.
