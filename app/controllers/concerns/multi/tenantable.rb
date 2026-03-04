module Multi
  module Tenantable
    extend ActiveSupport::Concern

    included do
      before_action :set_current_store
    end

    private

    def set_current_store
      Current.store = resolve_store
      raise ActiveRecord::RecordNotFound, "Store not found" unless Current.store
    end

    def resolve_store
      raise NotImplementedError
    end
  end
end
