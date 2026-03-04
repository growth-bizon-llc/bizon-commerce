class StoreSerializer
  include Alba::Resource

  attributes :id, :name, :slug, :custom_domain, :subdomain,
             :description, :currency, :locale, :settings, :active,
             :tax_rate, :created_at, :updated_at
end
