# React TypeScript Workflow Plugin

A comprehensive Claude Code plugin for React and TypeScript development. This plugin provides slash commands that automate common React development tasks while following modern React patterns and TypeScript best practices.

## Installation

1. Copy the `.claude` directory to your React project root:

```bash
cp -r plugins/react-typescript-workflow/.claude /path/to/your/react/project/
```

2. Verify installation by running `/help` in Claude Code

## Available Commands

### Component Development

#### `/react-create-component`

Generate a new React functional component with TypeScript.

**Example usage:**

```
User: /react-create-component Button with onClick and variant props
```

**Features:**

- Functional components with TypeScript
- Prop interfaces
- JSDoc documentation
- Unit tests
- Storybook stories (if configured)

### Custom Hooks

#### `/react-create-hook`

Create a custom React hook with proper TypeScript types.

**Example usage:**

```
User: /react-create-hook useLocalStorage for storing user preferences
```

**Features:**

- TypeScript generics
- Proper dependency arrays
- Cleanup logic
- Comprehensive tests
- JSDoc documentation

### State Management

#### `/react-setup-context`

Create a React Context with TypeScript for application state.

**Example usage:**

```
User: /react-setup-context for authentication state
```

**Features:**

- Type-safe context creation
- Custom consumption hooks
- Provider component
- Error boundaries
- Usage examples

### Testing

#### `/react-setup-testing`

Configure React Testing Library with TypeScript and utilities.

**Example usage:**

```
User: /react-setup-testing
```

**Features:**

- Testing Library setup
- Custom render utilities
- MSW configuration
- Coverage setup
- Example tests

### Form Handling

#### `/react-add-form-handling`

Implement forms with React Hook Form and Zod validation.

**Example usage:**

```
User: /react-add-form-handling for user registration
```

**Features:**

- React Hook Form integration
- Zod schema validation
- TypeScript type inference
- Accessibility support
- Error handling

### Data Fetching

#### `/react-add-data-fetching`

Set up data fetching with React Query (TanStack Query).

**Example usage:**

```
User: /react-add-data-fetching for user management
```

**Features:**

- React Query setup
- Typed API client
- Query and mutation hooks
- Caching configuration
- DevTools integration

## Best Practices

This plugin enforces modern React and TypeScript best practices:

- Functional components with hooks
- Strict TypeScript types (no `any`)
- Component composition
- Custom hooks for reusable logic
- Context API for state management
- React Testing Library for testing
- React Hook Form for forms
- React Query for data fetching
- Accessibility (ARIA attributes)
- Performance optimization (memoization)

## Project Structure

The plugin assumes a standard React project structure:

```
src/
├── components/      # Reusable UI components
├── hooks/           # Custom React hooks
├── contexts/        # React Context providers
├── api/             # API client functions
├── pages/           # Page components
├── test-utils/      # Testing utilities
└── ...
```

## Technology Stack

This plugin works best with:

- **React 18+** - Modern React with concurrent features
- **TypeScript 5+** - Latest TypeScript features
- **Vite or Create React App** - Build tooling
- **React Testing Library** - Component testing
- **React Hook Form** - Form management
- **Zod** - Schema validation
- **React Query** - Data fetching and caching
- **Vitest or Jest** - Test runner

## Patterns and Conventions

### Component Patterns

- Functional components only
- Props interfaces exported
- Default props via destructuring
- Composition over props drilling

### Hook Patterns

- Prefix all hooks with "use"
- Return stable references
- Include cleanup logic
- Document with JSDoc

### TypeScript Patterns

- No implicit `any`
- Use `interface` for props
- Use `type` for unions/intersections
- Infer types from schemas when possible

### Testing Patterns

- Test behavior, not implementation
- Use user-event for interactions
- Query by accessibility roles
- Mock external dependencies with MSW

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Follow React and TypeScript best practices
2. Include tests for new commands
3. Update documentation
4. Test with React 18+

## License

MIT License - see LICENSE file

## Version

0.1.0 - Initial release

## Requirements

- React 18+
- TypeScript 5+
- Node.js 18+
- Claude Code CLI

## Support

For issues and questions:

- GitHub Issues: [Create an issue]
- Documentation: See `/docs/best-practices/`

## Examples

See the `examples/` directory for complete example projects demonstrating each command.
