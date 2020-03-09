class StructureSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name
  has_many :original_properties, record_type: :property, serializer: :property
end
