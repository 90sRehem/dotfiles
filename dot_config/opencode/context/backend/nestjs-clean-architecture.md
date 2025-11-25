# NestJS Clean Architecture - Bounded Contexts Pattern

**IMPLEMENTAR** bounded contexts com Clean Architecture seguindo padrões do EasyList:

## **BOUNDED CONTEXT STRUCTURE** - Organização por domínios:

```
src/
├── shared/                     # Código compartilhado
│   ├── core/                   # Core abstrações
│   │   ├── either.ts           # Either pattern para errors
│   │   ├── unique-entity-id.ts # Identificadores únicos
│   │   ├── aggregate-root.ts   # Base para aggregate roots
│   │   ├── entity.ts           # Base entity class
│   │   ├── value-object.ts     # Base value object
│   │   └── domain-event.ts     # Sistema de eventos
│   ├── errors/                 # Errors compartilhados
│   └── utils/                  # Utilitários
├── contexts/                   # Bounded contexts
│   ├── user-management/        # Context: Gestão de usuários
│   │   ├── domain/             # Regras de negócio puras
│   │   │   ├── entities/       # User aggregate
│   │   │   ├── value-objects/  # Email, Password, etc
│   │   │   ├── use-cases/      # Business operations
│   │   │   ├── repositories/   # Data access interfaces
│   │   │   ├── events/         # Domain events
│   │   │   └── errors/         # Domain errors
│   │   └── infra/              # Infraestrutura (NestJS)
│   │       ├── http/           # Controllers, DTOs, presenters
│   │       ├── database/       # Repository implementations
│   │       ├── services/       # Application services (adapters)
│   │       └── user.module.ts  # NestJS module
│   ├── authentication/         # Context: Autenticação
│   ├── product-catalog/        # Context: Catálogo de produtos
│   └── order-management/       # Context: Gestão de pedidos
```

## **DOMAIN ENTITY PATTERN** - Entidades não anêmicas:

```typescript
// shared/core/entity.ts
export abstract class Entity<T> {
  protected readonly _id: UniqueEntityID;
  protected props: T;

  constructor(props: T, id?: UniqueEntityID) {
    this._id = id ?? new UniqueEntityID();
    this.props = props;
  }

  get id(): UniqueEntityID {
    return this._id;
  }

  public equals(object?: Entity<T>): boolean {
    if (object == null || object == undefined) {
      return false;
    }

    if (this === object) {
      return true;
    }

    if (!(object instanceof Entity)) {
      return false;
    }

    return this._id.equals(object._id);
  }
}

// contexts/user-management/domain/entities/user.entity.ts
interface UserProps {
  name: string;
  email: Email;
  password: Password;
  role: UserRole;
  isActive: boolean;
  createdAt: Date;
  updatedAt?: Date;
}

export class User extends Entity<UserProps> {
  private constructor(props: UserProps, id?: UniqueEntityID) {
    super(props, id);
  }

  // Factory method - controla criação
  static create(props: CreateUserProps, id?: UniqueEntityID): Either<UserError, User> {
    const emailOrError = Email.create(props.email);
    if (emailOrError.isLeft()) {
      return left(emailOrError.value);
    }

    const passwordOrError = Password.create(props.password);
    if (passwordOrError.isLeft()) {
      return left(passwordOrError.value);
    }

    const userProps: UserProps = {
      name: props.name,
      email: emailOrError.value,
      password: passwordOrError.value,
      role: props.role ?? UserRole.USER,
      isActive: true,
      createdAt: new Date(),
    };

    const user = new User(userProps, id);
    
    // Domain event
    if (!id) {
      user.addDomainEvent(new UserCreatedEvent(user));
    }

    return right(user);
  }

  // Business methods - encapsulam regras de negócio
  changeEmail(newEmail: Email): Either<UserError, void> {
    if (this.props.email.equals(newEmail)) {
      return left(new EmailAlreadyInUseError());
    }

    const oldEmail = this.props.email;
    this.props.email = newEmail;
    this.props.updatedAt = new Date();

    this.addDomainEvent(new UserEmailChangedEvent(this, oldEmail, newEmail));
    
    return right(void 0);
  }

  activate(): Either<UserError, void> {
    if (this.props.isActive) {
      return left(new UserAlreadyActiveError());
    }

    this.props.isActive = true;
    this.props.updatedAt = new Date();
    
    this.addDomainEvent(new UserActivatedEvent(this));
    
    return right(void 0);
  }

  deactivate(): Either<UserError, void> {
    if (!this.props.isActive) {
      return left(new UserAlreadyInactiveError());
    }

    this.props.isActive = false;
    this.props.updatedAt = new Date();
    
    this.addDomainEvent(new UserDeactivatedEvent(this));
    
    return right(void 0);
  }

  changePassword(newPassword: Password): Either<UserError, void> {
    this.props.password = newPassword;
    this.props.updatedAt = new Date();
    
    this.addDomainEvent(new UserPasswordChangedEvent(this));
    
    return right(void 0);
  }

  // Getters - acesso controlado às propriedades
  get name(): string { return this.props.name; }
  get email(): Email { return this.props.email; }
  get role(): UserRole { return this.props.role; }
  get isActive(): boolean { return this.props.isActive; }
  get createdAt(): Date { return this.props.createdAt; }
  get updatedAt(): Date | undefined { return this.props.updatedAt; }
}
```

