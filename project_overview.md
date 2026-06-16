# Bizon Commerce - Project Overview

## What is it?

**Bizon Commerce** is a multi-tenant e-commerce API backend built with **Rails 8.1.2** and **PostgreSQL**. It provides separate Admin and Storefront JSON APIs (versioned under `/api/v1/`) to power online stores. The current seed data showcases a jewelry store ("Samdalth Gold - Joyeria Premium").

---

## Tech Stack

| Layer              | Technology                                     |
| ------------------ | ---------------------------------------------- |
| Framework          | Rails 8.1.2 (API-only)                         |
| Database           | PostgreSQL (UUID primary keys, pgcrypto)        |
| Auth (Admin)       | Devise + devise-jwt (Bearer token, 24h expiry)  |
| Auth (Customer)    | Custom JWT via `has_secure_password` (bcrypt)    |
| Authorization      | Pundit policies                                 |
| Serialization      | Alba (14 serializers)                           |
| Pagination         | Pagy                                            |
| State Machine      | AASM (Order lifecycle: 8 states)                |
| Money              | money-rails (cents + currency columns)          |
| Slugs              | friendly_id (store-scoped)                      |
| Soft Deletes       | Discard (Category, Product, ProductVariant)      |
| File Storage       | Active Storage + AWS S3                         |
| Background Jobs    | Solid Queue / Sidekiq                           |
| Caching            | Solid Cache / Redis                             |
| API Docs           | rswag (Swagger/OpenAPI)                         |
| Deployment         | Kamal + Docker + Thruster (HTTP2/SSL)           |
| CI/CD              | GitHub Actions (Brakeman, bundler-audit, Rubocop)|
| Testing            | RSpec, FactoryBot, Faker, SimpleCov (98% min)   |

---

## Architecture

```
                    ┌──────────────────────────────┐
                    │         Client Apps           │
                    │  (Admin SPA / Storefront SPA) │
                    └──────────┬───────────────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
     Admin API (JWT)   Storefront API    Cart (Token)
   Authorization:       Store resolved    X-Cart-Token
   Bearer <token>      via X-Store-Domain   header
   Pundit policies     or Origin header
              │                │                │
              └────────────────┼────────────────┘
                               │
                    ┌──────────┴───────────┐
                    │   Rails Controllers  │
                    │   api/v1/admin/*     │
                    │   api/v1/storefront/*│
                    └──────────┬───────────┘
                               │
                    ┌──────────┴───────────┐
                    │  Services / Models   │
                    │  Multi::Scoped       │
                    │  (auto store_id)     │
                    └──────────┬───────────┘
                               │
                    ┌──────────┴───────────┐
                    │     PostgreSQL        │
                    │  (UUID PKs, JSONB)   │
                    └──────────────────────┘
```

---

## Multi-Tenancy Model

- **Store** is the tenant. All major entities (`Product`, `Category`, `Customer`, `Order`, `Cart`) belong to a `Store`.
- The `Multi::Scoped` concern auto-scopes queries by `store_id`.
- **Admin**: Store resolved from `current_user.store`.
- **Storefront**: Store resolved from `X-Store-Domain` header (custom_domain or subdomain) or `Origin` header.

---

## Database Schema (13 tables)

