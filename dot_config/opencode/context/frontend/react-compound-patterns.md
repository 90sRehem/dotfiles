# React Compound Components - Padrões de UI Reutilizável

**CRIAR** componentes compound para UIs complexas e reutilizáveis seguindo estes padrões:

## **COMPOUND COMPONENT PATTERN** - Para interfaces complexas:

```typescript
import React, { createContext, useContext, forwardRef } from 'react';
import { cn } from '@/lib/utils';

// Context para comunicação entre componentes
interface FormContextData {
  errors: Record<string, string>;
  isLoading: boolean;
}

const FormContext = createContext<FormContextData>({} as FormContextData);

// Root component - gerencia estado e contexto
const Form = {
  Root: ({ children, errors = {}, isLoading = false, onSubmit, className, ...props }) => {
    return (
      <FormContext.Provider value={{ errors, isLoading }}>
        <form onSubmit={onSubmit} className={cn("space-y-6", className)} {...props}>
          {children}
        </form>
      </FormContext.Provider>
    );
  },

  // Container para campos
  Fields: ({ children, className }) => (
    <div className={cn("space-y-4", className)}>
      {children}
    </div>
  ),

  // Campo individual com label e erro
  Field: ({ label, name, error, children, required, className }) => {
    const { errors } = useContext(FormContext);
    const fieldError = error || errors[name];
    
    return (
      <div className={cn("space-y-1", className)}>
        <label htmlFor={name} className="block text-sm font-medium text-gray-700">
          {label}
          {required && <span className="text-red-500 ml-1">*</span>}
        </label>
        {children}
        {fieldError && (
          <span className="text-red-500 text-xs mt-1 block">{fieldError}</span>
        )}
      </div>
    );
  },

  // Input com estilos consistentes
  Input: forwardRef<HTMLInputElement, InputProps>(({ className, error, ...props }, ref) => {
    return (
      <input
        ref={ref}
        className={cn(
          "flex h-10 w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm",
          "placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent",
          "disabled:cursor-not-allowed disabled:opacity-50",
          error && "border-red-500 focus:ring-red-500",
          className
        )}
        {...props}
      />
    );
  }),

  // Textarea com estilos consistentes
  Textarea: forwardRef<HTMLTextAreaElement, TextareaProps>(({ className, ...props }, ref) => {
    return (
      <textarea
        ref={ref}
        className={cn(
          "flex min-h-[80px] w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm",
          "placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent",
          "disabled:cursor-not-allowed disabled:opacity-50",
          className
        )}
        {...props}
      />
    );
  }),

  // Select customizado
  Select: ({ children, placeholder, className, ...props }) => (
    <select
      className={cn(
        "flex h-10 w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm",
        "focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent",
        "disabled:cursor-not-allowed disabled:opacity-50",
        className
      )}
      {...props}
    >
      {placeholder && <option value="">{placeholder}</option>}
      {children}
    </select>
  ),

  // Botão de submit com loading
  Submit: ({ children, variant = "primary", size = "md", className, ...props }) => {
    const { isLoading } = useContext(FormContext);
    
    const baseClasses = "inline-flex items-center justify-center rounded-md font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none";
    
    const variants = {
      primary: "bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500",
      secondary: "bg-gray-200 text-gray-900 hover:bg-gray-300 focus:ring-gray-500",
      destructive: "bg-red-600 text-white hover:bg-red-700 focus:ring-red-500"
    };
    
    const sizes = {
      sm: "h-8 px-3 text-xs",
      md: "h-10 px-4 py-2 text-sm",
      lg: "h-12 px-8 text-base"
    };

    return (
      <button
        type="submit"
        disabled={isLoading}
        className={cn(baseClasses, variants[variant], sizes[size], className)}
        {...props}
      >
        {isLoading ? (
          <>
            <svg className="animate-spin -ml-1 mr-2 h-4 w-4" fill="none" viewBox="0 0 24 24">
              <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"/>
              <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"/>
            </svg>
            Carregando...
          </>
        ) : children}
      </button>
    );
  }
};

export { Form };
```

**USO DO COMPOUND COMPONENT**:

