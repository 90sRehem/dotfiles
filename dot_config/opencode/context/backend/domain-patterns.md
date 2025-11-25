# Domain Patterns - Use Cases e Entities Robustas

**IMPLEMENTAR** domain layer com entities não anêmicas e use cases focados:

## **SHARED CORE PATTERNS** - Infraestrutura do domínio:

```typescript
// shared/core/either.ts
export class Left<L, A> {
  readonly value: L;
  
  constructor(value: L) {
    this.value = value;
  }
  
  isLeft(): this is Left<L, A> {
    return true;
  }
  
  isRight(): this is Right<L, A> {
    return false;
  }
}

export class Right<L, A> {
  readonly value: A;
  
  constructor(value: A) {
    this.value = value;
  }
  
  isLeft(): this is Left<L, A> {
    return false;
  }
  
  isRight(): this is Right<L, A> {
    return true;
  }
}

export type Either<L, A> = Left<L, A> | Right<L, A>;

export const left = <L, A>(l: L): Either<L, A> => {
  return new Left(l);
};

export const right = <L, A>(a: A): Either<L, A> => {
  return new Right(a);
};

// shared/core/unique-entity-id.ts
import { randomUUID } from 'crypto';

export class UniqueEntityID {
  private value: string;

  constructor(value?: string) {
    this.value = value ?? randomUUID();
  }

  equals(id?: UniqueEntityID): boolean {
    if (id === null || id === undefined) {
      return false;
    }

    if (!(id instanceof this.constructor)) {
      return false;
    }

    return id.toValue() === this.value;
  }

  toString() {
    return String(this.value);
  }

  toValue(): string {
    return this.value;
  }
}

// shared/core/entity.ts
export abstract class Entity<T> {
  protected readonly _id: UniqueEntityID;
  protected props: T;
  private _domainEvents: DomainEvent[] = [];

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

  protected addDomainEvent(domainEvent: DomainEvent): void {
    this._domainEvents.push(domainEvent);
  }

  public getUncommittedEvents(): DomainEvent[] {
    return this._domainEvents;
  }

  public markEventsAsCommitted(): void {
    this._domainEvents = [];
  }
}

// shared/core/aggregate-root.ts
export abstract class AggregateRoot<T> extends Entity<T> {
  // Aggregate roots podem ter behavior específico
  // como validation rules complexas ou invariants
}

// shared/core/value-object.ts
interface ValueObjectProps {
  [index: string]: any;
}

export abstract class ValueObject<T extends ValueObjectProps> {
  protected props: T;

  constructor(props: T) {
    this.props = Object.freeze(props);
  }

  public equals(vo?: ValueObject<T>): boolean {
    if (vo === null || vo === undefined) {
      return false;
    }

    if (vo.props === undefined) {
      return false;
    }

    return JSON.stringify(this.props) === JSON.stringify(vo.props);
  }
}
```

## **DOMAIN EVENT PATTERN** - Para comunicação entre contexts:

```typescript
// shared/core/domain-event.ts
export interface DomainEvent {
  occurredAt: Date;
  eventType: string;
  aggregateId: string;
}

export abstract class BaseDomainEvent implements DomainEvent {
  public occurredAt: Date;
  public eventType: string;
  public aggregateId: string;

  constructor(aggregateId: string, eventType: string) {
    this.aggregateId = aggregateId;
    this.eventType = eventType;
    this.occurredAt = new Date();
  }
}

// contexts/user-management/domain/events/user-created.event.ts
export class UserCreatedEvent extends BaseDomainEvent {
  constructor(
    public readonly user: User,
  ) {
    super(user.id.toString(), 'user.created');
  }
}

// contexts/user-management/domain/events/user-email-changed.event.ts
export class UserEmailChangedEvent extends BaseDomainEvent {
  constructor(
    public readonly user: User,
    public readonly oldEmail: Email,
    public readonly newEmail: Email,
  ) {
    super(user.id.toString(), 'user.email_changed');
  }
}

// shared/infra/domain-event-publisher.ts
@Injectable()
export class DomainEventPublisher {
  constructor(private eventBus: EventBus) {}

  async publishEvents(events: DomainEvent[]): Promise<void> {
    for (const event of events) {
      await this.eventBus.publish(event);
    }
  }
}
```

