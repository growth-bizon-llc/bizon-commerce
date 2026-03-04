module Carts
  class UpdateItemService < BaseService
    def initialize(cart:, cart_item_id:, quantity:)
      super()
      @cart = cart
      @cart_item_id = cart_item_id
      @quantity = quantity.to_i
    end

    def call
      cart_item = @cart.cart_items.find_by(id: @cart_item_id)

      unless cart_item
        @errors << "Cart item not found"
        return self
      end

      if @quantity <= 0
        @errors << "Quantity must be greater than 0"
        return self
      end

      check_stock!(cart_item)
      return self unless success?

      cart_item.update!(quantity: @quantity)
      @result = cart_item
      self
    rescue ActiveRecord::RecordInvalid => e
      @errors << e.message
      self
    end

    private

    def check_stock!(cart_item)
      item = cart_item.product_variant || cart_item.product
      return unless item.track_inventory

      if item.quantity < @quantity
        @errors << "Not enough stock available (#{item.quantity} available)"
      end
    end
  end
end
