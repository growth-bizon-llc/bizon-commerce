require 'rails_helper'

# Shared context for admin integration tests that use bearer_auth security.
# Rswag resolves `security [bearer_auth: []]` by calling `let(:Authorization)`.
RSpec.shared_context 'admin_bearer_auth' do
  let(:store) { create(:store) }
  let(:user) { create(:user, :owner, store: store, password: 'password123') }
  let(:Authorization) { "Bearer #{Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first}" }

  before { Current.store = store }
end

# Shared context for storefront integration tests that use store_domain security.
# Rswag resolves `security [store_domain: []]` by calling `let(:'X-Store-Domain')`.
RSpec.shared_context 'storefront_store_domain' do
  let(:store) { create(:store) }
  let(:'X-Store-Domain') { store.custom_domain || store.subdomain }
  let(:'X-Cart-Token') { nil }
  let(:'X-Customer-Token') { nil }

  before { Current.store = store }
end

RSpec.configure do |config|
  config.openapi_root = Rails.root.to_s + '/swagger'

  # Auto-include shared contexts for integration tests based on path
  config.include_context 'admin_bearer_auth', file_path: %r{spec/integration/api/v1/admin/}
  config.include_context 'storefront_store_domain', file_path: %r{spec/integration/api/v1/storefront/}

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Bizon Commerce API',
        version: 'v1',
        description: 'Multi-tenant e-commerce API with Admin and Storefront endpoints.'
      },
      paths: {},
      servers: [
        { url: 'http://localhost:3000', description: 'Development' }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: :JWT,
            description: 'Admin JWT token (obtained via POST /api/v1/admin/auth/sign_in)'
          },
          store_domain: {
            type: :apiKey,
            in: :header,
            name: 'X-Store-Domain',
            description: 'Store domain or subdomain for tenant resolution (Storefront)'
          },
          cart_token: {
            type: :apiKey,
            in: :header,
            name: 'X-Cart-Token',
            description: 'Cart token for cart identification'
          },
          customer_token: {
            type: :apiKey,
            in: :header,
            name: 'X-Customer-Token',
            description: 'Customer JWT token (obtained via POST /api/v1/storefront/session)'
          }
        },
        schemas: {
          money: {
            type: :object,
            properties: {
              amount: { type: :number, example: 29.99 },
              currency: { type: :string, example: 'USD' }
            }
          },
          pagination_meta: {
            type: :object,
            properties: {
              current_page: { type: :integer },
              per_page: { type: :integer },
              total_pages: { type: :integer },
              total_count: { type: :integer }
            }
          },
          category: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              name: { type: :string },
              slug: { type: :string },
              description: { type: :string, nullable: true },
              position: { type: :integer, nullable: true },
              active: { type: :boolean },
              parent_id: { type: :string, format: :uuid, nullable: true },
              children_count: { type: :integer },
              products_count: { type: :integer },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          },
          variant: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              name: { type: :string },
              sku: { type: :string, nullable: true },
              track_inventory: { type: :boolean },
              quantity: { type: :integer },
              options: { type: :object },
              position: { type: :integer, nullable: true },
              active: { type: :boolean },
              price: { '$ref': '#/components/schemas/money' },
              compare_at_price: { '$ref': '#/components/schemas/money', nullable: true },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          },
          product_image: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              position: { type: :integer, nullable: true },
              alt_text: { type: :string, nullable: true },
              url: { type: :string, nullable: true },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          },
          product: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              name: { type: :string },
              slug: { type: :string },
              description: { type: :string, nullable: true },
              short_description: { type: :string, nullable: true },
              sku: { type: :string, nullable: true },
              barcode: { type: :string, nullable: true },
              status: { type: :string, enum: %w[draft active archived] },
              featured: { type: :boolean },
              custom_attributes: { type: :object, nullable: true },
              quantity: { type: :integer },
              track_inventory: { type: :boolean },
              position: { type: :integer, nullable: true },
              published_at: { type: :string, format: 'date-time', nullable: true },
              base_price: { '$ref': '#/components/schemas/money' },
              compare_at_price: { '$ref': '#/components/schemas/money', nullable: true },
              category: {
                type: :object,
                nullable: true,
                properties: {
                  id: { type: :string, format: :uuid },
                  name: { type: :string },
                  slug: { type: :string },
                  position: { type: :integer, nullable: true },
                  active: { type: :boolean },
                  parent_id: { type: :string, format: :uuid, nullable: true }
                }
              },
              variants: {
                type: :array,
                items: { '$ref': '#/components/schemas/variant' }
              },
              images: {
                type: :array,
                items: { '$ref': '#/components/schemas/product_image' }
              },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          },
          product_list: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              name: { type: :string },
              slug: { type: :string },
              short_description: { type: :string, nullable: true },
              sku: { type: :string, nullable: true },
              status: { type: :string, enum: %w[draft active archived] },
              featured: { type: :boolean },
              quantity: { type: :integer },
              track_inventory: { type: :boolean },
              position: { type: :integer, nullable: true },
              base_price: { '$ref': '#/components/schemas/money' },
              compare_at_price: { '$ref': '#/components/schemas/money', nullable: true },
              category_name: { type: :string, nullable: true },
              variants_count: { type: :integer },
              created_at: { type: :string, format: 'date-time' }
            }
          },
          customer: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              email: { type: :string },
              first_name: { type: :string, nullable: true },
              last_name: { type: :string, nullable: true },
              phone: { type: :string, nullable: true },
              accepts_marketing: { type: :boolean },
              metadata: { type: :object, nullable: true },
              orders_count: { type: :integer },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          },
          cart_item: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              quantity: { type: :integer },
              unit_price: { '$ref': '#/components/schemas/money' },
              total: { '$ref': '#/components/schemas/money' },
              product: {
                type: :object,
                properties: {
                  id: { type: :string, format: :uuid },
                  name: { type: :string },
                  slug: { type: :string }
                }
              },
              variant: {
                type: :object,
                nullable: true,
                properties: {
                  id: { type: :string, format: :uuid },
                  name: { type: :string }
                }
              },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          },
          cart: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              token: { type: :string },
              status: { type: :string },
              metadata: { type: :object, nullable: true },
              expires_at: { type: :string, format: 'date-time', nullable: true },
              total: { '$ref': '#/components/schemas/money' },
              items_count: { type: :integer },
              items: {
                type: :array,
                items: { '$ref': '#/components/schemas/cart_item' }
              },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          },
          order_item: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              product_id: { type: :string, format: :uuid },
              product_variant_id: { type: :string, format: :uuid, nullable: true },
              product_name: { type: :string },
              variant_name: { type: :string, nullable: true },
              sku: { type: :string, nullable: true },
              quantity: { type: :integer },
              unit_price: { '$ref': '#/components/schemas/money' },
              total: { '$ref': '#/components/schemas/money' }
            }
          },
          order: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              order_number: { type: :string, example: '#1001' },
              email: { type: :string },
              status: { type: :string, enum: %w[pending confirmed paid processing shipped delivered cancelled refunded] },
              shipping_address: { type: :object },
              billing_address: { type: :object, nullable: true },
              notes: { type: :string, nullable: true },
              metadata: { type: :object, nullable: true },
              subtotal: { '$ref': '#/components/schemas/money' },
              tax: { '$ref': '#/components/schemas/money' },
              total: { '$ref': '#/components/schemas/money' },
              customer: {
                type: :object,
                nullable: true,
                properties: {
                  id: { type: :string, format: :uuid },
                  email: { type: :string },
                  first_name: { type: :string },
                  last_name: { type: :string }
                }
              },
              items: {
                type: :array,
                items: { '$ref': '#/components/schemas/order_item' }
              },
              placed_at: { type: :string, format: 'date-time', nullable: true },
              paid_at: { type: :string, format: 'date-time', nullable: true },
              shipped_at: { type: :string, format: 'date-time', nullable: true },
              delivered_at: { type: :string, format: 'date-time', nullable: true },
              cancelled_at: { type: :string, format: 'date-time', nullable: true },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          },
          order_list: {
            type: :object,
            properties: {
              id: { type: :string, format: :uuid },
              order_number: { type: :string },
              email: { type: :string },
              status: { type: :string },
              total: { '$ref': '#/components/schemas/money' },
              items_count: { type: :integer },
              customer_name: { type: :string, nullable: true },
              created_at: { type: :string, format: 'date-time' }
            }
          }
        }
      },
      tags: [
        { name: 'Admin / Auth', description: 'Admin authentication (sign in / sign out)' },
        { name: 'Admin / Store', description: 'Store configuration' },
        { name: 'Admin / Dashboard', description: 'Dashboard metrics' },
        { name: 'Admin / Categories', description: 'Category management' },
        { name: 'Admin / Products', description: 'Product management' },
        { name: 'Admin / Variants', description: 'Product variant management' },
        { name: 'Admin / Product Images', description: 'Product image management' },
        { name: 'Admin / Orders', description: 'Order management' },
        { name: 'Admin / Customers', description: 'Customer management' },
        { name: 'Storefront / Products', description: 'Browse products' },
        { name: 'Storefront / Categories', description: 'Browse categories' },
        { name: 'Storefront / Cart', description: 'Shopping cart operations' },
        { name: 'Storefront / Orders', description: 'Checkout and order lookup' },
        { name: 'Storefront / Sessions', description: 'Customer login' },
        { name: 'Storefront / Customers', description: 'Customer registration' }
      ]
    }
  }

  config.openapi_format = :yaml
end