## **COMPLEX ENTITY PATTERN** - Entities com business logic:

```typescript
// contexts/order-management/domain/entities/order.entity.ts
interface OrderProps {
  customerId: UniqueEntityID;
  items: OrderItem[];
  status: OrderStatus;
  totalAmount: Money;
  shippingAddress: Address;
  billingAddress: Address;
  paymentMethod?: PaymentMethod;
  notes?: string;
  createdAt: Date;
  updatedAt?: Date;
  completedAt?: Date;
}

export class Order extends AggregateRoot<OrderProps> {
  private constructor(props: OrderProps, id?: UniqueEntityID) {
    super(props, id);
  }

  static create(props: CreateOrderProps, id?: UniqueEntityID): Either<OrderError, Order> {
    // Validation
    if (!props.items || props.items.length === 0) {
      return left(new EmptyOrderError());
    }

    // Calculate total amount
    const totalAmount = this.calculateTotalAmount(props.items);

    const orderProps: OrderProps = {
      customerId: props.customerId,
      items: props.items,
      status: OrderStatus.PENDING,
      totalAmount,
      shippingAddress: props.shippingAddress,
      billingAddress: props.billingAddress || props.shippingAddress,
      notes: props.notes,
      createdAt: new Date(),
    };

    const order = new Order(orderProps, id);

    // Domain event
    if (!id) {
      order.addDomainEvent(new OrderCreatedEvent(order));
    }

    return right(order);
  }

  // Business logic methods
  addItem(item: OrderItem): Either<OrderError, void> {
    if (this.props.status !== OrderStatus.PENDING) {
      return left(new OrderNotEditableError());
    }

    // Check if item already exists
    const existingItemIndex = this.props.items.findIndex(
      existingItem => existingItem.productId.equals(item.productId)
    );

    if (existingItemIndex >= 0) {
      // Update quantity
      this.props.items[existingItemIndex] = this.props.items[existingItemIndex].increaseQuantity(item.quantity);
    } else {
      // Add new item
      this.props.items.push(item);
    }

    // Recalculate total
    this.props.totalAmount = Order.calculateTotalAmount(this.props.items);
    this.props.updatedAt = new Date();

    this.addDomainEvent(new OrderItemAddedEvent(this, item));

    return right(void 0);
  }

  removeItem(productId: UniqueEntityID): Either<OrderError, void> {
    if (this.props.status !== OrderStatus.PENDING) {
      return left(new OrderNotEditableError());
    }

    const itemIndex = this.props.items.findIndex(
      item => item.productId.equals(productId)
    );

    if (itemIndex === -1) {
      return left(new ItemNotFoundInOrderError());
    }

    const removedItem = this.props.items[itemIndex];
    this.props.items.splice(itemIndex, 1);

    // Recalculate total
    this.props.totalAmount = Order.calculateTotalAmount(this.props.items);
    this.props.updatedAt = new Date();

    this.addDomainEvent(new OrderItemRemovedEvent(this, removedItem));

    return right(void 0);
  }

  confirm(): Either<OrderError, void> {
    if (this.props.status !== OrderStatus.PENDING) {
      return left(new OrderAlreadyConfirmedError());
    }

    if (this.props.items.length === 0) {
      return left(new EmptyOrderError());
    }

    this.props.status = OrderStatus.CONFIRMED;
    this.props.updatedAt = new Date();

    this.addDomainEvent(new OrderConfirmedEvent(this));

    return right(void 0);
  }

  ship(trackingNumber: string): Either<OrderError, void> {
    if (this.props.status !== OrderStatus.CONFIRMED) {
      return left(new OrderNotConfirmedError());
    }

    this.props.status = OrderStatus.SHIPPED;
    this.props.updatedAt = new Date();

    this.addDomainEvent(new OrderShippedEvent(this, trackingNumber));

    return right(void 0);
  }

  complete(): Either<OrderError, void> {
    if (this.props.status !== OrderStatus.SHIPPED) {
      return left(new OrderNotShippedError());
    }

    this.props.status = OrderStatus.COMPLETED;
    this.props.completedAt = new Date();
    this.props.updatedAt = new Date();

    this.addDomainEvent(new OrderCompletedEvent(this));

    return right(void 0);
  }

  cancel(reason: string): Either<OrderError, void> {
    if (this.props.status === OrderStatus.COMPLETED) {
      return left(new OrderAlreadyCompletedError());
    }

    this.props.status = OrderStatus.CANCELLED;
    this.props.updatedAt = new Date();

    this.addDomainEvent(new OrderCancelledEvent(this, reason));

    return right(void 0);
  }

  // Helper methods
  private static calculateTotalAmount(items: OrderItem[]): Money {
    const total = items.reduce((sum, item) => {
      return sum + (item.unitPrice.amount * item.quantity);
    }, 0);

    return Money.create(total, 'BRL').value as Money;
  }

  // Getters
  get customerId(): UniqueEntityID { return this.props.customerId; }
  get items(): OrderItem[] { return [...this.props.items]; }
  get status(): OrderStatus { return this.props.status; }
  get totalAmount(): Money { return this.props.totalAmount; }
  get shippingAddress(): Address { return this.props.shippingAddress; }
  get billingAddress(): Address { return this.props.billingAddress; }
  get itemCount(): number { return this.props.items.length; }
  get isEditable(): boolean { return this.props.status === OrderStatus.PENDING; }
  get createdAt(): Date { return this.props.createdAt; }
  get updatedAt(): Date | undefined { return this.props.updatedAt; }
  get completedAt(): Date | undefined { return this.props.completedAt; }
}
```