```typescript
// Exemplo de uso com React Hook Form
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

const userSchema = z.object({
  name: z.string().min(2, 'Nome deve ter pelo menos 2 caracteres'),
  email: z.string().email('Email inválido'),
  role: z.enum(['admin', 'user'])
});

type UserFormData = z.infer<typeof userSchema>;

export function UserForm() {
  const { register, handleSubmit, formState: { errors, isSubmitting } } = useForm<UserFormData>({
    resolver: zodResolver(userSchema)
  });

  const onSubmit = async (data: UserFormData) => {
    // Submit logic
  };

  return (
    <Form.Root onSubmit={handleSubmit(onSubmit)} errors={errors} isLoading={isSubmitting}>
      <Form.Fields>
        <Form.Field label="Nome completo" name="name" required>
          <Form.Input {...register('name')} placeholder="Digite seu nome" />
        </Form.Field>

        <Form.Field label="Email" name="email" required>
          <Form.Input type="email" {...register('email')} placeholder="seu@email.com" />
        </Form.Field>

        <Form.Field label="Função" name="role" required>
          <Form.Select {...register('role')} placeholder="Selecione uma função">
            <option value="user">Usuário</option>
            <option value="admin">Administrador</option>
          </Form.Select>
        </Form.Field>

        <Form.Submit>
          Salvar usuário
        </Form.Submit>
      </Form.Fields>
    </Form.Root>
  );
}
```

## **DATA TABLE COMPOUND PATTERN** - Para tabelas complexas:

```typescript
const DataTable = {
  Root: ({ children, className }) => (
    <div className={cn("w-full overflow-auto", className)}>
      <table className="w-full caption-bottom text-sm">
        {children}
      </table>
    </div>
  ),

  Header: ({ children }) => (
    <thead className="border-b">
      <tr className="border-b transition-colors hover:bg-gray-50">
        {children}
      </tr>
    </thead>
  ),

  HeaderCell: ({ children, sortable, onSort, sortDirection, className }) => (
    <th className={cn("h-12 px-4 text-left align-middle font-medium text-gray-700", className)}>
      {sortable ? (
        <button onClick={onSort} className="flex items-center space-x-1 hover:text-gray-900">
          <span>{children}</span>
          {sortDirection && (
            <span className="text-xs">
              {sortDirection === 'asc' ? '↑' : '↓'}
            </span>
          )}
        </button>
      ) : children}
    </th>
  ),

  Body: ({ children }) => (
    <tbody className="[&_tr:last-child]:border-0">
      {children}
    </tbody>
  ),

  Row: ({ children, onClick, className }) => (
    <tr 
      onClick={onClick}
      className={cn(
        "border-b transition-colors hover:bg-gray-50",
        onClick && "cursor-pointer",
        className
      )}
    >
      {children}
    </tr>
  ),

  Cell: ({ children, className }) => (
    <td className={cn("p-4 align-middle", className)}>
      {children}
    </td>
  )
};
```

## **MODAL COMPOUND PATTERN** - Para dialogs complexos:

```typescript
const Modal = {
  Root: ({ open, onClose, children }) => {
    if (!open) return null;
    
    return (
      <div className="fixed inset-0 z-50 flex items-center justify-center">
        <div className="fixed inset-0 bg-black/50" onClick={onClose} />
        <div className="relative bg-white rounded-lg shadow-lg max-w-md w-full mx-4">
          {children}
        </div>
      </div>
    );
  },

  Header: ({ children, onClose }) => (
    <div className="flex items-center justify-between p-6 border-b">
      <h2 className="text-lg font-semibold">{children}</h2>
      {onClose && (
        <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
          ✕
        </button>
      )}
    </div>
  ),

  Content: ({ children }) => (
    <div className="p-6">
      {children}
    </div>
  ),

  Footer: ({ children }) => (
    <div className="flex justify-end space-x-2 p-6 border-t">
      {children}
    </div>
  )
};
```

**REGRAS IMPORTANTES**:

- **SEMPRE** use Context API para comunicação entre componentes compound
- **SEMPRE** aplique TypeScript strict com interfaces bem definidas
- **USE** forwardRef para componentes que precisam de ref
- **COMBINE** com React Hook Form para validação robusta
- **APLIQUE** Tailwind classes de forma consistente
- **MANTENHA** cada sub-component focado em uma responsabilidade
- **EXPORT** como object literal para namespace claro
- **VALIDE** props com TypeScript interfaces detalhadas

**TESTING PATTERN**:

```typescript
// Teste de compound component
import { render, screen } from '@testing-library/react';
import { userEvent } from '@testing-library/user-event';

describe('Form Compound Component', () => {
  it('should render form with fields and handle submission', async () => {
    const onSubmit = jest.fn();
    
    render(
      <Form.Root onSubmit={onSubmit}>
        <Form.Fields>
          <Form.Field label="Name" name="name">
            <Form.Input data-testid="name-input" />
          </Form.Field>
          <Form.Submit>Submit</Form.Submit>
        </Form.Fields>
      </Form.Root>
    );

    await userEvent.type(screen.getByTestId('name-input'), 'John Doe');
    await userEvent.click(screen.getByRole('button', { name: /submit/i }));

    expect(onSubmit).toHaveBeenCalled();
  });
});
```