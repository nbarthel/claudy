# react-create-component

Generate a new React component with TypeScript

---

Create a new React component following modern React and TypeScript best practices:

1. **Determine component type** (functional component, custom hook, or context provider)
2. **Create component file** in appropriate directory (components/, features/, or pages/)
3. **Implement component** with:
   - TypeScript interface for props
   - Proper prop destructuring
   - JSDoc comments for documentation
   - Error boundaries if needed
4. **Create barrel export** (index.ts) if appropriate
5. **Add unit tests** using React Testing Library
6. **Create Storybook story** if Storybook is configured
7. **Update parent component** to use new component if needed

Component structure to follow:

```typescript
import React from 'react';

interface ComponentNameProps {
  title: string;
  onClick?: () => void;
  children?: React.ReactNode;
  className?: string;
}

/**
 * ComponentName - Brief description of what this component does
 *
 * @param props - Component props
 * @returns JSX.Element
 */
export const ComponentName: React.FC<ComponentNameProps> = ({
  title,
  onClick,
  children,
  className = '',
}) => {
  return (
    <div className={className}>
      <h2>{title}</h2>
      {children}
      {onClick && <button onClick={onClick}>Click me</button>}
    </div>
  );
};
```

Best practices to follow:

- Use functional components with hooks
- Export interfaces for reusability
- Use const assertions for prop types
- Implement proper TypeScript types (no `any`)
- Use composition over inheritance
- Keep components focused and single-responsibility
- Extract complex logic to custom hooks
- Use CSS modules or styled-components for styling
