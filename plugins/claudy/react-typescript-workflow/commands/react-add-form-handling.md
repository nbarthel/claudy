# react-add-form-handling

Implement form handling with validation using React Hook Form and Zod

---

Set up robust form handling with React Hook Form and Zod validation:

1. **Install dependencies**: react-hook-form, zod, @hookform/resolvers
2. **Create Zod schema** for form validation
3. **Implement form component** with:
   - useForm hook configuration
   - Form fields with registration
   - Error message display
   - Submit handler
4. **Add TypeScript types** from Zod schema
5. **Style form** with appropriate CSS/UI library
6. **Write tests** for form validation and submission
7. **Add accessibility** attributes (aria-labels, error announcements)

Form implementation:

```typescript
import React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

// Define validation schema
const userFormSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  email: z.string().email('Invalid email address'),
  age: z.number().min(18, 'Must be at least 18 years old').optional(),
  terms: z.boolean().refine((val) => val === true, {
    message: 'You must accept the terms and conditions',
  }),
});

// Infer TypeScript type from schema
type UserFormData = z.infer<typeof userFormSchema>;

interface UserFormProps {
  onSubmit: (data: UserFormData) => Promise<void>;
  initialData?: Partial<UserFormData>;
}

export const UserForm: React.FC<UserFormProps> = ({
  onSubmit,
  initialData,
}) => {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
    reset,
  } = useForm<UserFormData>({
    resolver: zodResolver(userFormSchema),
    defaultValues: initialData,
  });

  const onSubmitHandler = async (data: UserFormData) => {
    try {
      await onSubmit(data);
      reset();
    } catch (error) {
      console.error('Form submission error:', error);
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmitHandler)} className="space-y-4">
      <div>
        <label htmlFor="name">Name</label>
        <input
          id="name"
          type="text"
          {...register('name')}
          aria-invalid={errors.name ? 'true' : 'false'}
        />
        {errors.name && (
          <p className="error" role="alert">
            {errors.name.message}
          </p>
        )}
      </div>

      <div>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          {...register('email')}
          aria-invalid={errors.email ? 'true' : 'false'}
        />
        {errors.email && (
          <p className="error" role="alert">
            {errors.email.message}
          </p>
        )}
      </div>

      <div>
        <label htmlFor="age">Age (optional)</label>
        <input
          id="age"
          type="number"
          {...register('age', { valueAsNumber: true })}
          aria-invalid={errors.age ? 'true' : 'false'}
        />
        {errors.age && (
          <p className="error" role="alert">
            {errors.age.message}
          </p>
        )}
      </div>

      <div>
        <label>
          <input type="checkbox" {...register('terms')} />
          I accept the terms and conditions
        </label>
        {errors.terms && (
          <p className="error" role="alert">
            {errors.terms.message}
          </p>
        )}
      </div>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Submitting...' : 'Submit'}
      </button>
    </form>
  );
};
```

Best practices:

- Use Zod for schema validation
- Infer TypeScript types from schemas
- Handle async validation if needed
- Display errors near relevant fields
- Disable submit during submission
- Reset form after successful submission
- Use proper HTML input types
- Add ARIA attributes for accessibility
- Test validation rules
- Handle loading and error states
