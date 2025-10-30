# react-setup-testing

Configure React Testing Library with TypeScript and best practices

---

Set up comprehensive testing infrastructure for React with TypeScript:

1. **Install testing dependencies**:
   - @testing-library/react
   - @testing-library/jest-dom
   - @testing-library/user-event
   - @types/jest (if using TypeScript)
   - vitest or jest
2. **Configure test setup** file with custom matchers
3. **Create test utilities** file for common testing helpers
4. **Set up MSW** (Mock Service Worker) for API mocking if needed
5. **Configure coverage** thresholds
6. **Add test scripts** to package.json
7. **Create example test** to verify setup
8. **Update tsconfig** for test files

Test setup file:

```typescript
// src/test-utils/setup.ts
import '@testing-library/jest-dom';
import { cleanup } from '@testing-library/react';
import { afterEach } from 'vitest';

// Cleanup after each test
afterEach(() => {
  cleanup();
});
```

Test utilities:

```typescript
// src/test-utils/index.tsx
import React, { ReactElement } from 'react';
import { render, RenderOptions } from '@testing-library/react';
import { ThemeProvider } from '../contexts/ThemeContext';

interface AllTheProvidersProps {
  children: React.ReactNode;
}

// Wrapper with all providers
const AllTheProviders: React.FC<AllTheProvidersProps> = ({ children }) => {
  return (
    <ThemeProvider>
      {children}
    </ThemeProvider>
  );
};

// Custom render function
const customRender = (
  ui: ReactElement,
  options?: Omit<RenderOptions, 'wrapper'>
) => render(ui, { wrapper: AllTheProviders, ...options });

export * from '@testing-library/react';
export { customRender as render };
```

Example test:

```typescript
// src/components/Button/Button.test.tsx
import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '../../test-utils';
import userEvent from '@testing-library/user-event';
import { Button } from './Button';

describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument();
  });

  it('calls onClick when clicked', async () => {
    const handleClick = vi.fn();
    const user = userEvent.setup();

    render(<Button onClick={handleClick}>Click me</Button>);

    await user.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('disables button when disabled prop is true', () => {
    render(<Button disabled>Click me</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
  });
});
```

Package.json scripts:

```json
{
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest --coverage"
  }
}
```

Testing best practices:

- Test behavior, not implementation
- Use user-event for simulating interactions
- Query by accessibility roles
- Avoid testing implementation details
- Mock external dependencies
- Use MSW for API mocking
- Aim for high coverage but focus on critical paths
- Write descriptive test names
