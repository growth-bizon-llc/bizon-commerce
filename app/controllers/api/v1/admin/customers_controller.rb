module Api
  module V1
    module Admin
      class CustomersController < BaseController
        def index
          customers = policy_scope(Customer).includes(:orders).order(created_at: :desc)
          customers = customers.where("email ILIKE ?", "%#{params[:q]}%") if params[:q].present?

          pagy, records = pagy(customers, limit: (params[:per_page] || 20).to_i.clamp(1, 100))
          render json: {
            customers: CustomerSerializer.new(records).serializable_hash,
            meta: pagination_meta(pagy)
          }
        end

        def show
          customer = Customer.find(params[:id])
          authorize customer
          render json: CustomerSerializer.new(customer).to_h
        end
      end
    end
  end
end
