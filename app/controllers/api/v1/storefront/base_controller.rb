module Api
  module V1
    module Storefront
      class BaseController < ApplicationController
        include Multi::Tenantable
        include Pagy::Method

        private

        def resolve_store
          domain = request.headers["X-Store-Domain"].presence || extract_domain_from_origin
          return nil unless domain

          Store.find_by(custom_domain: domain) || Store.find_by(subdomain: domain)
        end

        def extract_domain_from_origin
          origin = request.headers["Origin"]
          return nil unless origin
          URI.parse(origin).host
        rescue URI::InvalidURIError
          nil
        end

        def current_cart
          token = request.headers["X-Cart-Token"] || params[:cart_token]
          @current_cart ||= Cart.find_by(token: token, status: 'active') if token
        end

        def current_customer
          token = request.headers["X-Customer-Token"]
          return nil unless token

          @current_customer ||= begin
            decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')
            Customer.find_by(id: decoded.first['customer_id'])
          rescue JWT::DecodeError
            nil
          end
        end

        def authenticate_customer!
          render json: { error: "Customer authentication required" }, status: :unauthorized unless current_customer
        end

        def pagination_meta(pagy)
          {
            current_page: pagy.page,
            per_page: pagy.limit,
            total_pages: pagy.pages,
            total_count: pagy.count
          }
        end
      end
    end
  end
end
