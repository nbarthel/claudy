# react-add-data-fetching

Implement data fetching with React Query (TanStack Query)

---

Set up efficient data fetching with React Query and TypeScript:

1. **Install dependencies**: @tanstack/react-query, @tanstack/react-query-devtools
2. **Configure QueryClient** and provider in app root
3. **Create API client** module with typed functions
4. **Implement query hooks** for data fetching
5. **Add mutation hooks** for data modification
6. **Handle loading and error states**
7. **Configure caching strategy**
8. **Add React Query DevTools** for development

Query client setup:

```typescript
// src/lib/queryClient.ts
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});
```

App setup:

```typescript
// src/App.tsx
import { QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import { queryClient } from './lib/queryClient';

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <YourApp />
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  );
}
```

API client:

```typescript
// src/api/users.ts
export interface User {
  id: number;
  name: string;
  email: string;
}

export interface CreateUserDto {
  name: string;
  email: string;
}

const API_BASE_URL = process.env.VITE_API_URL || 'http://localhost:3000/api';

export const userApi = {
  getAll: async (): Promise<User[]> => {
    const response = await fetch(`${API_BASE_URL}/users`);
    if (!response.ok) {
      throw new Error('Failed to fetch users');
    }
    return response.json();
  },

  getById: async (id: number): Promise<User> => {
    const response = await fetch(`${API_BASE_URL}/users/${id}`);
    if (!response.ok) {
      throw new Error(`Failed to fetch user ${id}`);
    }
    return response.json();
  },

  create: async (data: CreateUserDto): Promise<User> => {
    const response = await fetch(`${API_BASE_URL}/users`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    if (!response.ok) {
      throw new Error('Failed to create user');
    }
    return response.json();
  },

  delete: async (id: number): Promise<void> => {
    const response = await fetch(`${API_BASE_URL}/users/${id}`, {
      method: 'DELETE',
    });
    if (!response.ok) {
      throw new Error(`Failed to delete user ${id}`);
    }
  },
};
```

Query hooks:

```typescript
// src/hooks/useUsers.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { userApi, User, CreateUserDto } from '../api/users';

// Query keys
export const userKeys = {
  all: ['users'] as const,
  detail: (id: number) => [...userKeys.all, id] as const,
};

// Fetch all users
export const useUsers = () => {
  return useQuery({
    queryKey: userKeys.all,
    queryFn: userApi.getAll,
  });
};

// Fetch single user
export const useUser = (id: number) => {
  return useQuery({
    queryKey: userKeys.detail(id),
    queryFn: () => userApi.getById(id),
    enabled: !!id, // Only run if id is truthy
  });
};

// Create user mutation
export const useCreateUser = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: userApi.create,
    onSuccess: () => {
      // Invalidate and refetch users list
      queryClient.invalidateQueries({ queryKey: userKeys.all });
    },
  });
};

// Delete user mutation
export const useDeleteUser = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: userApi.delete,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: userKeys.all });
    },
  });
};
```

Component usage:

```typescript
// src/components/UserList.tsx
import { useUsers, useCreateUser } from '../hooks/useUsers';

export const UserList: React.FC = () => {
  const { data: users, isLoading, error } = useUsers();
  const createUser = useCreateUser();

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  const handleCreate = async () => {
    try {
      await createUser.mutateAsync({
        name: 'New User',
        email: 'user@example.com',
      });
    } catch (error) {
      console.error('Failed to create user:', error);
    }
  };

  return (
    <div>
      <button onClick={handleCreate} disabled={createUser.isPending}>
        {createUser.isPending ? 'Creating...' : 'Create User'}
      </button>
      <ul>
        {users?.map((user) => (
          <li key={user.id}>{user.name}</li>
        ))}
      </ul>
    </div>
  );
};
```

Best practices:

- Use query keys consistently
- Organize queries by domain
- Handle loading and error states
- Invalidate queries after mutations
- Use optimistic updates for better UX
- Configure appropriate stale times
- Leverage React Query DevTools
- Type all API responses
- Handle authentication tokens
- Implement error boundaries
