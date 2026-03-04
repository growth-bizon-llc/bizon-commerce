puts "Seeding database..."

# Store
store = Store.find_or_create_by!(slug: 'demo-store') do |s|
  s.name = 'Demo Store'
  s.custom_domain = 'demo.localhost'
  s.subdomain = 'demo'
  s.description = 'A demo ecommerce store for development'
  s.currency = 'USD'
  s.locale = 'en'
  s.settings = { theme: 'default', logo_url: nil, primary_color: '#3B82F6' }
end
puts "  Store: #{store.name} (#{store.slug})"

Current.store = store

# Users
owner = User.find_or_create_by!(email: 'owner@demo.com') do |u|
  u.store = store
  u.first_name = 'John'
  u.last_name = 'Owner'
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.role = :owner
  u.jti = SecureRandom.uuid
end
puts "  Owner: #{owner.email}"

admin = User.find_or_create_by!(email: 'admin@demo.com') do |u|
  u.store = store
  u.first_name = 'Jane'
  u.last_name = 'Admin'
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.role = :admin
  u.jti = SecureRandom.uuid
end
puts "  Admin: #{admin.email}"

staff = User.find_or_create_by!(email: 'staff@demo.com') do |u|
  u.store = store
  u.first_name = 'Bob'
  u.last_name = 'Staff'
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.role = :staff
  u.jti = SecureRandom.uuid
end
puts "  Staff: #{staff.email}"

# Categories
category_names = ['Electronics', 'Clothing', 'Home & Garden', 'Sports', 'Books']
categories = category_names.map.with_index do |name, i|
  Category.find_or_create_by!(name: name, store: store) do |c|
    c.description = Faker::Lorem.paragraph(sentence_count: 2)
    c.position = i
    c.active = true
  end
end
puts "  Categories: #{categories.map(&:name).join(', ')}"

# Subcategories
subcats = []
categories.first(3).each do |cat|
  2.times do |i|
    sub = Category.find_or_create_by!(
      name: "#{cat.name} - Sub #{i + 1}",
      store: store,
      parent: cat
    ) do |c|
      c.description = Faker::Lorem.sentence
      c.position = i
      c.active = true
    end
    subcats << sub
  end
end
puts "  Subcategories: #{subcats.count} created"

# Products
products = []
20.times do |i|
  cat = categories.sample
  product = Product.find_or_create_by!(
    name: Faker::Commerce.unique.product_name,
    store: store
  ) do |p|
    p.category = cat
    p.description = Faker::Lorem.paragraph(sentence_count: 4)
    p.short_description = Faker::Lorem.sentence
    p.base_price_cents = rand(999..99999)
    p.base_price_currency = 'USD'
    p.compare_at_price_cents = [nil, rand(10000..120000)].sample
    p.sku = "SKU-#{format('%04d', i + 1)}"
    p.track_inventory = true
    p.quantity = rand(0..100)
    p.status = %w[active active active draft archived].sample
    p.featured = [true, false, false, false].sample
    p.position = i
    p.published_at = p.status == 'active' ? Time.current : nil
    p.custom_attributes = { color: Faker::Color.color_name, material: Faker::Commerce.material }
  end
  products << product
end
puts "  Products: #{products.count} created"

# Variants
products.each do |product|
  variant_count = rand(2..3)
  variant_count.times do |vi|
    colors = %w[Red Blue Green Black White]
    sizes = %w[S M L XL]
    color = colors.sample
    size = sizes.sample

    ProductVariant.find_or_create_by!(
      product: product,
      name: "#{color} / #{size}",
      store: store
    ) do |v|
      v.sku = "#{product.sku}-#{color[0]}#{size}"
      v.price_cents = product.base_price_cents + rand(-500..500).abs
      v.price_currency = 'USD'
      v.track_inventory = true
      v.quantity = rand(0..50)
      v.options = { color: color, size: size }
      v.position = vi
      v.active = true
    end
  end
end
puts "  Variants: created for all products"

# Customers
customers = []
3.times do |i|
  customer = Customer.find_or_create_by!(
    email: Faker::Internet.unique.email,
    store: store
  ) do |c|
    c.first_name = Faker::Name.first_name
    c.last_name = Faker::Name.last_name
    c.phone = Faker::PhoneNumber.phone_number
    c.password = 'password123'
    c.password_confirmation = 'password123'
    c.accepts_marketing = [true, false].sample
  end
  customers << customer
end
puts "  Customers: #{customers.map(&:email).join(', ')}"

# Orders
statuses_flow = [
  { status: 'pending' },
  { status: 'confirmed' },
  { status: 'paid', paid_at: 2.days.ago },
  { status: 'shipped', paid_at: 5.days.ago, shipped_at: 1.day.ago },
  { status: 'delivered', paid_at: 10.days.ago, shipped_at: 5.days.ago, delivered_at: 1.day.ago }
]

active_products = products.select { |p| p.status == 'active' }
active_products = products.first(5) if active_products.empty?

5.times do |i|
  flow = statuses_flow[i]
  customer = customers.sample
  order_products = active_products.sample(rand(1..3))

  subtotal = 0
  items_data = order_products.map do |p|
    qty = rand(1..3)
    price = p.base_price_cents
    total = price * qty
    subtotal += total
    { product: p, quantity: qty, price: price, total: total }
  end

  order = Order.create!(
    store: store,
    customer: customer,
    email: customer.email,
    status: flow[:status],
    subtotal_cents: subtotal,
    tax_cents: (subtotal * 0.08).to_i,
    total_cents: subtotal + (subtotal * 0.08).to_i,
    shipping_address: {
      line1: Faker::Address.street_address,
      city: Faker::Address.city,
      state: Faker::Address.state_abbr,
      zip: Faker::Address.zip_code,
      country: 'US'
    },
    billing_address: {
      line1: Faker::Address.street_address,
      city: Faker::Address.city,
      state: Faker::Address.state_abbr,
      zip: Faker::Address.zip_code,
      country: 'US'
    },
    placed_at: Time.current,
    paid_at: flow[:paid_at],
    shipped_at: flow[:shipped_at],
    delivered_at: flow[:delivered_at]
  )

  items_data.each do |item|
    order.order_items.create!(
      product: item[:product],
      product_name: item[:product].name,
      sku: item[:product].sku,
      quantity: item[:quantity],
      unit_price_cents: item[:price],
      unit_price_currency: 'USD',
      total_cents: item[:total],
      total_currency: 'USD'
    )
  end
end
puts "  Orders: 5 created in various statuses"

puts "\nSeed complete!"
puts "Login with: owner@demo.com / password123"
