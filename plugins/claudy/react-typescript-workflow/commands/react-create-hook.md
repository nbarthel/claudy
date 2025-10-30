# react-create-hook

Create a custom React hook with TypeScript

---

Create a custom React hook following best practices:

1. **Create hook file** in `hooks/` or `src/hooks/` directory
2. **Implement hook** with:
   - Clear naming (use prefix)
   - TypeScript types for parameters and return value
   - Proper dependency arrays
   - Cleanup logic if needed
3. **Add comprehensive tests** covering:
   - Initial state
   - State updates
   - Side effects
   - Edge cases
4. **Document the hook** with JSDoc comments
5. **Export from barrel** if using index files

Hook patterns to consider:

- State management hooks
- Data fetching hooks
- Event listener hooks
- Local storage hooks
- Form handling hooks
- Animation hooks

Example hook structure:

```typescript
import { useState, useEffect, useCallback } from 'react';

interface UseApiOptions<T> {
  url: string;
  initialData?: T;
  autoFetch?: boolean;
}

interface UseApiReturn<T> {
  data: T | null;
  loading: boolean;
  error: Error | null;
  refetch: () => Promise<void>;
}

/**
 * useApi - Custom hook for API data fetching
 *
 * @param options - Configuration options
 * @returns API state and refetch function
 */
export const useApi = <T,>({
  url,
  initialData = null,
  autoFetch = true,
}: UseApiOptions<T>): UseApiReturn<T> => {
  const [data, setData] = useState<T | null>(initialData);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(url);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const result = await response.json();
      setData(result);
    } catch (err) {
      setError(err as Error);
    } finally {
      setLoading(false);
    }
  }, [url]);

  useEffect(() => {
    if (autoFetch) {
      fetchData();
    }
  }, [autoFetch, fetchData]);

  return { data, loading, error, refetch: fetchData };
};
```

Best practices:

- Start hook names with "use"
- Return stable references with useCallback/useMemo
- Handle cleanup in useEffect
- Type generics for flexibility
- Document parameters and return values
- Include error handling
- Test with @testing-library/react-hooks
