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
        decrement_inventory!
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

      validate_prices!
      validate_single_currency!
      validate_products_available!
      validate_stock!
    end

    def validate_single_currency!
      currencies = @cart.cart_items.pluck(:unit_price_currency).uniq
      if currencies.size > 1
        @errors << "All items must use the same currency. Found: #{currencies.join(', ')}"
      end
    end

    def validate_products_available!
      @cart.cart_items.includes(:product).each do |cart_item|
        product = cart_item.product
        if product.nil? || product.discarded?
          @errors << "Product is no longer available. Please update your cart."
          next
        end
        unless product.status == 'active'
          @errors << "#{product.name} is not currently available for purchase."
          next
        end
        if cart_item.product_variant_id.present? && cart_item.product_variant.nil?
          @errors << "A selected variant for #{product.name} is no longer available. Please update your cart."
          next
        end
      end
    end

    def validate_stock!
      @cart.cart_items.includes(:product, :product_variant).each do |cart_item|
        variant = cart_item.product_variant
        product = cart_item.product

        if variant
          next unless variant.track_inventory

          if variant.quantity < cart_item.quantity
            @errors << "Insufficient stock for #{product.name}. Only #{variant.quantity} available."
          end
        else
          next unless product.track_inventory

          if product.quantity < cart_item.quantity
            @errors << "Insufficient stock for #{product.name}. Only #{product.quantity} available."
          end
        end
      end
    end

    def validate_prices!
      @cart.cart_items.includes(:product, :product_variant).each do |cart_item|
        current_price = if cart_item.product_variant
                          cart_item.product_variant.price_cents
                        else
                          cart_item.product.base_price_cents
                        end

        if cart_item.unit_price_cents != current_price
          @errors << "Price has changed for #{cart_item.product.name}. Please refresh your cart."
          return
        end
      end
    end

    def create_order
      subtotal = @cart.total
      tax = (BigDecimal(subtotal.to_s) * BigDecimal(@cart.store.tax_rate.to_s) / BigDecimal('100')).round
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

    def decrement_inventory!
      @cart.cart_items.includes(:product, :product_variant).each do |cart_item|
        variant = cart_item.product_variant
        product = cart_item.product

        if variant && variant.track_inventory
          variant.lock!
          raise ActiveRecord::RecordInvalid, variant unless variant.quantity >= cart_item.quantity

          variant.update!(quantity: variant.quantity - cart_item.quantity)
        elsif !variant && product.track_inventory
          product.lock!
          raise ActiveRecord::RecordInvalid, product unless product.quantity >= cart_item.quantity

          product.update!(quantity: product.quantity - cart_item.quantity)
        end
      end
    end

    def update_cart_status
      @cart.update!(status: 'converted')
    end
  end
end
