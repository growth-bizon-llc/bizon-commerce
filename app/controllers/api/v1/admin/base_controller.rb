module Api
  module V1
    module Admin
      class BaseController < ApplicationController
        before_action :authenticate_user!
        include Multi::Tenantable
        include Pundit::Authorization
        include Pagy::Method

        after_action :verify_authorized, unless: :index_action?
        after_action :verify_policy_scoped, if: :index_action?

        private

        def resolve_store
          current_user&.store
        end

        def index_action?
          action_name == 'index'
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
