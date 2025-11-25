# React Query - Padrões de Data Fetching Otimizado

**IMPLEMENTAR** data fetching com React Query seguindo estes padrões robustos:

## **QUERY FACTORIES PATTERN** - Para query keys coesas e reutilizáveis:

```typescript
// lib/query-factories.ts
export const userQueries = {
  // Base key para todas as queries de usuários
  all: ['users'] as const,
  
  // Lista de usuários com filtros
  lists: () => [...userQueries.all, 'list'] as const,
  list: (filters?: UserFilters) => [...userQueries.lists(), filters] as const,
  
  // Detalhes de usuário específico
  details: () => [...userQueries.all, 'detail'] as const,
  detail: (id: string) => [...userQueries.details(), id] as const,
  
  // Infinite queries
  infinites: () => [...userQueries.all, 'infinite'] as const,
  infinite: (filters?: UserFilters) => [...userQueries.infinites(), filters] as const,
  
  // User permissions
  permissions: (id: string) => [...userQueries.detail(id), 'permissions'] as const,
  
  // User activity
  activity: (id: string, period?: string) => [...userQueries.detail(id), 'activity', period] as const,
};

export const productQueries = {
  all: ['products'] as const,
  lists: () => [...productQueries.all, 'list'] as const,
  list: (filters?: ProductFilters) => [...productQueries.lists(), filters] as const,
  details: () => [...productQueries.all, 'detail'] as const,
  detail: (id: string) => [...productQueries.details(), id] as const,
  search: (query: string) => [...productQueries.all, 'search', query] as const,
};

export const orderQueries = {
  all: ['orders'] as const,
  lists: () => [...orderQueries.all, 'list'] as const,
  list: (filters?: OrderFilters) => [...orderQueries.lists(), filters] as const,
  details: () => [...orderQueries.all, 'detail'] as const,
  detail: (id: string) => [...orderQueries.details(), id] as const,
  userOrders: (userId: string) => [...orderQueries.all, 'user', userId] as const,
};
```

## **API FUNCTIONS PATTERN** - Funções puras para uso fora do React:

```typescript
// lib/api/users.api.ts
import { api } from '@/lib/api';

// Funções puras que podem ser usadas fora do React
export const usersApi = {
  // Fetch functions - podem ser usadas em qualquer lugar
  fetchUsers: async (filters?: UserFilters): Promise<PaginatedResponse<User>> => {
    const { data } = await api.get<PaginatedResponse<User>>('/users', {
      params: filters
    });
    return data;
  },

  fetchUser: async (userId: string): Promise<User> => {
    const { data } = await api.get<User>(`/users/${userId}`);
    return data;
  },

  fetchUserPermissions: async (userId: string): Promise<UserPermission[]> => {
    const { data } = await api.get<UserPermission[]>(`/users/${userId}/permissions`);
    return data;
  },

  fetchUserActivity: async (userId: string, period?: string): Promise<UserActivity[]> => {
    const { data } = await api.get<UserActivity[]>(`/users/${userId}/activity`, {
      params: { period }
    });
    return data;
  },

  // Mutation functions
  createUser: async (userData: CreateUserRequest): Promise<User> => {
    const { data } = await api.post<User>('/users', userData);
    return data;
  },

  updateUser: async (userId: string, userData: UpdateUserRequest): Promise<User> => {
    const { data } = await api.put<User>(`/users/${userId}`, userData);
    return data;
  },

  deleteUser: async (userId: string): Promise<void> => {
    await api.delete(`/users/${userId}`);
  },

  // Search function
  searchUsers: async (query: string, filters?: UserFilters): Promise<User[]> => {
    const { data } = await api.get<User[]>('/users/search', {
      params: { q: query, ...filters }
    });
    return data;
  },
};

// lib/api/products.api.ts
export const productsApi = {
  fetchProducts: async (filters?: ProductFilters): Promise<PaginatedResponse<Product>> => {
    const { data } = await api.get<PaginatedResponse<Product>>('/products', {
      params: filters
    });
    return data;
  },

  fetchProduct: async (productId: string): Promise<Product> => {
    const { data } = await api.get<Product>(`/products/${productId}`);
    return data;
  },

  searchProducts: async (query: string): Promise<Product[]> => {
    const { data } = await api.get<Product[]>('/products/search', {
      params: { q: query }
    });
    return data;
  },

  createProduct: async (productData: CreateProductRequest): Promise<Product> => {
    const { data } = await api.post<Product>('/products', productData);
    return data;
  },

  updateProduct: async (productId: string, productData: UpdateProductRequest): Promise<Product> => {
    const { data } = await api.put<Product>(`/products/${productId}`, productData);
    return data;
  },

  deleteProduct: async (productId: string): Promise<void> => {
    await api.delete(`/products/${productId}`);
  },
};
```

