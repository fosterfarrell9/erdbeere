class PropertySerializer
  include FastJsonapi::ObjectSerializer
  attributes :name
  belongs_to :structure
end
