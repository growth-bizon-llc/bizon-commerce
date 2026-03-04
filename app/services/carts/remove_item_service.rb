module Carts
  class RemoveItemService < BaseService
    def initialize(cart:, cart_item_id:)
      super()
      @cart = cart
      @cart_item_id = cart_item_id
    end

    def call
      cart_item = @cart.cart_items.find_by(id: @cart_item_id)

      unless cart_item
        @errors << "Cart item not found"
        return self
      end

      cart_item.destroy!
      @result = @cart.reload
      self
    rescue ActiveRecord::RecordNotDestroyed => e
      @errors << e.message
      self
    end
  end
end
