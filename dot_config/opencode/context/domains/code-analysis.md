# Code Analysis Context

## Code Quality Analysis Framework

### Code Quality Metrics
- **Complexity**: Cyclomatic complexity, cognitive complexity
- **Maintainability**: Code readability, modularity, documentation
- **Performance**: Time/space complexity, bottlenecks identification
- **Security**: Vulnerability detection, input validation
- **Test Coverage**: Unit test coverage, integration test coverage

### Common Code Smells

#### Structural Issues
```javascript
// ❌ Long Method (too many responsibilities)
function processUser(userData) {
  // 50+ lines of mixed validation, transformation, and saving
}

// ✅ Separated Concerns
function validateUser(userData) { /* validation only */ }
function transformUser(userData) { /* transformation only */ }
function saveUser(userData) { /* persistence only */ }
```

#### Naming Issues
```javascript
// ❌ Poor naming
function calc(x, y, z) { return x * y * z; }
const d = new Date();
let temp = getData();

// ✅ Descriptive naming
function calculateVolume(length, width, height) { return length * width * height; }
const currentDate = new Date();
let userProfileData = getUserProfile();
```

#### Duplication Issues
```javascript
// ❌ Code duplication
function formatUserName(user) {
  return user.firstName + ' ' + user.lastName;
}

function formatEmployeeName(employee) {
  return employee.firstName + ' ' + employee.lastName;
}

// ✅ Extract common logic
function formatFullName(person) {
  return `${person.firstName} ${person.lastName}`;
}
```

### Security Analysis Patterns

#### Input Validation
```javascript
// ❌ No validation
function updateUser(userId, data) {
  database.update(userId, data); // Direct database access
}

// ✅ Proper validation
function updateUser(userId, data) {
  if (!isValidUserId(userId)) {
    throw new Error('Invalid user ID');
  }
  
  const sanitizedData = sanitizeUserData(data);
  const validatedData = validateUserData(sanitizedData);
  
  return database.update(userId, validatedData);
}
```

#### SQL Injection Prevention
```javascript
// ❌ Vulnerable to SQL injection
const query = `SELECT * FROM users WHERE id = ${userId}`;

// ✅ Parameterized queries
const query = 'SELECT * FROM users WHERE id = ?';
database.query(query, [userId]);
```

### Performance Analysis

#### Common Performance Issues
```javascript
// ❌ N+1 Query Problem
async function getUsersWithPosts() {
  const users = await User.findAll();
  for (let user of users) {
    user.posts = await Post.findByUserId(user.id); // N additional queries
  }
  return users;
}

// ✅ Optimized with joins
async function getUsersWithPosts() {
  return User.findAll({
    include: [{ model: Post }] // Single query with join
  });
}
```

#### Memory Leaks Detection
```javascript
// ❌ Memory leak - event listeners not removed
function setupComponent() {
  const button = document.getElementById('myButton');
  button.addEventListener('click', handleClick);
  // Component unmounted but listener still exists
}

// ✅ Proper cleanup
function setupComponent() {
  const button = document.getElementById('myButton');
  const cleanup = () => button.removeEventListener('click', handleClick);
  button.addEventListener('click', handleClick);
  return cleanup; // Return cleanup function
}
```

### Code Architecture Analysis

#### Dependency Issues
```javascript
// ❌ Tight coupling
class OrderService {
  constructor() {
    this.emailService = new EmailService(); // Hard dependency
    this.paymentService = new PaymentService();
  }
}

// ✅ Dependency injection
class OrderService {
  constructor(emailService, paymentService) {
    this.emailService = emailService;
    this.paymentService = paymentService;
  }
}
```

#### Single Responsibility Violation
```javascript
// ❌ Multiple responsibilities
class User {
  constructor(name, email) {
    this.name = name;
    this.email = email;
  }
  
  save() { /* database logic */ }
  sendEmail() { /* email logic */ }
  validateEmail() { /* validation logic */ }
  formatName() { /* formatting logic */ }
}

// ✅ Separated responsibilities
class User {
  constructor(name, email) {
    this.name = name;
    this.email = email;
  }
}

class UserRepository {
  save(user) { /* database logic */ }
}

class EmailService {
  send(user, message) { /* email logic */ }
}
```

### Code Analysis Tools Integration

#### ESLint Configuration
```json
{
  "extends": ["eslint:recommended", "@typescript-eslint/recommended"],
  "rules": {
    "complexity": ["error", 10],
    "max-lines": ["error", 300],
    "max-params": ["error", 4],
    "no-console": "warn",
    "prefer-const": "error"
  }
}
```

#### TypeScript Analysis
```typescript
// Type safety analysis
interface User {
  id: string;
  name: string;
  email: string;
}

// ❌ Runtime error prone
function getUser(id: any): any {
  return database.findById(id);
}

// ✅ Type safe
function getUser(id: string): Promise<User | null> {
  return database.findById(id);
}
```

### Testing Analysis

#### Test Quality Assessment
```javascript
// ❌ Weak test
test('user function works', () => {
  const result = someFunction();
  expect(result).toBeTruthy();
});

// ✅ Comprehensive test
test('calculateTotalPrice applies discount and tax correctly', () => {
  // Arrange
  const basePrice = 100;
  const discountPercent = 10;
  const taxRate = 0.08;
  
  // Act
  const result = calculateTotalPrice(basePrice, taxRate, discountPercent);
  
  // Assert
  expect(result).toBe(97.2); // (100 - 10) * 1.08
});
```

### Code Review Checklist

#### Functionality
- [ ] Code works as intended
- [ ] Edge cases are handled
- [ ] Error handling is implemented
- [ ] Business logic is correct

#### Code Quality
- [ ] Code is readable and well-structured
- [ ] Functions are small and focused
- [ ] Variable names are descriptive
- [ ] No code duplication

#### Security
- [ ] Input validation is implemented
- [ ] No hardcoded secrets
- [ ] SQL injection prevention
- [ ] XSS prevention measures

#### Performance
- [ ] No obvious performance bottlenecks
- [ ] Efficient algorithms used
- [ ] Memory usage is reasonable
- [ ] Database queries are optimized

#### Testing
- [ ] Unit tests cover critical paths
- [ ] Tests are meaningful and readable
- [ ] Edge cases are tested
- [ ] Test coverage is adequate

### Static Analysis Tools
- **SonarQube**: Comprehensive code quality analysis
- **CodeClimate**: Automated code review
- **ESLint**: JavaScript/TypeScript linting
- **Prettier**: Code formatting
- **Husky**: Git hooks for quality checks

### Analysis Report Template
```markdown
## Code Analysis Report

### Summary
- Files analyzed: X
- Issues found: Y
- Critical issues: Z

### Issues by Category
- Security: X issues
- Performance: Y issues
- Maintainability: Z issues
- Code smells: W issues

### Recommendations
1. Priority 1: Critical security fixes
2. Priority 2: Performance optimizations
3. Priority 3: Code structure improvements

### Detailed Findings
[Specific issues with file locations and recommendations]
```