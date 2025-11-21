"""
Data models for the Orders REST API
"""
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
from enum import Enum


class OrderStatus(str, Enum):
    """Order status enumeration"""
    PENDING = "pending"
    PROCESSING = "processing"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"


class OrderItem(BaseModel):
    """Order item model"""
    product_id: str = Field(..., description="Product identifier")
    product_name: str = Field(..., description="Product name")
    quantity: int = Field(..., ge=1, description="Quantity ordered")
    unit_price: float = Field(..., ge=0, description="Unit price")
    total_price: float = Field(..., ge=0, description="Total price for this item")


class Order(BaseModel):
    """Order model - complete order information"""
    order_id: str = Field(..., description="Unique order identifier")
    customer_id: str = Field(..., description="Customer identifier")
    customer_name: str = Field(..., description="Customer name")
    customer_email: str = Field(..., description="Customer email")
    order_date: datetime = Field(..., description="Order creation date")
    status: OrderStatus = Field(..., description="Current order status")
    items: List[OrderItem] = Field(..., description="List of ordered items")
    subtotal: float = Field(..., ge=0, description="Subtotal amount")
    tax: float = Field(..., ge=0, description="Tax amount")
    shipping_cost: float = Field(..., ge=0, description="Shipping cost")
    total_amount: float = Field(..., ge=0, description="Total order amount")
    shipping_address: str = Field(..., description="Shipping address")
    notes: Optional[str] = Field(None, description="Order notes")
    
    class Config:
        json_schema_extra = {
            "example": {
                "order_id": "ORD-2024-001",
                "customer_id": "CUST-12345",
                "customer_name": "John Doe",
                "customer_email": "john.doe@example.com",
                "order_date": "2024-01-15T10:30:00",
                "status": "pending",
                "items": [
                    {
                        "product_id": "PROD-001",
                        "product_name": "Laptop",
                        "quantity": 1,
                        "unit_price": 999.99,
                        "total_price": 999.99
                    }
                ],
                "subtotal": 999.99,
                "tax": 80.00,
                "shipping_cost": 20.00,
                "total_amount": 1099.99,
                "shipping_address": "123 Main St, City, State 12345",
                "notes": "Please handle with care"
            }
        }


class OrderCreate(BaseModel):
    """Order creation model - data needed to create a new order"""
    customer_id: str = Field(..., description="Customer identifier")
    customer_name: str = Field(..., description="Customer name")
    customer_email: str = Field(..., description="Customer email")
    items: List[OrderItem] = Field(..., description="List of ordered items")
    shipping_address: str = Field(..., description="Shipping address")
    notes: Optional[str] = Field(None, description="Order notes")


class OrderUpdate(BaseModel):
    """Order update model - data that can be updated"""
    status: Optional[OrderStatus] = Field(None, description="Order status")
    shipping_address: Optional[str] = Field(None, description="Shipping address")
    notes: Optional[str] = Field(None, description="Order notes")
