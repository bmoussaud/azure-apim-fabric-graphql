"""
Fake data generator and in-memory storage for orders
"""
from typing import List, Optional
from datetime import datetime, timedelta
import random
from models import Order, OrderItem, OrderStatus, OrderCreate, OrderUpdate

# In-memory storage for orders
_orders: List[Order] = []


def _generate_fake_orders() -> List[Order]:
    """Generate fake orders for testing"""
    
    # Sample products
    products = [
        {"id": "PROD-001", "name": "Laptop", "price": 999.99},
        {"id": "PROD-002", "name": "Wireless Mouse", "price": 29.99},
        {"id": "PROD-003", "name": "USB-C Cable", "price": 19.99},
        {"id": "PROD-004", "name": "Monitor", "price": 349.99},
        {"id": "PROD-005", "name": "Keyboard", "price": 79.99},
        {"id": "PROD-006", "name": "Headphones", "price": 149.99},
        {"id": "PROD-007", "name": "Webcam", "price": 89.99},
        {"id": "PROD-008", "name": "Desk Lamp", "price": 39.99},
        {"id": "PROD-009", "name": "Phone Stand", "price": 24.99},
        {"id": "PROD-010", "name": "External SSD", "price": 199.99},
    ]
    
    # Sample customers
    customers = [
        {"id": "CUST-001", "name": "Alice Johnson", "email": "alice.johnson@example.com"},
        {"id": "CUST-002", "name": "Bob Smith", "email": "bob.smith@example.com"},
        {"id": "CUST-003", "name": "Carol White", "email": "carol.white@example.com"},
        {"id": "CUST-004", "name": "David Brown", "email": "david.brown@example.com"},
        {"id": "CUST-005", "name": "Eve Davis", "email": "eve.davis@example.com"},
        {"id": "CUST-006", "name": "Frank Miller", "email": "frank.miller@example.com"},
        {"id": "CUST-007", "name": "Grace Wilson", "email": "grace.wilson@example.com"},
        {"id": "CUST-008", "name": "Henry Moore", "email": "henry.moore@example.com"},
        {"id": "CUST-009", "name": "Ivy Taylor", "email": "ivy.taylor@example.com"},
        {"id": "CUST-010", "name": "Jack Anderson", "email": "jack.anderson@example.com"},
    ]
    
    # Sample addresses
    addresses = [
        "123 Main St, New York, NY 10001",
        "456 Oak Ave, Los Angeles, CA 90001",
        "789 Pine Rd, Chicago, IL 60601",
        "321 Elm St, Houston, TX 77001",
        "654 Maple Dr, Phoenix, AZ 85001",
        "987 Cedar Ln, Philadelphia, PA 19019",
        "147 Birch Blvd, San Antonio, TX 78201",
        "258 Walnut Way, San Diego, CA 92101",
        "369 Spruce St, Dallas, TX 75201",
        "741 Ash Ave, San Jose, CA 95101",
    ]
    
    # Sample notes
    notes_options = [
        "Please handle with care",
        "Gift wrap requested",
        "Leave at doorstep",
        "Signature required",
        "Call before delivery",
        None,
        None,
        None,
    ]
    
    orders = []
    base_date = datetime.utcnow() - timedelta(days=30)
    
    # Generate 20 fake orders
    for i in range(1, 21):
        customer = random.choice(customers)
        num_items = random.randint(1, 4)
        selected_products = random.sample(products, num_items)
        
        # Generate order items
        items = []
        subtotal = 0
        for product in selected_products:
            quantity = random.randint(1, 3)
            unit_price = product["price"]
            total_price = quantity * unit_price
            subtotal += total_price
            
            items.append(OrderItem(
                product_id=product["id"],
                product_name=product["name"],
                quantity=quantity,
                unit_price=unit_price,
                total_price=total_price
            ))
        
        # Calculate totals
        tax = round(subtotal * 0.08, 2)  # 8% tax
        shipping_cost = 15.00 if subtotal < 100 else 0.00  # Free shipping over $100
        total_amount = subtotal + tax + shipping_cost
        
        # Random order date within the last 30 days
        order_date = base_date + timedelta(days=i-1, hours=random.randint(0, 23))
        
        # Determine status based on order age
        days_old = (datetime.utcnow() - order_date).days
        if days_old > 20:
            status = random.choice([OrderStatus.DELIVERED, OrderStatus.DELIVERED, OrderStatus.CANCELLED])
        elif days_old > 10:
            status = random.choice([OrderStatus.SHIPPED, OrderStatus.DELIVERED])
        elif days_old > 5:
            status = random.choice([OrderStatus.PROCESSING, OrderStatus.SHIPPED])
        else:
            status = random.choice([OrderStatus.PENDING, OrderStatus.PROCESSING])
        
        order = Order(
            order_id=f"ORD-2024-{i:03d}",
            customer_id=customer["id"],
            customer_name=customer["name"],
            customer_email=customer["email"],
            order_date=order_date,
            status=status,
            items=items,
            subtotal=round(subtotal, 2),
            tax=tax,
            shipping_cost=shipping_cost,
            total_amount=round(total_amount, 2),
            shipping_address=random.choice(addresses),
            notes=random.choice(notes_options)
        )
        orders.append(order)
    
    return orders


def get_orders() -> List[Order]:
    """Get all orders"""
    global _orders
    if not _orders:
        _orders = _generate_fake_orders()
    return _orders


def get_order_by_id(order_id: str) -> Optional[Order]:
    """Get order by ID"""
    orders = get_orders()
    for order in orders:
        if order.order_id == order_id:
            return order
    return None


def create_order(order_data: OrderCreate) -> Order:
    """Create a new order"""
    orders = get_orders()
    
    # Generate new order ID
    order_count = len(orders) + 1
    order_id = f"ORD-2024-{order_count:03d}"
    
    # Calculate totals
    subtotal = sum(item.total_price for item in order_data.items)
    tax = round(subtotal * 0.08, 2)
    shipping_cost = 15.00 if subtotal < 100 else 0.00
    total_amount = subtotal + tax + shipping_cost
    
    # Create new order
    new_order = Order(
        order_id=order_id,
        customer_id=order_data.customer_id,
        customer_name=order_data.customer_name,
        customer_email=order_data.customer_email,
        order_date=datetime.utcnow(),
        status=OrderStatus.PENDING,
        items=order_data.items,
        subtotal=round(subtotal, 2),
        tax=tax,
        shipping_cost=shipping_cost,
        total_amount=round(total_amount, 2),
        shipping_address=order_data.shipping_address,
        notes=order_data.notes
    )
    
    _orders.append(new_order)
    return new_order


def update_order(order_id: str, order_data: OrderUpdate) -> Optional[Order]:
    """Update an existing order"""
    orders = get_orders()
    
    for i, order in enumerate(orders):
        if order.order_id == order_id:
            # Update only provided fields
            update_dict = order_data.model_dump(exclude_unset=True)
            updated_order = order.model_copy(update=update_dict)
            _orders[i] = updated_order
            return updated_order
    
    return None


def delete_order(order_id: str) -> bool:
    """Delete an order"""
    global _orders
    orders = get_orders()
    
    for i, order in enumerate(orders):
        if order.order_id == order_id:
            _orders.pop(i)
            return True
    
    return False
