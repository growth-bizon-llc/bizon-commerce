module Carts
  class AddItemService < BaseService
    def initialize(cart:, product:, variant: nil, quantity: 1)
      super()
      @cart = cart
      @product = product
      @variant = variant
      @quantity = quantity.to_i
    end

    def call
      validate!
      return self unless success?

      ActiveRecord::Base.transaction do
        @result = @cart.add_item(@product, @variant, @quantity)
      end

      self
    rescue ActiveRecord::RecordInvalid => e
      @errors << e.message
      self
    end

    private

    def validate!
      if @quantity <= 0
        @errors << "Quantity must be greater than 0"
        return
      end

      if @product.status != 'active'
        @errors << "Product is not available"
        return
      end

      if @variant && !@variant.active?
        @errors << "Variant is not available"
        return
      end

      check_stock!
    end

    def check_stock!
      item = @variant || @product
      return unless item.track_inventory

      available = item.quantity
      existing = @cart.cart_items.find_by(product: @product, product_variant: @variant)
      already_in_cart = existing&.quantity || 0

      if available < (already_in_cart + @quantity)
        @errors << "Not enough stock available (#{available} available)"
      end
    end
  end
end