## **HOOK FUNCTIONS PATTERN** - Hooks que usam as factory queries:

```typescript
// hooks/use-users.ts
import { useQuery, useInfiniteQuery } from '@tanstack/react-query';
import { userQueries } from '@/lib/query-factories';
import { usersApi } from '@/lib/api/users.api';

// Hook para lista de usuários
export function useUsers(filters?: UserFilters) {
  return useQuery({
    queryKey: userQueries.list(filters),
    queryFn: () => usersApi.fetchUsers(filters),
    staleTime: 5 * 60 * 1000,
    keepPreviousData: true,
  });
}

// Hook para usuário específico
export function useUser(userId: string, enabled = true) {
  return useQuery({
    queryKey: userQueries.detail(userId),
    queryFn: () => usersApi.fetchUser(userId),
    enabled: enabled && !!userId,
    staleTime: 10 * 60 * 1000,
  });
}

// Hook para infinite scroll
export function useUsersInfinite(filters?: UserFilters) {
  return useInfiniteQuery({
    queryKey: userQueries.infinite(filters),
    queryFn: async ({ pageParam = 1 }) => {
      return usersApi.fetchUsers({ ...filters, page: pageParam, limit: 20 });
    },
    getNextPageParam: (lastPage) => {
      return lastPage.hasMore ? lastPage.page + 1 : undefined;
    },
    staleTime: 5 * 60 * 1000,
  });
}

// Hook para permissões do usuário
export function useUserPermissions(userId: string, enabled = true) {
  return useQuery({
    queryKey: userQueries.permissions(userId),
    queryFn: () => usersApi.fetchUserPermissions(userId),
    enabled: enabled && !!userId,
    staleTime: 15 * 60 * 1000, // Permissões mudam menos frequentemente
  });
}

// Hook para atividade do usuário
export function useUserActivity(userId: string, period = '7d', enabled = true) {
  return useQuery({
    queryKey: userQueries.activity(userId, period),
    queryFn: () => usersApi.fetchUserActivity(userId, period),
    enabled: enabled && !!userId,
    staleTime: 2 * 60 * 1000, // Atividade muda mais frequentemente
  });
}

// hooks/use-products.ts
export function useProducts(filters?: ProductFilters) {
  return useQuery({
    queryKey: productQueries.list(filters),
    queryFn: () => productsApi.fetchProducts(filters),
    staleTime: 10 * 60 * 1000,
  });
}

export function useProduct(productId: string, enabled = true) {
  return useQuery({
    queryKey: productQueries.detail(productId),
    queryFn: () => productsApi.fetchProduct(productId),
    enabled: enabled && !!productId,
    staleTime: 15 * 60 * 1000,
  });
}

export function useProductSearch(query: string, enabled = true) {
  return useQuery({
    queryKey: productQueries.search(query),
    queryFn: () => productsApi.searchProducts(query),
    enabled: enabled && query.length > 2,
    staleTime: 5 * 60 * 1000,
  });
}
```

## **UTILITY FUNCTIONS PATTERN** - Para uso fora do React:

