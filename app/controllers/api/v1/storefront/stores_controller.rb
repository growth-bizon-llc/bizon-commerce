module Api
  module V1
    module Storefront
      class StoresController < BaseController
        def show
          render json: StoreSerializer.new(Current.store).to_h
        end
      end
    end
  end
end