## **VALUE OBJECTS PATTERN** - Para conceitos sem identidade:

```typescript
// contexts/user-management/domain/value-objects/email.ts
export class Email extends ValueObject<{ value: string }> {
  private constructor(props: { value: string }) {
    super(props);
  }

  static create(email: string): Either<InvalidEmailError, Email> {
    if (!this.isValidEmail(email)) {
      return left(new InvalidEmailError(email));
    }

    return right(new Email({ value: email.toLowerCase().trim() }));
  }

  private static isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email) && email.length <= 255;
  }

  get value(): string {
    return this.props.value;
  }
}

// contexts/user-management/domain/value-objects/password.ts
export class Password extends ValueObject<{ hash: string }> {
  private constructor(props: { hash: string }) {
    super(props);
  }

  static async create(password: string): Promise<Either<InvalidPasswordError, Password>> {
    if (!this.isValidPassword(password)) {
      return left(new InvalidPasswordError());
    }

    const hash = await bcrypt.hash(password, 12);
    return right(new Password({ hash }));
  }

  static createFromHash(hash: string): Password {
    return new Password({ hash });
  }

  private static isValidPassword(password: string): boolean {
    // Pelo menos 8 caracteres, 1 maiúscula, 1 minúscula, 1 número
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$/;
    return passwordRegex.test(password);
  }

  async compare(plainPassword: string): Promise<boolean> {
    return bcrypt.compare(plainPassword, this.props.hash);
  }

  get hash(): string {
    return this.props.hash;
  }
}
```

## **USE CASE PATTERN** - Business logic isolada:

```typescript
// contexts/user-management/domain/use-cases/create-user.use-case.ts
export interface CreateUserRequest {
  name: string;
  email: string;
  password: string;
  role?: UserRole;
}

export interface CreateUserResponse {
  user: UserPresenterData;
}

@Injectable()
export class CreateUserUseCase {
  constructor(
    private userRepository: UserRepository,
    private emailValidator: EmailValidator,
    private eventPublisher: DomainEventPublisher,
  ) {}

  async execute(request: CreateUserRequest): Promise<Either<UserError, CreateUserResponse>> {
    // Validate email uniqueness
    const emailExists = await this.userRepository.findByEmail(request.email);
    if (emailExists) {
      return left(new EmailAlreadyExistsError(request.email));
    }

    // Create user entity
    const userOrError = User.create({
      name: request.name,
      email: request.email,
      password: request.password,
      role: request.role,
    });

    if (userOrError.isLeft()) {
      return left(userOrError.value);
    }

    const user = userOrError.value;

    // Persist user
    await this.userRepository.save(user);

    // Publish domain events
    await this.eventPublisher.publishEvents(user.getUncommittedEvents());
    user.markEventsAsCommitted();

    return right({
      user: UserPresenter.toHTTP(user),
    });
  }
}

// contexts/user-management/domain/use-cases/authenticate-user.use-case.ts
export interface AuthenticateUserRequest {
  email: string;
  password: string;
}

export interface AuthenticateUserResponse {
  accessToken: string;
  refreshToken: string;
  user: UserPresenterData;
}

@Injectable()
export class AuthenticateUserUseCase {
  constructor(
    private userRepository: UserRepository,
    private hashComparer: HashComparer,
    private tokenGenerator: TokenGenerator,
  ) {}

  async execute(request: AuthenticateUserRequest): Promise<Either<AuthenticationError, AuthenticateUserResponse>> {
    // Find user by email
    const user = await this.userRepository.findByEmail(request.email);
    if (!user) {
      return left(new InvalidCredentialsError());
    }

    // Check if user is active
    if (!user.isActive) {
      return left(new UserInactiveError());
    }

    // Verify password
    const isPasswordValid = await user.password.compare(request.password);
    if (!isPasswordValid) {
      return left(new InvalidCredentialsError());
    }

    // Generate tokens
    const accessToken = await this.tokenGenerator.generateAccessToken(user.id.toString());
    const refreshToken = await this.tokenGenerator.generateRefreshToken(user.id.toString());

    return right({
      accessToken,
      refreshToken,
      user: UserPresenter.toHTTP(user),
    });
  }
}
```

## **REPOSITORY PATTERN** - Abstração para persistência:

