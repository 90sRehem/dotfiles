# Web Development Context

## Modern Web Development Patterns

### Frontend Architecture
- **Component-Based Architecture**: React, Vue, Svelte components
- **State Management**: Redux, Zustand, Context API, Pinia
- **Routing**: React Router, Vue Router, SvelteKit routing
- **Styling**: CSS Modules, Styled Components, Tailwind CSS

### HTML Structure Best Practices
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Page description">
  <title>Page Title</title>
  <!-- Preload critical resources -->
  <link rel="preload" href="critical.css" as="style">
</head>
<body>
  <!-- Semantic HTML structure -->
  <header role="banner">
    <nav role="navigation">
      <!-- Navigation items -->
    </nav>
  </header>
  
  <main role="main">
    <!-- Main content -->
  </main>
  
  <footer role="contentinfo">
    <!-- Footer content -->
  </footer>
</body>
</html>
```

### CSS Architecture
```css
/* CSS Custom Properties for theming */
:root {
  --primary-color: #007bff;
  --secondary-color: #6c757d;
  --font-family: 'Inter', system-ui, sans-serif;
  --border-radius: 0.375rem;
  --spacing-unit: 1rem;
}

/* Mobile-first responsive design */
.container {
  padding: var(--spacing-unit);
  max-width: 1200px;
  margin: 0 auto;
}

@media (min-width: 768px) {
  .container {
    padding: calc(var(--spacing-unit) * 2);
  }
}

/* Modern layout with Grid/Flexbox */
.layout {
  display: grid;
  grid-template-columns: 1fr;
  gap: var(--spacing-unit);
}

@media (min-width: 1024px) {
  .layout {
    grid-template-columns: 250px 1fr;
  }
}
```

### React Component Patterns
```jsx
// Functional component with hooks
import { useState, useEffect } from 'react';

function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function fetchUser() {
      try {
        setLoading(true);
        const response = await fetch(`/api/users/${userId}`);
        if (!response.ok) throw new Error('Failed to fetch user');
        const userData = await response.json();
        setUser(userData);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    }

    fetchUser();
  }, [userId]);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!user) return <div>User not found</div>;

  return (
    <div className="user-profile">
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
}
```

### Form Handling
```jsx
// Modern form handling with validation
import { useState } from 'react';

function ContactForm() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    message: ''
  });
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const validateForm = () => {
    const newErrors = {};
    
    if (!formData.name.trim()) {
      newErrors.name = 'Name is required';
    }
    
    if (!formData.email.trim()) {
      newErrors.email = 'Email is required';
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = 'Email is invalid';
    }
    
    if (!formData.message.trim()) {
      newErrors.message = 'Message is required';
    }
    
    return newErrors;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    const formErrors = validateForm();
    if (Object.keys(formErrors).length > 0) {
      setErrors(formErrors);
      return;
    }
    
    setIsSubmitting(true);
    try {
      await submitForm(formData);
      setFormData({ name: '', email: '', message: '' });
      setErrors({});
    } catch (error) {
      setErrors({ submit: 'Failed to submit form' });
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      {/* Form fields with error handling */}
    </form>
  );
}
```

### File Structure for Web Projects
```
project/
├── public/
│   ├── index.html
│   ├── favicon.ico
│   └── robots.txt
├── src/
│   ├── components/
│   │   ├── common/       # Reusable components
│   │   ├── layout/       # Layout components
│   │   └── pages/        # Page-specific components
│   ├── hooks/            # Custom React hooks
│   ├── services/         # API calls, business logic
│   ├── utils/            # Helper functions
│   ├── styles/           # Global styles
│   └── App.jsx
├── package.json
└── README.md
```

### Performance Optimization
```jsx
// Code splitting with lazy loading
import { lazy, Suspense } from 'react';

const LazyComponent = lazy(() => import('./LazyComponent'));

function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <LazyComponent />
    </Suspense>
  );
}

// Memoization for expensive calculations
import { useMemo } from 'react';

function ExpensiveComponent({ data }) {
  const processedData = useMemo(() => {
    return data.filter(item => item.active)
              .sort((a, b) => a.priority - b.priority);
  }, [data]);

  return <div>{/* Render processed data */}</div>;
}
```

### Accessibility Best Practices
```jsx
// Proper ARIA labels and semantic HTML
function SearchInput({ onSearch }) {
  return (
    <div role="search">
      <label htmlFor="search-input" className="sr-only">
        Search products
      </label>
      <input
        id="search-input"
        type="search"
        placeholder="Search..."
        aria-label="Search products"
        onChange={(e) => onSearch(e.target.value)}
      />
      <button type="submit" aria-label="Submit search">
        🔍
      </button>
    </div>
  );
}
```

### SEO Considerations
- Use semantic HTML elements
- Include proper meta tags
- Implement structured data (JSON-LD)
- Optimize images with alt text
- Use descriptive URLs
- Implement proper heading hierarchy (h1, h2, h3...)

### Modern Build Tools
- **Vite**: Fast build tool for modern web projects
- **Webpack**: Module bundler with extensive plugin ecosystem
- **Parcel**: Zero-configuration build tool
- **ESBuild**: Extremely fast JavaScript bundler

### Testing Strategies
```jsx
// Unit testing with React Testing Library
import { render, screen, fireEvent } from '@testing-library/react';
import { ContactForm } from './ContactForm';

test('shows validation error for empty email', async () => {
  render(<ContactForm />);
  
  const submitButton = screen.getByRole('button', { name: /submit/i });
  fireEvent.click(submitButton);
  
  expect(await screen.findByText('Email is required')).toBeInTheDocument();
});
```

### Progressive Web App (PWA) Features
- Service Worker for offline functionality
- Web App Manifest for installability
- Push notifications
- Background sync
- Cache strategies

### Security Best Practices
- Sanitize user inputs
- Use HTTPS everywhere
- Implement Content Security Policy (CSP)
- Validate data on both client and server
- Use environment variables for sensitive data
- Implement proper authentication and authorization