```typescript
// lib/query-utils.ts
import { QueryClient } from '@tanstack/react-query';
import { userQueries, productQueries } from '@/lib/query-factories';
import { usersApi, productsApi } from '@/lib/api';

// Funções utilitárias que podem ser usadas fora do React
export const queryUtils = {
  // Prefetch functions - úteis para SSR ou otimização
  prefetchUser: async (queryClient: QueryClient, userId: string) => {
    await queryClient.prefetchQuery({
      queryKey: userQueries.detail(userId),
      queryFn: () => usersApi.fetchUser(userId),
      staleTime: 10 * 60 * 1000,
    });
  },

  prefetchUsers: async (queryClient: QueryClient, filters?: UserFilters) => {
    await queryClient.prefetchQuery({
      queryKey: userQueries.list(filters),
      queryFn: () => usersApi.fetchUsers(filters),
      staleTime: 5 * 60 * 1000,
    });
  },

  // Cache setters - para atualização otimista
  setUserInCache: (queryClient: QueryClient, user: User) => {
    queryClient.setQueryData(userQueries.detail(user.id), user);
  },

  updateUserInCache: (queryClient: QueryClient, userId: string, updates: Partial<User>) => {
    queryClient.setQueryData<User>(
      userQueries.detail(userId),
      (oldUser) => oldUser ? { ...oldUser, ...updates } : undefined
    );
  },

  // Cache invalidation
  invalidateUsers: (queryClient: QueryClient) => {
    queryClient.invalidateQueries({ queryKey: userQueries.all });
  },

  invalidateUser: (queryClient: QueryClient, userId: string) => {
    queryClient.invalidateQueries({ queryKey: userQueries.detail(userId) });
  },

  // Remove from cache
  removeUser: (queryClient: QueryClient, userId: string) => {
    queryClient.removeQueries({ queryKey: userQueries.detail(userId) });
  },

  // Get cached data (para uso em interceptors, middleware, etc.)
  getCachedUser: (queryClient: QueryClient, userId: string): User | undefined => {
    return queryClient.getQueryData<User>(userQueries.detail(userId));
  },

  getCachedUsers: (queryClient: QueryClient, filters?: UserFilters): PaginatedResponse<User> | undefined => {
    return queryClient.getQueryData<PaginatedResponse<User>>(userQueries.list(filters));
  },
};

// hooks/use-query-utils.ts - Wrapper para usar dentro do React
export function useQueryUtils() {
  const queryClient = useQueryClient();
  
  return useMemo(() => ({
    prefetchUser: (userId: string) => queryUtils.prefetchUser(queryClient, userId),
    prefetchUsers: (filters?: UserFilters) => queryUtils.prefetchUsers(queryClient, filters),
    setUserInCache: (user: User) => queryUtils.setUserInCache(queryClient, user),
    updateUserInCache: (userId: string, updates: Partial<User>) => 
      queryUtils.updateUserInCache(queryClient, userId, updates),
    invalidateUsers: () => queryUtils.invalidateUsers(queryClient),
    invalidateUser: (userId: string) => queryUtils.invalidateUser(queryClient, userId),
    removeUser: (userId: string) => queryUtils.removeUser(queryClient, userId),
    getCachedUser: (userId: string) => queryUtils.getCachedUser(queryClient, userId),
    getCachedUsers: (filters?: UserFilters) => queryUtils.getCachedUsers(queryClient, filters),
  }), [queryClient]);
}
```

## **MUTATION HOOKS PATTERN** - Para operações de escrita:

```typescript
// hooks/use-user-mutations.ts
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { userQueries } from '@/lib/query-factories';
import { usersApi } from '@/lib/api/users.api';
import { queryUtils } from '@/lib/query-utils';
import { toast } from '@/lib/toast';

// Hook para criar usuário
export function useCreateUser() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: usersApi.createUser,
    onSuccess: (newUser) => {
      // Atualiza cache com novo usuário
      queryUtils.setUserInCache(queryClient, newUser);
      
      // Invalida listas para refetch
      queryUtils.invalidateUsers(queryClient);
      
      toast.success('Usuário criado com sucesso!');
    },
    onError: (error: ApiError) => {
      toast.error(error.message || 'Erro ao criar usuário');
    }
  });
}

// Hook para atualizar usuário
export function useUpdateUser() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateUserRequest }) => 
      usersApi.updateUser(id, data),
    onMutate: async ({ id, data }) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: userQueries.detail(id) });
      
      // Snapshot previous value
      const previousUser = queryUtils.getCachedUser(queryClient, id);
      
      // Optimistically update
      if (previousUser) {
        queryUtils.updateUserInCache(queryClient, id, {
          ...data,
          updatedAt: new Date().toISOString()
        });
      }
      
      return { previousUser };
    },
    onError: (error, variables, context) => {
      // Rollback optimistic update
      if (context?.previousUser) {
        queryUtils.setUserInCache(queryClient, context.previousUser);
      }
      toast.error('Erro ao atualizar usuário');
    },
    onSettled: (data, error, variables) => {
      // Refetch após mutation
      queryUtils.invalidateUser(queryClient, variables.id);
    }
  });
}

// Hook para deletar usuário
export function useDeleteUser() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: usersApi.deleteUser,
    onMutate: async (userId: string) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: userQueries.detail(userId) });
      
      // Snapshot previous value
      const previousUser = queryUtils.getCachedUser(queryClient, userId);
      
      // Optimistically remove from lists
      queryClient.setQueriesData<PaginatedResponse<User>>(
        { queryKey: userQueries.lists() },
        (old) => {
          if (!old) return old;
          return {
            ...old,
            items: old.items.filter(user => user.id !== userId),
            total: old.total - 1
          };
        }
      );
      
      return { previousUser, userId };
    },
    onError: (error, userId, context) => {
      // Rollback optimistic update
      if (context?.previousUser) {
        queryUtils.setUserInCache(queryClient, context.previousUser);
        queryUtils.invalidateUsers(queryClient);
      }
      toast.error('Erro ao deletar usuário');
    },
    onSuccess: (_, userId) => {
      // Remove do cache definitivamente
      queryUtils.removeUser(queryClient, userId);
      toast.success('Usuário removido com sucesso!');
    }
  });
}
```

