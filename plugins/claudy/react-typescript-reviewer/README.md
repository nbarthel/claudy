# React TypeScript Code Review Agent Plugin

A specialized Claude Code agent for automated React and TypeScript code review. This agent provides comprehensive review focusing on modern React patterns, TypeScript best practices, performance, and accessibility.

## Installation

1. Copy the `.claude` directory to your React project root:

```bash
cp -r plugins/react-typescript-code-review-agent/.claude /path/to/your/react/project/
```

2. The agent will automatically be available for use in Claude Code

## Usage

The React TypeScript reviewer agent can be invoked in several ways:

### Manual Invocation

Simply ask Claude to review your React/TypeScript code:

```
"Can you review my UserProfile component?"
"Please review my custom useApi hook"
"Review these changes for TypeScript issues"
"Check my component for performance problems"
```

### What the Agent Reviews

### React Patterns

- Functional components over class components
- Proper hook usage and dependencies
- Component composition
- Context vs. prop drilling
- Re-render optimization
- Memoization patterns

### TypeScript Quality

- No `any` types (or justified usage)
- Proper interface/type definitions
- Generic usage
- Type inference vs. explicit types
- Union and intersection types
- Type safety in event handlers

### Component Structure

- Single responsibility principle
- Component size and complexity
- Prop interface definitions
- Default props handling
- Component naming
- File organization

### Hooks

- Rules of Hooks compliance
- Dependency array completeness
- Custom hook design
- Cleanup functions
- Infinite loop prevention
- State management patterns

### Performance

- Unnecessary re-renders
- Memoization opportunities
- Expensive computations
- List key usage
- Bundle size
- Memory leaks

### Accessibility

- Semantic HTML
- ARIA attributes
- Keyboard navigation
- Focus management
- Screen reader support
- Color contrast

### Testing

- Test coverage
- RTL best practices
- Test quality
- Edge case coverage
- Proper mocking
- Test organization

## Anti-Patterns Detected

The agent identifies and flags common React/TypeScript anti-patterns:

- Class components (when functional would work)
- Missing hook dependencies
- Inline function definitions causing re-renders
- Improper key usage in lists
- Excessive props drilling
- Unnecessary `any` types
- Missing TypeScript strict mode
- Non-semantic HTML
- Missing accessibility attributes
- Untested components
- Direct DOM manipulation
- Memory leaks (missing cleanup)
- Unnecessary re-renders

## Review Output Format

The agent provides structured feedback:

```markdown
## Review Summary
High-level assessment of your changes

## Critical Issues
- Specific issues with file:line references

## Type Safety Issues
- TypeScript problems

## Performance Concerns
- Performance issues

## Accessibility Issues
- A11y problems

## Suggestions
- Actionable improvements

## Positive Observations
- Good practices you're following
```

## Example Reviews

### Example 1: Hook Dependency Issue

**Code:**

```typescript
useEffect(() => {
  fetchData(userId);
}, []); // Missing userId dependency!
```

**Agent Feedback:**

```markdown
## Critical Issues
- Missing dependency in useEffect at `src/components/User.tsx:15`
  The effect uses `userId` but it's not in the dependency array

## Suggestions
- Add `userId` to the dependency array: `[userId]`
- Or use `useCallback` if `fetchData` changes frequently
```

### Example 2: TypeScript Any Usage

**Code:**

```typescript
interface Props {
  data: any; // Bad!
  onClick: any; // Bad!
}
```

**Agent Feedback:**

```markdown
## Type Safety Issues
- Using `any` type for `data` prop at `src/components/Card.tsx:3`
- Using `any` type for `onClick` prop at `src/components/Card.tsx:4`

## Suggestions
- Define proper interface for `data` prop
- Use proper event handler type: `onClick: () => void`
```

### Example 3: Performance Issue

**Code:**

```typescript
function UserList({ users }) {
  return users.map(user => (
    <div key={Math.random()}> {/* Bad key! */}
      <UserCard user={user} onClick={() => handleClick(user.id)} />
    </div>
  ));
}
```

**Agent Feedback:**

```markdown
## Critical Issues
- Using `Math.random()` as key at `src/components/UserList.tsx:3`
- Inline function definition causing re-renders at `src/components/UserList.tsx:4`

## Performance Concerns
- Every render creates new keys, causing full list re-render
- New function created for each user on every render

## Suggestions
- Use `user.id` as the key
- Use `useCallback` for the onClick handler or move it outside
```

## Best Practices Enforced

1. **Modern React**: Functional components with hooks
2. **Type Safety**: Strict TypeScript, no `any`
3. **Performance**: Proper memoization and optimization
4. **Accessibility**: WCAG compliance
5. **Testing**: Comprehensive test coverage
6. **Composition**: Component composition over inheritance
7. **Clean Code**: Clear, maintainable code

## Integration

### With Git Hooks

Add to `.claude/hooks/pre-commit`:

```bash
#!/bin/bash
echo "Running React/TypeScript code review..."
# Your hook logic here
```

### With CI/CD

Include in your CI pipeline for automated reviews on PRs.

## Requirements

- React 18+
- TypeScript 5+
- Node.js 18+
- Claude Code CLI

## Configuration

### Custom Focus

Ask the agent to focus on specific aspects:

```
"Review this component focusing on accessibility"
"Check for TypeScript type issues"
"Review for performance problems"
```

## Contributing

To improve the agent:

1. Add new review patterns
2. Include examples of common issues
3. Update TypeScript checks
4. Enhance accessibility validation

## License

MIT License - see LICENSE file

## Version

0.1.0 - Initial release

## Support

For issues and questions:

- GitHub Issues: [Create an issue]
- Documentation: See `/docs/best-practices/`
