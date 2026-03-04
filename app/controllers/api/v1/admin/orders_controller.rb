module Api
  module V1
    module Admin
      class OrdersController < BaseController
        before_action :set_order, only: [:show, :update]

        def index
          orders = policy_scope(Order).includes(:customer, :order_items).order(created_at: :desc)
          orders = orders.by_status(params[:status]) if params[:status].present?

          pagy, records = pagy(orders, limit: (params[:per_page] || 20).to_i.clamp(1, 100))
          render json: {
            orders: OrderListSerializer.new(records).serializable_hash,
            meta: pagination_meta(pagy)
          }
        end

        def show
          authorize @order
          render json: OrderSerializer.new(@order).to_h
        end

        def update
          authorize @order
          return render json: { error: "Event parameter is required" }, status: :bad_request unless params[:event].present?

          service = Orders::UpdateStatusService.new(order: @order, event: params[:event])
          service.call

          if service.success?
            render json: OrderSerializer.new(service.result).to_h
          else
            render json: { errors: service.errors }, status: :unprocessable_entity
          end
        end

        private

        def set_order
          @order = Order.includes(:order_items, :customer).find(params[:id])
        end
      end
    end
  end
end
