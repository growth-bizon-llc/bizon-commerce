# Bizon Commerce API Documentation

> **Base URL:** `https://your-domain.com/api/v1`
>
> **Content-Type:** `application/json`

---

## Table of Contents

1. [Authentication](#authentication)
2. [Multi-Tenancy](#multi-tenancy)
3. [Error Handling](#error-handling)
4. [Pagination](#pagination)
5. [Admin API](#admin-api)
   - [Auth (Sessions)](#admin-auth)
   - [Store](#admin-store)
   - [Dashboard](#admin-dashboard)
   - [Categories](#admin-categories)
   - [Products](#admin-products)
   - [Product Variants](#admin-product-variants)
   - [Product Images](#admin-product-images)
   - [Orders](#admin-orders)
   - [Customers](#admin-customers)
6. [Storefront API](#storefront-api)
   - [Products](#storefront-products)
   - [Categories](#storefront-categories)
   - [Cart](#storefront-cart)
   - [Orders](#storefront-orders)
   - [Customer Sessions](#storefront-sessions)
   - [Customer Registration](#storefront-customer-registration)

---

## Authentication

### Admin Authentication

Admin endpoints use **JWT Bearer tokens** via Devise JWT.

Include the token in the `Authorization` header:

```
Authorization: Bearer <jwt_token>
```

The token is returned in the `Authorization` header after a successful sign-in.

### Customer Authentication (Storefront)

Customer-facing endpoints use a custom JWT token passed via the `X-Customer-Token` header:

```
X-Customer-Token: <jwt_token>
```

The token is returned in the response body after sign-in or registration. Tokens expire after **24 hours**.

---

## Multi-Tenancy

All requests are scoped to a **store**. The store is resolved differently depending on the API namespace:

| Namespace | Resolution Method |
|-----------|-------------------|
| **Admin** (`/api/v1/admin/*`) | Resolved from the authenticated user's `store_id` |
| **Storefront** (`/api/v1/storefront/*`) | Resolved from `X-Store-Domain` header or `Origin` header hostname |

**Storefront headers:**

```
X-Store-Domain: my-store.example.com
```

If `X-Store-Domain` is not provided, the API attempts to extract the domain from the `Origin` header.

---

## Error Handling

All errors follow a consistent JSON format:

```json
{
  "error": "Error message or array of messages"
}
```

| HTTP Status | Meaning |
|-------------|---------|
| `400` | Bad Request — missing required parameter |
| `401` | Unauthorized — invalid or missing authentication |
| `403` | Forbidden — not authorized to perform this action |
| `404` | Not Found — resource does not exist |
| `422` | Unprocessable Entity — validation error or invalid state transition |

---

## Pagination

Paginated endpoints return a `meta` object:

```json
{
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 5,
    "total_count": 100
  }
}
```

**Query parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | integer | `1` | Page number |
| `limit` | integer | `20` | Items per page |

---

## Admin API

All admin endpoints require a valid JWT Bearer token. The authenticated user must belong to the store.

---

<a id="admin-auth"></a>
### Auth (Sessions)

#### Sign In

```
POST /api/v1/admin/auth/sign_in
```

**Request Body:**

```json
{
  "user": {
    "email": "admin@example.com",
    "password": "password123"
  }
}
```

**Response `200 OK`:**

```json
{
  "user": {
    "id": "uuid",
    "email": "admin@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "role": "owner",
    "full_name": "John Doe",
    "created_at": "2026-01-01T00:00:00.000Z",
    "updated_at": "2026-01-01T00:00:00.000Z"
  },
  "message": "Logged in successfully."
}
```

The JWT token is returned in the `Authorization` response header.

**Response `401 Unauthorized`:**

```json
{
  "error": "Invalid Email or password."
}
```

---

#### Sign Out

```
DELETE /api/v1/admin/auth/sign_out
```

**Headers:** `Authorization: Bearer <token>`

**Response `200 OK`:**

```json
{
  "message": "Logged out successfully."
}
```

---

<a id="admin-store"></a>
### Store

#### Get Store

```
GET /api/v1/admin/store
```

**Headers:** `Authorization: Bearer <token>`

**Response `200 OK`:**

```json
{
  "id": "uuid",
  "name": "My Store",
  "slug": "my-store",
  "custom_domain": "store.example.com",
  "subdomain": "my-store",
  "description": "A great store",
  "currency": "USD",
  "locale": "en",
  "settings": {},
  "active": true,
  "created_at": "2026-01-01T00:00:00.000Z",
  "updated_at": "2026-01-01T00:00:00.000Z"
}
```

---

#### Update Store

```
PATCH /api/v1/admin/store
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**

```json
{
  "store": {
    "name": "Updated Store Name",
    "description": "Updated description",
    "custom_domain": "new-domain.example.com",
    "subdomain": "new-subdomain",
    "currency": "EUR",
    "locale": "es",
    "active": true,
    "settings": { "theme": "dark" }
  }
}
```

**Response `200 OK`:** Same as Get Store response with updated values.

---

<a id="admin-dashboard"></a>
### Dashboard

#### Get Dashboard

```
GET /api/v1/admin/dashboard
```

**Headers:** `Authorization: Bearer <token>`

**Response `200 OK`:**

```json
{
  "total_products": 42,
  "total_orders": 150,
  "total_customers": 85,
  "total_revenue_cents": 5000000,
  "orders_by_status": {
    "pending": 10,
    "confirmed": 5,
    "paid": 20,
    "shipped": 15,
    "delivered": 100
  },
  "recent_orders": [
    {
      "id": "uuid",
      "order_number": "#1001",
      "email": "customer@example.com",
      "status": "pending",
      "total": { "amount": 50.0, "currency": "USD" },
      "items_count": 3,
      "customer_name": "John Doe",
      "created_at": "2026-01-01T00:00:00.000Z"
    }
  ]
}
```

---

<a id="admin-categories"></a>
### Categories

#### List Categories

```
GET /api/v1/admin/categories
```

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | integer | Page number |
| `limit` | integer | Items per page |

**Response `200 OK`:**

```json
{
  "categories": [
    {
      "id": "uuid",
      "name": "Electronics",
      "slug": "electronics",
      "description": "Electronic products",
      "position": 1,
      "active": true,
      "parent_id": null,
      "children_count": 3,
      "products_count": 15,
      "created_at": "2026-01-01T00:00:00.000Z",
      "updated_at": "2026-01-01T00:00:00.000Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 1,
    "total_count": 5
  }
}
```

---

#### Get Category

```
GET /api/v1/admin/categories/:id
```

**Headers:** `Authorization: Bearer <token>`

**Response `200 OK`:**

```json
{
  "id": "uuid",
  "name": "Electronics",
  "slug": "electronics",
  "description": "Electronic products",
  "position": 1,
  "active": true,
  "parent_id": null,
  "children_count": 3,
  "products_count": 15,
  "created_at": "2026-01-01T00:00:00.000Z",
  "updated_at": "2026-01-01T00:00:00.000Z"
}
```

---

#### Create Category

```
POST /api/v1/admin/categories
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**

```json
{
  "category": {
    "name": "Electronics",
    "description": "Electronic products",
    "parent_id": null,
    "position": 1,
    "active": true
  }
}
```

**Response `201 Created`:** Same as Get Category response.

---

#### Update Category

```
PATCH /api/v1/admin/categories/:id
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**

```json
{
  "category": {
    "name": "Updated Name",
    "description": "Updated description",
    "position": 2,
    "active": false
  }
}
```

**Response `200 OK`:** Same as Get Category response with updated values.

---

#### Delete Category (Soft Delete)

```
DELETE /api/v1/admin/categories/:id
```

**Headers:** `Authorization: Bearer <token>`

**Response `204 No Content`**

---

<a id="admin-products"></a>
### Products

#### List Products

```
GET /api/v1/admin/products
```

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | integer | Page number |
| `limit` | integer | Items per page |
| `status` | string | Filter by status (`draft`, `active`, `archived`) |
| `category_id` | uuid | Filter by category |
| `q` | string | Search by product name (ILIKE) |
| `featured` | string | Filter featured products (`true`) |

**Response `200 OK`:**

```json
{
  "products": [
    {
      "id": "uuid",
      "name": "Cool T-Shirt",
      "slug": "cool-t-shirt",
      "short_description": "A cool t-shirt",
      "sku": "TST-001",
      "status": "active",
      "featured": false,
      "quantity": 50,
      "track_inventory": true,
      "position": 1,
      "base_price": { "amount": 25.0, "currency": "USD" },
      "compare_at_price": { "amount": 35.0, "currency": "USD" },
      "category_name": "Clothing",
      "variants_count": 3,
      "created_at": "2026-01-01T00:00:00.000Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 1,
    "total_count": 10
  }
}
```

> **Note:** `compare_at_price` is `null` when not set.

---

#### Get Product

```
GET /api/v1/admin/products/:id
```

**Headers:** `Authorization: Bearer <token>`

**Response `200 OK`:**

```json
{
  "id": "uuid",
  "name": "Cool T-Shirt",
  "slug": "cool-t-shirt",
  "description": "A really cool t-shirt with a great design.",
  "short_description": "A cool t-shirt",
  "sku": "TST-001",
  "barcode": null,
  "status": "active",
  "featured": false,
  "custom_attributes": {},
  "quantity": 50,
  "track_inventory": true,
  "position": 1,
  "published_at": "2026-01-01T00:00:00.000Z",
  "base_price": { "amount": 25.0, "currency": "USD" },
  "compare_at_price": { "amount": 35.0, "currency": "USD" },
  "category": {
    "id": "uuid",
    "name": "Clothing",
    "slug": "clothing",
    "position": 1,
    "active": true,
    "parent_id": null
  },
  "variants": [
    {
      "id": "uuid",
      "name": "Red / XL",
      "sku": "TST-001-RXL",
      "track_inventory": true,
      "quantity": 20,
      "options": { "color": "red", "size": "XL" },
      "position": 1,
      "active": true,
      "price": { "amount": 25.0, "currency": "USD" },
      "compare_at_price": null,
      "created_at": "2026-01-01T00:00:00.000Z",
      "updated_at": "2026-01-01T00:00:00.000Z"
    }
  ],
  "images": [
    {
      "id": "uuid",
      "position": 1,
      "alt_text": "Front view",
      "url": "https://storage.example.com/image.jpg",
      "created_at": "2026-01-01T00:00:00.000Z",
      "updated_at": "2026-01-01T00:00:00.000Z"
    }
  ],
  "created_at": "2026-01-01T00:00:00.000Z",
  "updated_at": "2026-01-01T00:00:00.000Z"
}
```

---

#### Create Product

```
POST /api/v1/admin/products
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**

```json
{
  "product": {
    "name": "Cool T-Shirt",
    "description": "A really cool t-shirt with a great design.",
    "short_description": "A cool t-shirt",
    "category_id": "uuid",
    "base_price_cents": 2500,
    "base_price_currency": "USD",
    "compare_at_price_cents": 3500,
    "compare_at_price_currency": "USD",
    "sku": "TST-001",
    "barcode": null,
    "track_inventory": true,
    "quantity": 50,
    "status": "draft",
    "featured": false,
    "position": 1,
    "published_at": null,
    "custom_attributes": {}
  }
}
```

**Response `201 Created`:** Same as Get Product response.

---

#### Update Product

```
PATCH /api/v1/admin/products/:id
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:** Same fields as create (all optional).

**Response `200 OK`:** Same as Get Product response with updated values.

---

#### Delete Product (Soft Delete)

```
DELETE /api/v1/admin/products/:id
```

**Headers:** `Authorization: Bearer <token>`

**Response `204 No Content`**

---

<a id="admin-product-variants"></a>
### Product Variants

All variant endpoints are nested under a product: `/api/v1/admin/products/:product_id/variants`

#### List Variants

```
GET /api/v1/admin/products/:product_id/variants
```

**Headers:** `Authorization: Bearer <token>`

**Response `200 OK`:**

```json
{
  "variants": [
    {
      "id": "uuid",
      "name": "Red / XL",
      "sku": "TST-001-RXL",
      "track_inventory": true,
      "quantity": 20,
      "options": { "color": "red", "size": "XL" },
      "position": 1,
      "active": true,
      "price": { "amount": 25.0, "currency": "USD" },
      "compare_at_price": null,
      "created_at": "2026-01-01T00:00:00.000Z",
      "updated_at": "2026-01-01T00:00:00.000Z"
    }
  ]
}
```

---

#### Get Variant

```
GET /api/v1/admin/products/:product_id/variants/:id
```

**Headers:** `Authorization: Bearer <token>`

**Response `200 OK`:** Single variant object (same structure as items in list).

---

#### Create Variant

```
POST /api/v1/admin/products/:product_id/variants
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**

```json
{
  "variant": {
    "name": "Red / XL",
    "sku": "TST-001-RXL",
    "price_cents": 2500,
    "price_currency": "USD",
    "compare_at_price_cents": null,
    "compare_at_price_currency": "USD",
    "track_inventory": true,
    "quantity": 20,
    "position": 1,
    "active": true,
    "options": { "color": "red", "size": "XL" }
  }
}
```

**Response `201 Created`:** Single variant object.

---

#### Update Variant

```
PATCH /api/v1/admin/products/:product_id/variants/:id
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:** Same fields as create (all optional).

**Response `200 OK`:** Single variant object with updated values.

---

#### Delete Variant (Soft Delete)

```
DELETE /api/v1/admin/products/:product_id/variants/:id
```

**Headers:** `Authorization: Bearer <token>`

**Response `204 No Content`**

---

<a id="admin-product-images"></a>
### Product Images

All image endpoints are nested under a product: `/api/v1/admin/products/:product_id/images`

#### List Images

```
GET /api/v1/admin/products/:product_id/images
```

**Headers:** `Authorization: Bearer <token>`

**Response `200 OK`:**

```json
{
  "images": [
    {
      "id": "uuid",
      "position": 1,
      "alt_text": "Front view",
      "url": "https://storage.example.com/image.jpg",
      "created_at": "2026-01-01T00:00:00.000Z",
      "updated_at": "2026-01-01T00:00:00.000Z"
    }
  ]
}
```

---

#### Create Image

```
POST /api/v1/admin/products/:product_id/images
```

**Headers:** `Authorization: Bearer <token>`

**Content-Type:** `multipart/form-data`

**Form Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `image` | file | Image file (JPEG, PNG, WebP, etc.) |
| `position` | integer | Display order |
| `alt_text` | string | Image alt text for accessibility |

**Response `201 Created`:** Single image object.

---

#### Update Image

```
PATCH /api/v1/admin/products/:product_id/images/:id
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**

```json
{
  "position": 2,
  "alt_text": "Updated alt text"
}
```

**Response `200 OK`:** Single image object with updated values.

---

#### Delete Image

```
DELETE /api/v1/admin/products/:product_id/images/:id
```

**Headers:** `Authorization: Bearer <token>`

**Response `204 No Content`**

---

<a id="admin-orders"></a>
### Orders

#### List Orders

```
GET /api/v1/admin/orders
```

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | integer | Page number |
| `limit` | integer | Items per page |
| `status` | string | Filter by status |

**Available statuses:** `pending`, `confirmed`, `paid`, `processing`, `shipped`, `delivered`, `cancelled`, `refunded`

**Response `200 OK`:**

```json
{
  "orders": [
    {
      "id": "uuid",
      "order_number": "#1001",
      "email": "customer@example.com",
      "status": "pending",
      "total": { "amount": 50.0, "currency": "USD" },
      "items_count": 3,
      "customer_name": "John Doe",
      "created_at": "2026-01-01T00:00:00.000Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 1,
    "total_count": 50
  }
}
```

> **Note:** `customer_name` is `null` when the order has no associated customer (guest checkout).

---

#### Get Order

```
GET /api/v1/admin/orders/:id
```

**Headers:** `Authorization: Bearer <token>`

**Response `200 OK`:**

```json
{
  "id": "uuid",
  "order_number": "#1001",
  "email": "customer@example.com",
  "status": "pending",
  "shipping_address": {
    "line1": "123 Main St",
    "city": "New York",
    "state": "NY",
    "zip": "10001",
    "country": "US"
  },
  "billing_address": {
    "line1": "123 Main St",
    "city": "New York",
    "state": "NY",
    "zip": "10001",
    "country": "US"
  },
  "notes": null,
  "metadata": {},
  "placed_at": "2026-01-01T00:00:00.000Z",
  "paid_at": null,
  "shipped_at": null,
  "delivered_at": null,
  "cancelled_at": null,
  "subtotal": { "amount": 50.0, "currency": "USD" },
  "tax": { "amount": 0.0, "currency": "USD" },
  "total": { "amount": 50.0, "currency": "USD" },
  "customer": {
    "id": "uuid",
    "email": "customer@example.com",
    "first_name": "John",
    "last_name": "Doe"
  },
  "items": [
    {
      "id": "uuid",
      "product_id": "uuid",
      "product_variant_id": null,
      "product_name": "Cool T-Shirt",
      "variant_name": null,
      "sku": "TST-001",
      "quantity": 2,
      "unit_price": { "amount": 25.0, "currency": "USD" },
      "total": { "amount": 50.0, "currency": "USD" }
    }
  ],
  "created_at": "2026-01-01T00:00:00.000Z",
  "updated_at": "2026-01-01T00:00:00.000Z"
}
```

> **Note:** `customer` is `null` for guest orders.

---

#### Update Order Status

```
PATCH /api/v1/admin/orders/:id
```

**Headers:** `Authorization: Bearer <token>`

**Request Body:**

```json
{
  "event": "confirm"
}
```

**Valid Events and Transitions:**

| Event | From | To |
|-------|------|----|
| `confirm` | `pending` | `confirmed` |
| `pay` | `confirmed` | `paid` |
| `process_order` | `paid` | `processing` |
| `ship` | `processing` | `shipped` |
| `deliver` | `shipped` | `delivered` |
| `cancel` | `pending`, `confirmed` | `cancelled` |
| `refund` | `paid` | `refunded` |

**Response `200 OK`:** Full order object with updated status.

**Response `422 Unprocessable Entity`:**

```json
{
  "errors": ["Cannot transition from pending via pay"]
}
```

---

<a id="admin-customers"></a>
### Customers

#### List Customers

```
GET /api/v1/admin/customers
```

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | integer | Page number |
| `limit` | integer | Items per page |
| `q` | string | Search by email (ILIKE) |

**Response `200 OK`:**

```json
{
  "customers": [
    {
      "id": "uuid",
      "email": "customer@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "phone": "+1234567890",
      "accepts_marketing": false,
      "metadata": {},
      "orders_count": 5,
      "created_at": "2026-01-01T00:00:00.000Z",
      "updated_at": "2026-01-01T00:00:00.000Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 1,
    "total_count": 20
  }
}
```

---

#### Get Customer

```
GET /api/v1/admin/customers/:id
```

**Headers:** `Authorization: Bearer <token>`

**Response `200 OK`:** Single customer object (same structure as items in list).

---

## Storefront API

Storefront endpoints are public (no admin auth required). Store is resolved via `X-Store-Domain` or `Origin` header.

---

<a id="storefront-products"></a>
### Products

#### List Products

```
GET /api/v1/storefront/products
```

**Headers:** `X-Store-Domain: my-store.example.com`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | integer | Page number |
| `limit` | integer | Items per page |
| `category_id` | uuid | Filter by category |
| `q` | string | Search by product name (ILIKE) |
| `featured` | string | Filter featured products (`true`) |
| `in_stock` | string | Filter in-stock products (`true`) |

> Only **active** products are returned.

**Response `200 OK`:**

```json
{
  "products": [
    {
      "id": "uuid",
      "name": "Cool T-Shirt",
      "slug": "cool-t-shirt",
      "short_description": "A cool t-shirt",
      "sku": "TST-001",
      "status": "active",
      "featured": false,
      "quantity": 50,
      "track_inventory": true,
      "position": 1,
      "base_price": { "amount": 25.0, "currency": "USD" },
      "compare_at_price": null,
      "category_name": "Clothing",
      "variants_count": 3,
      "created_at": "2026-01-01T00:00:00.000Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 1,
    "total_count": 10
  }
}
```

---

#### Get Product by Slug

```
GET /api/v1/storefront/products/:slug
```

**Headers:** `X-Store-Domain: my-store.example.com`

**Response `200 OK`:** Full product object (same as Admin Get Product), including `category`, `variants`, and `images`.

---

<a id="storefront-categories"></a>
### Categories

#### List Categories

```
GET /api/v1/storefront/categories
```

**Headers:** `X-Store-Domain: my-store.example.com`

> Returns only **active** root categories with their children.

**Response `200 OK`:**

```json
{
  "categories": [
    {
      "id": "uuid",
      "name": "Electronics",
      "slug": "electronics",
      "description": "Electronic products",
      "position": 1,
      "active": true,
      "parent_id": null,
      "children_count": 3,
      "products_count": 15,
      "created_at": "2026-01-01T00:00:00.000Z",
      "updated_at": "2026-01-01T00:00:00.000Z"
    }
  ]
}
```

---

#### Get Category by Slug (with Products)

```
GET /api/v1/storefront/categories/:slug
```

**Headers:** `X-Store-Domain: my-store.example.com`

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `page` | integer | Page number for products |
| `limit` | integer | Products per page |

**Response `200 OK`:**

```json
{
  "category": {
    "id": "uuid",
    "name": "Electronics",
    "slug": "electronics",
    "description": "Electronic products",
    "position": 1,
    "active": true,
    "parent_id": null,
    "children_count": 3,
    "products_count": 15,
    "created_at": "2026-01-01T00:00:00.000Z",
    "updated_at": "2026-01-01T00:00:00.000Z"
  },
  "products": [
    {
      "id": "uuid",
      "name": "Smartphone",
      "slug": "smartphone",
      "base_price": { "amount": 499.0, "currency": "USD" },
      "..."
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 1,
    "total_count": 15
  }
}
```

---

<a id="storefront-cart"></a>
### Cart

The cart is identified by a token passed in the `X-Cart-Token` header. If no token is provided, a new cart is created and the token is returned in the `X-Cart-Token` response header.

**Headers:**

```
X-Store-Domain: my-store.example.com
X-Cart-Token: <cart_token>
```

#### Get Cart

```
GET /api/v1/storefront/cart
```

**Response `200 OK`:**

```json
{
  "id": "uuid",
  "token": "abc123...",
  "status": "active",
  "metadata": {},
  "expires_at": null,
  "total": { "amount": 50.0, "currency": "USD" },
  "items_count": 2,
  "items": [
    {
      "id": "uuid",
      "quantity": 2,
      "unit_price": { "amount": 25.0, "currency": "USD" },
      "total": { "amount": 50.0, "currency": "USD" },
      "product": {
        "id": "uuid",
        "name": "Cool T-Shirt",
        "slug": "cool-t-shirt"
      },
      "variant": null,
      "created_at": "2026-01-01T00:00:00.000Z",
      "updated_at": "2026-01-01T00:00:00.000Z"
    }
  ],
  "created_at": "2026-01-01T00:00:00.000Z",
  "updated_at": "2026-01-01T00:00:00.000Z"
}
```

> **Note:** `variant` is `null` when the item is for a product without variants. When present:
> ```json
> "variant": { "id": "uuid", "name": "Red / XL" }
> ```

---

#### Add Item to Cart

```
POST /api/v1/storefront/cart/add_item
```

**Request Body:**

```json
{
  "product_id": "uuid",
  "variant_id": "uuid",
  "quantity": 2
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `product_id` | uuid | Yes | Product to add |
| `variant_id` | uuid | No | Specific variant (if product has variants) |
| `quantity` | integer | No | Quantity (default: 1) |

**Response `200 OK`:** Full cart object.

**Response `422 Unprocessable Entity`:**

```json
{
  "errors": ["Not enough stock available"]
}
```

---

#### Update Cart Item Quantity

```
PATCH /api/v1/storefront/cart/update_item
```

**Request Body:**

```json
{
  "cart_item_id": "uuid",
  "quantity": 3
}
```

**Response `200 OK`:** Full cart object.

**Response `422 Unprocessable Entity`:**

```json
{
  "errors": ["Cart item not found"]
}
```

---

#### Remove Cart Item

```
DELETE /api/v1/storefront/cart/remove_item
```

**Request Body:**

```json
{
  "cart_item_id": "uuid"
}
```

**Response `200 OK`:** Full cart object.

---

#### Clear Cart

```
DELETE /api/v1/storefront/cart/clear
```

**Response `200 OK`:** Full cart object (empty).

---

<a id="storefront-orders"></a>
### Orders

#### Create Order (Checkout)

```
POST /api/v1/storefront/orders
```

**Headers:**

```
X-Store-Domain: my-store.example.com
X-Cart-Token: <cart_token>
X-Customer-Token: <customer_token>  (optional)
```

**Request Body:**

```json
{
  "email": "customer@example.com",
  "shipping_address": {
    "line1": "123 Main St",
    "city": "New York",
    "state": "NY",
    "zip": "10001",
    "country": "US"
  },
  "billing_address": {
    "line1": "123 Main St",
    "city": "New York",
    "state": "NY",
    "zip": "10001",
    "country": "US"
  },
  "notes": "Please leave at the door"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes | Customer email |
| `shipping_address` | object | No | Shipping address |
| `billing_address` | object | No | Billing address |
| `notes` | string | No | Order notes |

> If `X-Customer-Token` is provided, the order is associated with the authenticated customer.

**Response `201 Created`:** Full order object (same as Admin Get Order).

**Response `422 Unprocessable Entity`:**

```json
{
  "errors": ["Cart is empty"]
}
```

---

#### Get Order by Number

```
GET /api/v1/storefront/orders/:order_number
```

**Headers:** `X-Store-Domain: my-store.example.com`

> The `order_number` parameter should be the numeric part only (without the `#` prefix). For example, for order `#1001`, use `/api/v1/storefront/orders/1001`.

**Response `200 OK`:** Full order object.

---

<a id="storefront-sessions"></a>
### Customer Sessions

#### Sign In

```
POST /api/v1/storefront/session
```

**Headers:** `X-Store-Domain: my-store.example.com`

**Request Body:**

```json
{
  "email": "customer@example.com",
  "password": "password123"
}
```

**Response `200 OK`:**

```json
{
  "customer": {
    "id": "uuid",
    "email": "customer@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "phone": "+1234567890",
    "accepts_marketing": false,
    "metadata": {},
    "orders_count": 5,
    "created_at": "2026-01-01T00:00:00.000Z",
    "updated_at": "2026-01-01T00:00:00.000Z"
  },
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

**Response `401 Unauthorized`:**

```json
{
  "error": "Invalid email or password"
}
```

---

<a id="storefront-customer-registration"></a>
### Customer Registration

#### Register

```
POST /api/v1/storefront/customers
```

**Headers:** `X-Store-Domain: my-store.example.com`

**Request Body:**

```json
{
  "customer": {
    "email": "newcustomer@example.com",
    "first_name": "Jane",
    "last_name": "Doe",
    "phone": "+1234567890",
    "password": "securepassword",
    "password_confirmation": "securepassword"
  }
}
```

**Response `201 Created`:**

```json
{
  "customer": {
    "id": "uuid",
    "email": "newcustomer@example.com",
    "first_name": "Jane",
    "last_name": "Doe",
    "phone": "+1234567890",
    "accepts_marketing": false,
    "metadata": {},
    "orders_count": 0,
    "created_at": "2026-01-01T00:00:00.000Z",
    "updated_at": "2026-01-01T00:00:00.000Z"
  },
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

**Response `422 Unprocessable Entity`:**

```json
{
  "error": ["Email has already been taken"]
}
```
