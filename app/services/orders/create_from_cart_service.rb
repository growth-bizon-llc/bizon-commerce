module Orders
  class CreateFromCartService < BaseService
    def initialize(cart:, email:, customer: nil, shipping_address: {}, billing_address: {}, notes: nil)
      super()
      @cart = cart
      @email = email
      @customer = customer
      @shipping_address = shipping_address
      @billing_address = billing_address
      @notes = notes
    end

    def call
      validate!
      return self unless success?

      ActiveRecord::Base.transaction do
        @result = create_order
        create_order_items
        update_cart_status
      end

      self
    rescue ActiveRecord::RecordInvalid => e
      @errors << e.message
      self
    end

    private

    def validate!
      if @cart.cart_items.empty?
        @errors << "Cart is empty"
        return
      end

      @errors << "Email is required" if @email.blank?
    end

    def create_order
      subtotal = @cart.total
      tax = 0
      total = subtotal + tax

      Order.create!(
        store_id: @cart.store_id,
        customer: @customer,
        email: @email,
        subtotal_cents: subtotal,
        tax_cents: tax,
        total_cents: total,
        shipping_address: @shipping_address,
        billing_address: @billing_address,
        notes: @notes,
        placed_at: Time.current
      )
    end

    def create_order_items
      @cart.cart_items.includes(:product, :product_variant).each do |cart_item|
        item_total = cart_item.unit_price_cents * cart_item.quantity

        @result.order_items.create!(
          product: cart_item.product,
          product_variant: cart_item.product_variant,
          product_name: cart_item.product.name,
          variant_name: cart_item.product_variant&.name,
          sku: cart_item.product_variant&.sku || cart_item.product.sku,
          quantity: cart_item.quantity,
          unit_price_cents: cart_item.unit_price_cents,
          unit_price_currency: cart_item.unit_price_currency,
          total_cents: item_total,
          total_currency: cart_item.unit_price_currency
        )
      end
    end

    def update_cart_status
      @cart.update!(status: 'converted')
    end
  end
end