## **USE CASE ORCHESTRATION PATTERN** - Para operações complexas:

```typescript
// contexts/order-management/domain/use-cases/process-order.use-case.ts
export interface ProcessOrderRequest {
  customerId: string;
  items: {
    productId: string;
    quantity: number;
  }[];
  shippingAddress: AddressProps;
  billingAddress?: AddressProps;
  paymentMethodId: string;
  notes?: string;
}

export interface ProcessOrderResponse {
  orderId: string;
  totalAmount: number;
  estimatedDelivery: Date;
}

@Injectable()
export class ProcessOrderUseCase {
  constructor(
    private orderRepository: OrderRepository,
    private productRepository: ProductRepository,
    private customerRepository: CustomerRepository,
    private paymentService: PaymentService,
    private inventoryService: InventoryService,
    private eventPublisher: DomainEventPublisher,
  ) {}

  async execute(request: ProcessOrderRequest): Promise<Either<OrderError, ProcessOrderResponse>> {
    // 1. Validate customer
    const customer = await this.customerRepository.findById(request.customerId);
    if (!customer) {
      return left(new CustomerNotFoundError());
    }

    // 2. Validate products and build order items
    const orderItemsResult = await this.buildOrderItems(request.items);
    if (orderItemsResult.isLeft()) {
      return left(orderItemsResult.value);
    }

    // 3. Check inventory availability
    const inventoryCheck = await this.inventoryService.checkAvailability(request.items);
    if (!inventoryCheck.isAvailable) {
      return left(new InsufficientInventoryError(inventoryCheck.unavailableItems));
    }

    // 4. Create addresses
    const shippingAddressResult = Address.create(request.shippingAddress);
    if (shippingAddressResult.isLeft()) {
      return left(shippingAddressResult.value);
    }

    const billingAddressResult = request.billingAddress 
      ? Address.create(request.billingAddress)
      : right(shippingAddressResult.value);
    
    if (billingAddressResult.isLeft()) {
      return left(billingAddressResult.value);
    }

    // 5. Create order
    const orderResult = Order.create({
      customerId: new UniqueEntityID(request.customerId),
      items: orderItemsResult.value,
      shippingAddress: shippingAddressResult.value,
      billingAddress: billingAddressResult.value,
      notes: request.notes,
    });

    if (orderResult.isLeft()) {
      return left(orderResult.value);
    }

    const order = orderResult.value;

    // 6. Reserve inventory
    const reservationResult = await this.inventoryService.reserve(
      order.id.toString(),
      request.items
    );

    if (reservationResult.isLeft()) {
      return left(reservationResult.value);
    }

    // 7. Process payment
    const paymentResult = await this.paymentService.processPayment({
      orderId: order.id.toString(),
      amount: order.totalAmount.amount,
      currency: order.totalAmount.currency,
      paymentMethodId: request.paymentMethodId,
      customerId: request.customerId,
    });

    if (paymentResult.isLeft()) {
      // Rollback inventory reservation
      await this.inventoryService.releaseReservation(order.id.toString());
      return left(paymentResult.value);
    }

    // 8. Confirm order
    const confirmResult = order.confirm();
    if (confirmResult.isLeft()) {
      return left(confirmResult.value);
    }

    // 9. Save order
    await this.orderRepository.save(order);

    // 10. Publish domain events
    await this.eventPublisher.publishEvents(order.getUncommittedEvents());
    order.markEventsAsCommitted();

    // 11. Calculate estimated delivery
    const estimatedDelivery = await this.calculateEstimatedDelivery(
      order.shippingAddress,
      order.items
    );

    return right({
      orderId: order.id.toString(),
      totalAmount: order.totalAmount.amount,
      estimatedDelivery,
    });
  }

  private async buildOrderItems(
    items: { productId: string; quantity: number }[]
  ): Promise<Either<OrderError, OrderItem[]>> {
    const orderItems: OrderItem[] = [];

    for (const item of items) {
      const product = await this.productRepository.findById(item.productId);
      if (!product) {
        return left(new ProductNotFoundError(item.productId));
      }

      if (!product.isAvailable) {
        return left(new ProductNotAvailableError(item.productId));
      }

      const orderItemResult = OrderItem.create({
        productId: new UniqueEntityID(item.productId),
        productName: product.name,
        quantity: item.quantity,
        unitPrice: product.price,
      });

      if (orderItemResult.isLeft()) {
        return left(orderItemResult.value);
      }

      orderItems.push(orderItemResult.value);
    }

    return right(orderItems);
  }

  private async calculateEstimatedDelivery(
    address: Address,
    items: OrderItem[]
  ): Promise<Date> {
    // Business logic for delivery estimation
    const baseDeliveryDays = 3;
    const heavyItemDays = items.some(item => item.isHeavy) ? 2 : 0;
    const remoteAreaDays = address.isRemoteArea ? 3 : 0;
    
    const totalDays = baseDeliveryDays + heavyItemDays + remoteAreaDays;
    
    const estimatedDate = new Date();
    estimatedDate.setDate(estimatedDate.getDate() + totalDays);
    
    return estimatedDate;
  }
}
```

