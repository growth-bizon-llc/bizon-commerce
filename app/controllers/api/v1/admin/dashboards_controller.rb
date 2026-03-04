module Api
  module V1
    module Admin
      class DashboardsController < BaseController
        skip_after_action :verify_authorized
        skip_after_action :verify_policy_scoped

        def show
          render json: {
            total_products: Product.where(store: Current.store).count,
            total_orders: Order.where(store: Current.store).count,
            total_customers: Customer.where(store: Current.store).count,
            total_revenue_cents: Order.where(store: Current.store).where(status: %w[paid processing shipped delivered]).sum(:total_cents),
            orders_by_status: Order.where(store: Current.store).group(:status).count,
            recent_orders: OrderListSerializer.new(Order.where(store: Current.store).includes(:order_items, :customer).order(created_at: :desc).limit(5)).serializable_hash
          }
        end
      end
    end
  end
end