```typescript
// contexts/user-management/domain/repositories/user.repository.ts
export interface UserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  findMany(params: FindManyUsersParams): Promise<User[]>;
  save(user: User): Promise<void>;
  delete(id: string): Promise<void>;
  exists(id: string): Promise<boolean>;
}

// contexts/user-management/infra/database/prisma-user.repository.ts
@Injectable()
export class PrismaUserRepository implements UserRepository {
  constructor(private prisma: PrismaService) {}

  async findById(id: string): Promise<User | null> {
    const userData = await this.prisma.user.findUnique({
      where: { id },
    });

    if (!userData) return null;

    return UserMapper.toDomain(userData);
  }

  async findByEmail(email: string): Promise<User | null> {
    const userData = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!userData) return null;

    return UserMapper.toDomain(userData);
  }

  async save(user: User): Promise<void> {
    const persistenceData = UserMapper.toPersistence(user);

    await this.prisma.user.upsert({
      where: { id: persistenceData.id },
      create: persistenceData,
      update: persistenceData,
    });
  }

  async delete(id: string): Promise<void> {
    await this.prisma.user.delete({
      where: { id },
    });
  }
}
```

## **CONTROLLER PATTERN** - HTTP adapter:

```typescript
// contexts/user-management/infra/http/create-user.controller.ts
@Controller('users')
@ApiTags('Users')
export class CreateUserController {
  constructor(private createUserService: CreateUserService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new user' })
  @ApiResponse({ status: 201, description: 'User created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 409, description: 'Email already exists' })
  async handle(@Body() body: CreateUserDto): Promise<CreateUserPresenter> {
    const result = await this.createUserService.execute(body);

    if (result.isLeft()) {
      const error = result.value;
      
      switch (error.constructor) {
        case EmailAlreadyExistsError:
          throw new ConflictException(error.message);
        case InvalidEmailError:
        case InvalidPasswordError:
          throw new BadRequestException(error.message);
        default:
          throw new InternalServerErrorException('Internal server error');
      }
    }

    return CreateUserPresenter.toHTTP(result.value);
  }
}

// contexts/user-management/infra/http/dtos/create-user.dto.ts
export class CreateUserDto {
  @ApiProperty({ example: 'John Doe' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(100)
  name: string;

  @ApiProperty({ example: 'john@example.com' })
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @ApiProperty({ example: 'StrongPass123!' })
  @IsString()
  @MinLength(8)
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$/, {
    message: 'Password must contain at least 8 characters, 1 uppercase, 1 lowercase and 1 number'
  })
  password: string;

  @ApiProperty({ enum: UserRole, required: false })
  @IsEnum(UserRole)
  @IsOptional()
  role?: UserRole;
}
```

## **SERVICE ADAPTER PATTERN** - Adaptador para use cases:

```typescript
// contexts/user-management/infra/services/create-user.service.ts
@Injectable()
export class CreateUserService {
  constructor(private createUserUseCase: CreateUserUseCase) {}

  async execute(request: CreateUserRequest): Promise<Either<UserError, CreateUserResponse>> {
    return this.createUserUseCase.execute(request);
  }
}
```

## **MODULE CONFIGURATION** - Dependency injection:

```typescript
// contexts/user-management/infra/user.module.ts
@Module({
  imports: [
    PrismaModule,
    JwtModule.register({
      secret: process.env.JWT_SECRET,
      signOptions: { expiresIn: '15m' },
    }),
  ],
  controllers: [
    CreateUserController,
    AuthenticateUserController,
    GetUserController,
    UpdateUserController,
    DeleteUserController,
  ],
  providers: [
    // Use Cases
    CreateUserUseCase,
    AuthenticateUserUseCase,
    UpdateUserUseCase,
    DeleteUserUseCase,

    // Services (Adapters)
    CreateUserService,
    AuthenticateUserService,
    UpdateUserService,
    DeleteUserService,

    // Repositories
    {
      provide: 'UserRepository',
      useClass: PrismaUserRepository,
    },

    // Infrastructure services
    {
      provide: 'TokenGenerator',
      useClass: JwtTokenGenerator,
    },
    {
      provide: 'HashComparer',
      useClass: BcryptHashComparer,
    },
  ],
  exports: ['UserRepository'],
})
export class UserModule {}
```

**REGRAS IMPORTANTES**:

- **SEPARE** domain de infrastructure rigorosamente
- **USE** Either pattern para error handling consistente
- **IMPLEMENTE** entities não anêmicas com business logic
- **CRIE** value objects para conceitos importantes
- **ISOLE** use cases com uma responsabilidade cada
- **ABSTRAIA** persistência com repository pattern
- **ADAPTE** use cases com services no nível de infra
- **CONFIGURE** dependency injection no módulo
- **PUBLIQUE** domain events para comunicação entre contexts
- **VALIDE** inputs nos DTOs e no domínio