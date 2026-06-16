class CategorySerializer
  include Alba::Resource

  attributes :id, :name, :slug, :description, :position, :active,
             :parent_id, :created_at, :updated_at

  attribute :children_count do |category|
    category.children.size
  end

  attribute :products_count do |category|
    category.products.size
  end

  attribute :image_url do |category|
    if category.image.attached?
      host = ENV.fetch('APP_HOST', 'localhost')
      url_options = { host: host }
      if host.include?('.')
        url_options[:protocol] = 'https'
      else
        url_options[:port] = ENV.fetch('APP_PORT', 3000)
      end
      Rails.application.routes.url_helpers.rails_blob_url(category.image, **url_options)
    end
  end
end
