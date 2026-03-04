module Api
  module V1
    module Admin
      class StoresController < BaseController
        def show
          authorize Current.store
          render json: StoreSerializer.new(Current.store).to_h
        end

        def update
          authorize Current.store
          Current.store.update!(store_params)
          render json: StoreSerializer.new(Current.store).to_h
        end

        private

        def store_params
          params.require(:store).permit(:name, :description, :custom_domain,
                                        :subdomain, :currency, :locale, :active,
                                        :tax_rate, settings: {})
        end
      end
    end
  end
end