| Table              | Purpose                                | Key Details                                         |
| ------------------ | -------------------------------------- | --------------------------------------------------- |
| `stores`           | Tenant/store config                    | slug, custom_domain, subdomain, currency, tax_rate  |
| `users`            | Admin users                            | Devise JWT, role enum (staff/admin/owner)           |
| `categories`       | Product categories (hierarchical)      | parent_id for tree structure, soft delete            |
| `products`         | Product catalog                        | status (draft/active/archived), monetized prices     |
| `product_variants` | Size/color/material variations         | JSONB options, independent price + stock             |
| `product_images`   | Images via Active Storage              | position, alt_text                                   |
| `customers`        | Storefront buyers                      | has_secure_password, accepts_marketing               |
| `carts`            | Shopping carts                         | token-based, status (active/abandoned/converted)     |
| `cart_items`       | Cart line items                        | product + optional variant, unit_price               |
| `orders`           | Customer orders                        | AASM state machine, order_number (#BZ-XXXXXXXX)     |
| `order_items`      | Order line items (snapshot)            | Denormalized product_name, sku, variant_name         |
| `active_storage_*` | File attachments                       | Rails Active Storage tables                          |

---

## API Endpoints

### Admin API (`/api/v1/admin/`)

| Resource         | Endpoints                         | Auth        |
| ---------------- | --------------------------------- | ----------- |
| Auth             | POST sign_in, DELETE sign_out     | Public/JWT  |
| Store            | GET, PATCH                        | JWT         |
| Dashboard        | GET (stats)                       | JWT         |
| Categories       | CRUD (index/show/create/update/destroy) | JWT + Pundit |
| Products         | CRUD + filtering                  | JWT + Pundit |
| Variants         | CRUD (nested under products)      | JWT + Pundit |
| Product Images   | Create/Update/Delete (nested)     | JWT + Pundit |
| Orders           | Index/Show/Update (status change) | JWT + Pundit |
| Customers        | Index/Show                        | JWT + Pundit |

### Storefront API (`/api/v1/storefront/`)

| Resource    | Endpoints                                     | Auth              |
| ----------- | --------------------------------------------- | ----------------- |
| Products    | GET list (filtered, paginated), GET by slug   | Public            |
| Categories  | GET list (root + children), GET by slug       | Public            |
| Cart        | GET, POST add_item, PATCH update_item, DELETE remove/clear | X-Cart-Token |
| Orders      | POST create (checkout), GET by order_number   | Optional customer |
| Session     | POST sign_in                                  | Public            |
| Customers   | POST register                                 | Public            |

---

## Order State Machine

```
pending → confirmed → paid → processing → shipped → delivered
   │                   │
   └→ cancelled    cancelled / refunded
```

**States**: pending, confirmed, paid, processing, shipped, delivered, cancelled, refunded

---

## Services

| Service                           | Purpose                                      |
| --------------------------------- | -------------------------------------------- |
| `Carts::AddItemService`          | Add product/variant to cart with stock check  |
| `Carts::RemoveItemService`       | Remove item from cart                         |
| `Carts::UpdateItemService`       | Update cart item quantity                     |
| `Orders::CreateFromCartService`  | Convert cart to order (transactional)         |
| `Orders::UpdateStatusService`    | Trigger AASM state transitions                |
| `Products::CreateWithVariantsService` | Create product + variants in transaction |

---

## Key Conventions

- **UUID primary keys** everywhere
- **Cents-based money storage** (e.g., `base_price_cents` + `base_price_currency`)
- **Soft deletes** via `discard` gem (`discarded_at` column)
- **Friendly slugs** scoped per store
- **JSONB** for flexible data (variant options, order addresses, store settings, customer metadata)
- **Denormalized order items** (snapshot of product_name, sku at time of purchase)
- **Token-based cart management** (no auth required)

---

## Seed Data

- **Store**: "Samdalth Gold - Joyeria Premium" (jewelry, subdomain: samdalth, currency: USD, locale: es)
- **Admin**: admin@samdalth.com / Samdalth@123 (role: owner)
- **Categories**: 7 main (Anillos, Aretes, Pulseras, Collares, Conjuntos, Diamantes, Accesorios) + subcategories
- **Products**: 100+ jewelry items with variants, Unsplash images, prices $50-$5000

---

## Testing

- **Framework**: RSpec
- **Coverage**: SimpleCov with 98% minimum threshold
- **Structure**: models (11), policies (3), serializers, services, integration (admin: 8, storefront: 6)
- **Factories**: Complete FactoryBot factories for all models
- **Database**: Transactional fixtures + DatabaseCleaner

---

## Deployment

- **Tool**: Kamal (Docker-based)
- **Image**: Ruby 4.0.1 slim, multi-stage build, jemalloc
- **Server**: Thruster → Puma (HTTP2, auto SSL)
- **CI**: GitHub Actions → Brakeman security scan, bundler-audit, Rubocop lint
