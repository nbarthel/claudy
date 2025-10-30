# react-setup-context

Create a React Context with TypeScript for state management

---

Set up a React Context with proper TypeScript types and best practices:

1. **Create context file** in `contexts/` or `src/contexts/` directory
2. **Define context value interface** with proper types
3. **Create context and provider** component
4. **Implement custom hook** for consuming context
5. **Add type safety** to prevent undefined context usage
6. **Write tests** for context provider
7. **Update app** to wrap with provider
8. **Document usage** with examples

Context structure:

```typescript
import React, { createContext, useContext, useState, ReactNode } from 'react';

// Define the shape of context value
interface ThemeContextValue {
  theme: 'light' | 'dark';
  toggleTheme: () => void;
}

// Create context with undefined default (will be provided by provider)
const ThemeContext = createContext<ThemeContextValue | undefined>(undefined);

// Provider props
interface ThemeProviderProps {
  children: ReactNode;
  initialTheme?: 'light' | 'dark';
}

/**
 * ThemeProvider - Provides theme state to the application
 */
export const ThemeProvider: React.FC<ThemeProviderProps> = ({
  children,
  initialTheme = 'light',
}) => {
  const [theme, setTheme] = useState<'light' | 'dark'>(initialTheme);

  const toggleTheme = () => {
    setTheme((prev) => (prev === 'light' ? 'dark' : 'light'));
  };

  const value: ThemeContextValue = {
    theme,
    toggleTheme,
  };

  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  );
};

/**
 * useTheme - Hook to consume theme context
 * Throws error if used outside ThemeProvider
 */
export const useTheme = (): ThemeContextValue => {
  const context = useContext(ThemeContext);

  if (context === undefined) {
    throw new Error('useTheme must be used within ThemeProvider');
  }

  return context;
};
```

Best practices:

- Create custom hook for context consumption
- Throw error if context is undefined
- Use meaningful names for context
- Keep context focused (single responsibility)
- Consider splitting large contexts
- Memoize context value if expensive
- Provide sensible defaults
- Test provider and consumer separately

Usage example:

```typescript
// In App.tsx
import { ThemeProvider } from './contexts/ThemeContext';

function App() {
  return (
    <ThemeProvider initialTheme="dark">
      <YourApp />
    </ThemeProvider>
  );
}

// In a component
import { useTheme } from './contexts/ThemeContext';

function Header() {
  const { theme, toggleTheme } = useTheme();

  return (
    <header className={theme}>
      <button onClick={toggleTheme}>Toggle Theme</button>
    </header>
  );
}
```
