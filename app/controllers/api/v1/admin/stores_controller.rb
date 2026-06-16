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
          merged = store_params
          if merged[:settings].present?
            merged[:settings] = (Current.store.settings || {}).deep_merge(merged[:settings])
          end
          Current.store.update!(merged)
          render json: StoreSerializer.new(Current.store.reload).to_h
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
