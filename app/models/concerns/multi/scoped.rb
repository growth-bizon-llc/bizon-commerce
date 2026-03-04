module Multi
  module Scoped
    extend ActiveSupport::Concern

    included do
      belongs_to :store
      default_scope { where(store: Current.store) if Current.store }
    end
  end
end