## **DOMAIN SERVICE PATTERN** - Para lógica que não pertence a uma entity:

```typescript
// contexts/user-management/domain/services/user-authorization.service.ts
@Injectable()
export class UserAuthorizationService {
  canAccessResource(user: User, resource: Resource, action: Action): boolean {
    // Complex authorization logic
    if (user.role === UserRole.ADMIN) {
      return true;
    }

    if (user.role === UserRole.MANAGER) {
      return this.managerCanAccess(user, resource, action);
    }

    if (user.role === UserRole.USER) {
      return this.userCanAccess(user, resource, action);
    }

    return false;
  }

  private managerCanAccess(user: User, resource: Resource, action: Action): boolean {
    // Manager-specific rules
    if (action === Action.DELETE && resource.type === ResourceType.USER) {
      return false; // Managers can't delete users
    }

    return resource.organizationId === user.organizationId;
  }

  private userCanAccess(user: User, resource: Resource, action: Action): boolean {
    // User-specific rules
    if (action === Action.READ) {
      return resource.ownerId === user.id.toString() || resource.isPublic;
    }

    if (action === Action.WRITE) {
      return resource.ownerId === user.id.toString();
    }

    return false;
  }
}
```

**REGRAS IMPORTANTES**:

- **ENTITIES** devem ter business logic, não apenas getters/setters
- **USE CASES** devem ter uma responsabilidade clara e bem definida
- **VALUE OBJECTS** devem ser imutáveis e validar invariants
- **DOMAIN EVENTS** devem comunicar mudanças importantes de estado
- **REPOSITORIES** devem abstrair completamente a persistência
- **DOMAIN SERVICES** devem conter lógica que não pertence a uma entity específica
- **ERROR HANDLING** deve usar Either pattern consistentemente
- **AGGREGATE ROOTS** devem manter consistência dos seus invariants
- **FACTORY METHODS** devem validar e construir objetos complexos
- **DOMAIN LAYER** não deve ter dependências de infraestrutura