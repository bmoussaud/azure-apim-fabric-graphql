"""
Tests for authentication mechanism
"""
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_health_endpoint_no_auth_required():
    """Health endpoint should work without authentication"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_root_endpoint_no_auth_required():
    """Root endpoint should work without authentication"""
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["name"] == "Orders REST API"


def test_list_orders_without_auth_header():
    """List orders should return 403 without auth header"""
    response = client.get("/orders")
    assert response.status_code == 403
    assert "Missing authentication header" in response.json()["detail"]


def test_list_orders_with_auth_header():
    """List orders should work with auth header"""
    response = client.get("/orders", headers={"X-Auth-Token": "any-value"})
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_get_order_without_auth_header():
    """Get order should return 403 without auth header"""
    response = client.get("/orders/ORD-2024-001")
    assert response.status_code == 403
    assert "Missing authentication header" in response.json()["detail"]


def test_get_order_with_auth_header():
    """Get order should work with auth header"""
    response = client.get("/orders/ORD-2024-001", headers={"X-Auth-Token": "test-token"})
    assert response.status_code == 200
    assert response.json()["order_id"] == "ORD-2024-001"


def test_create_order_without_auth_header():
    """Create order should return 403 without auth header"""
    order_data = {
        "customer_id": "CUST-999",
        "customer_name": "Test Customer",
        "customer_email": "test@example.com",
        "items": [
            {
                "product_id": "PROD-001",
                "product_name": "Test Product",
                "quantity": 1,
                "unit_price": 100.0,
                "total_price": 100.0
            }
        ],
        "shipping_address": "123 Test St"
    }
    response = client.post("/orders", json=order_data)
    assert response.status_code == 403
    assert "Missing authentication header" in response.json()["detail"]


def test_create_order_with_auth_header():
    """Create order should work with auth header"""
    order_data = {
        "customer_id": "CUST-999",
        "customer_name": "Test Customer",
        "customer_email": "test@example.com",
        "items": [
            {
                "product_id": "PROD-001",
                "product_name": "Test Product",
                "quantity": 1,
                "unit_price": 100.0,
                "total_price": 100.0
            }
        ],
        "shipping_address": "123 Test St"
    }
    response = client.post("/orders", json=order_data, headers={"X-Auth-Token": "test"})
    assert response.status_code == 201
    assert "order_id" in response.json()


def test_update_order_without_auth_header():
    """Update order should return 403 without auth header"""
    update_data = {"status": "processing"}
    response = client.put("/orders/ORD-2024-001", json=update_data)
    assert response.status_code == 403
    assert "Missing authentication header" in response.json()["detail"]


def test_update_order_with_auth_header():
    """Update order should work with auth header"""
    update_data = {"status": "processing"}
    response = client.put("/orders/ORD-2024-001", json=update_data, headers={"X-Auth-Token": "123"})
    assert response.status_code == 200
    assert response.json()["status"] == "processing"


def test_delete_order_without_auth_header():
    """Delete order should return 403 without auth header"""
    response = client.delete("/orders/ORD-2024-001")
    assert response.status_code == 403
    assert "Missing authentication header" in response.json()["detail"]


def test_delete_order_with_auth_header():
    """Delete order should work with auth header"""
    # First create an order to delete
    order_data = {
        "customer_id": "CUST-999",
        "customer_name": "Test Customer",
        "customer_email": "test@example.com",
        "items": [
            {
                "product_id": "PROD-001",
                "product_name": "Test Product",
                "quantity": 1,
                "unit_price": 100.0,
                "total_price": 100.0
            }
        ],
        "shipping_address": "123 Test St"
    }
    create_response = client.post("/orders", json=order_data, headers={"X-Auth-Token": "test"})
    order_id = create_response.json()["order_id"]
    
    # Now delete it
    response = client.delete(f"/orders/{order_id}", headers={"X-Auth-Token": "delete-token"})
    assert response.status_code == 204


def test_auth_header_with_empty_string():
    """Auth header with empty string should work (we don't care about value)"""
    response = client.get("/orders", headers={"X-Auth-Token": ""})
    assert response.status_code == 200


def test_auth_header_with_any_value():
    """Auth header with any value should work"""
    test_values = ["abc", "123", "Bearer token", "random-string", "!@#$%"]
    for value in test_values:
        response = client.get("/orders", headers={"X-Auth-Token": value})
        assert response.status_code == 200, f"Failed with value: {value}"
