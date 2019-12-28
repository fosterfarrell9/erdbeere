class BuildingBlock < ApplicationRecord
  belongs_to :explained_structure, class_name: 'Structure',
             foreign_key: 'explained_structure_id'
  belongs_to :structure
  has_many :atoms, as: :stuff_w_props

  validates :explained_structure, presence: true
  validates :structure, presence: true

  translates :name, :definition, fallbacks_for_empty_translations: true
  globalize_accessors

  def stuff_id
  	"b-#{id}"
  end

# TODO
#  after_create :inherit_implications_from_structure

  private


  # fülle BuildingBlock mit passenden Implikationen von seiner
  # Struktur, z.B. Basisring von R-Mod mit den Implikationen für
  # Ringe
	# TODO: cf. copy_implications in core_ext/array.rb , seeds/rings_and_modules.rb
  # def inherit_implications_from_structure
  # 	hash = {}
  # 	structure.properties.each do |p|
  # 		hash[p] = Atom.create(stuff_w_props: self, satisfies: p)
  # 	end
  # 	Implication.all.to_a.each do |im|
  # 		if im.implies.in?(structure.properties)
  # 			Implication.create do |c|
  # 				c.atoms =
  # 				c.implies = hash.select { |k,v| im.implies == structure.p}
  # 			end
  # 		end
  # 	end
  # end
end