## **CUSTOM QUERY PROVIDER** - Para configuração global:

```typescript
// lib/query-client.ts
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutos default
      cacheTime: 10 * 60 * 1000, // 10 minutos default
      refetchOnWindowFocus: false,
      refetchOnReconnect: true,
      retry: (failureCount, error) => {
        // Não retry em erros 4xx
        if (error.status >= 400 && error.status < 500) {
          return false;
        }
        return failureCount < 3;
      }
    },
    mutations: {
      retry: 1
    }
  }
});

// providers/query-provider.tsx
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';

export function QueryProvider({ children }: { children: React.ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      {children}
      {process.env.NODE_ENV === 'development' && (
        <ReactQueryDevtools initialIsOpen={false} />
      )}
    </QueryClientProvider>
  );
}
```

## **ERROR HANDLING PATTERN** - Para tratamento robusto de erros:

```typescript
// hooks/use-error-handler.ts
import { useQueryErrorResetBoundary } from '@tanstack/react-query';

export function useErrorHandler() {
  const { reset } = useQueryErrorResetBoundary();
  
  const handleError = useCallback((error: Error) => {
    // Log error para monitoramento
    console.error('Query Error:', error);
    
    // Reset boundary se necessário
    if (error.name === 'ChunkLoadError') {
      reset();
      window.location.reload();
    }
  }, [reset]);
  
  return { handleError };
}

// components/query-error-boundary.tsx
import { ErrorBoundary } from 'react-error-boundary';
import { useQueryErrorResetBoundary } from '@tanstack/react-query';

function QueryErrorFallback({ error, resetErrorBoundary }) {
  return (
    <div className="p-6 text-center">
      <h2 className="text-lg font-semibold text-red-600 mb-2">
        Ops! Algo deu errado
      </h2>
      <p className="text-gray-600 mb-4">
        {error.message || 'Erro inesperado ao carregar dados'}
      </p>
      <button
        onClick={resetErrorBoundary}
        className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
      >
        Tentar novamente
      </button>
    </div>
  );
}

export function QueryErrorBoundary({ children }) {
  const { reset } = useQueryErrorResetBoundary();
  
  return (
    <ErrorBoundary
      FallbackComponent={QueryErrorFallback}
      onReset={reset}
    >
      {children}
    </ErrorBoundary>
  );
}
```

## **SUSPENSE INTEGRATION** - Para loading states:

```typescript
// hooks/use-suspense-query.ts
export function useSuspenseUser(userId: string) {
  return useSuspenseQuery({
    queryKey: ['users', userId],
    queryFn: async () => {
      const { data } = await api.get<User>(`/users/${userId}`);
      return data;
    }
  });
}

// components/user-profile.tsx
import { Suspense } from 'react';

function UserProfileContent({ userId }: { userId: string }) {
  const user = useSuspenseUser(userId);
  
  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
}

export function UserProfile({ userId }: { userId: string }) {
  return (
    <QueryErrorBoundary>
      <Suspense fallback={<UserProfileSkeleton />}>
        <UserProfileContent userId={userId} />
      </Suspense>
    </QueryErrorBoundary>
  );
}
```

## **CACHE MANAGEMENT PATTERN** - Para performance otimizada:

```typescript
// hooks/use-cache-utils.ts
export function useCacheUtils() {
  const queryClient = useQueryClient();
  
  const prefetchUser = useCallback(async (userId: string) => {
    await queryClient.prefetchQuery({
      queryKey: ['users', userId],
      queryFn: () => api.get<User>(`/users/${userId}`).then(res => res.data),
      staleTime: 10 * 60 * 1000
    });
  }, [queryClient]);
  
  const invalidateUsers = useCallback(() => {
    queryClient.invalidateQueries({ queryKey: ['users'] });
  }, [queryClient]);
  
  const clearUserCache = useCallback((userId: string) => {
    queryClient.removeQueries({ queryKey: ['users', userId] });
  }, [queryClient]);
  
  return { prefetchUser, invalidateUsers, clearUserCache };
}
```

**REGRAS IMPORTANTES**:

- **SEMPRE** use queryKey arrays consistentes e descritivas
- **IMPLEMENTE** optimistic updates para melhor UX
- **CONFIGURE** staleTime e cacheTime apropriadamente
- **TRATE** erros com error boundaries e fallbacks
- **USE** Suspense para loading states limpos
- **PREFETCH** dados quando possível (hover, focus)
- **INVALIDE** queries relacionadas após mutations
- **MONITORE** performance com React Query Devtools
- **IMPLEMENTE** retry logic customizada por tipo de erro
- **SEPARE** hooks por domínio/feature para organização