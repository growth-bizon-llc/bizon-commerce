class CategoryListSerializer
  include Alba::Resource

  attributes :id, :name, :slug, :position, :active, :parent_id
end
