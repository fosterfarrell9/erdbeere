class BuildingBlock < ApplicationRecord
  belongs_to :explained_structure, class_name: 'Structure',
             foreign_key: 'explained_structure_id'
  belongs_to :structure
  before_destroy :destroy_dependent_stuff
  after_create :copy_structure_implications_to_explained_structure
  has_many :atoms, as: :stuff_w_props

  validates :explained_structure, presence: true
  validates :structure, presence: true

  translates :name, :definition, fallbacks_for_empty_translations: true
  globalize_accessors
  validates :name, presence: true
  validates :definition, presence: true

  def stuff_id
  	"b-#{id}"
  end

  def destroy_dependent_stuff
    atoms.destroy_all
  end

  def selectable_structures
    return Structure.all unless explained_structure
    Structure.all - explained_structure.descendants
  end

  private

  # inherit the implications associated to the building block's structure
  # to the explained_structure
  def copy_structure_implications_to_explained_structure
    structure.implications.each do |i|
      implies_stuff = i.implies.stuff_w_props == structure ? self : i.implies.stuff_w_props
      implies_for_bb = Atom.find_or_create_by(stuff_w_props: implies_stuff,
                                              satisfies: i.implies.satisfies)
      atoms_for_bb = []
      atoms.each do |a|
        atoms_stuff = a.stuff_w_props == structure ? bb : a.stuff_w_props
        atom_for_bb = Atom.find_or_create_by(stuff_w_props: atoms_stuff,
                                              satisfies: a.satisfies)
        atoms_for_bb.push(atom_for_bb)
      end
      Implication.create(atoms: atoms_for_bb,
                         implies: implies_for_bb,
                         structure: explained_structure,
                         parent_implication: i,
                         implies_value: i.implies_value)            

    end
  end
end
