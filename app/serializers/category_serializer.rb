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
end
