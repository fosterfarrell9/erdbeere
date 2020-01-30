class Implication < ApplicationRecord
  # a premise is a collection of atoms connected by a logical AND
  # "has_many :premises" should be "belongs_to_many :premises".
  has_many :premises
  has_many :atoms, through: :premises
  belongs_to :implies, class_name: 'Atom', touch: true
  has_many :explanations, as: :explainable
  belongs_to :parent_implication, class_name: 'Implication', optional: true
  has_many :children,
           class_name: 'Implication',
           foreign_key: 'parent_implication_id',
           inverse_of: :parent_implication,
           dependent: :destroy
  belongs_to :structure, optional: true
  after_create :apply_to_building_blocks
  validates :implies, presence: true
  validates :premises, presence: true
  validate :uniqueness

  # TODO
  # after_create :apply_to_building_blocks
  # after_destroy :remove_from_building_blocks

  def to_s
    base_struct = implies.stuff_w_props.structure
    s = '*IF* '
    s << atoms.map { |a| '(' + a.to_s + ')' }.join(' *AND* ')
    s << " *THEN* #{implies.to_s}"
    s
  end

  def self.to_a
    Implication.includes(:atoms, :implies).map { |i| [i.atoms_ids, i.implies_id] }
  end

  def self.to_dimacs
    dimacs = ''
    Implication.includes(:premises, :implies).order(:id).all.each do |i|
      i.premises.each do |p|
        dimacs += "#{p.value ? '-' : ''}#{p.atom_id} "
      end
      dimacs += "#{i.implies_value ? '' : '-'}#{i.implies.id} 0 \n"
    end
    dimacs
  end

  def self.to_dimacs_cached
    Rails.cache.fetch('implication_dimacs') do
      self.to_dimacs
    end
  end

  # given a set of atoms (a premise) and an implies-atom, the implication should
  # be unique. if rails were able to cope with this, it would just be
  # validates :implies, uniqueness: { scope: :atoms, :implies_value }
  def uniqueness
    implications_in_scope = Implication.where(implies: implies)
    matches = (implications_in_scope.find_all do |i|
      i.implies == implies && i.implies_value == implies_value && i.atom_ids.sort == premises.map(&:atom_id).sort
    end) - [self]
    return true unless matches.any?
    errors.add(:base, :not_unique)
  end

  # inherit the implication to all structures where the implication's structure
  # appears as a building block
  def apply_to_building_blocks
    return unless structure
    BuildingBlock.where(structure: structure).each do |bb|
      implies_stuff = implies.stuff_w_props == structure ? bb : implies.stuff_w_props
      implies_for_bb = Atom.find_or_create_by(stuff_w_props: implies_stuff,
                                              satisfies: implies.satisfies)
      atoms_for_bb = []
      atoms.each do |a|
        atoms_stuff = a.stuff_w_props == structure ? bb : implies.stuff_w_props
        atom_for_bb = Atom.find_or_create_by(stuff_w_props: atoms_stuff,
                                              satisfies: a.satisfies)
        atoms_for_bb.push(atom_for_bb)
      end
      Implication.create(atoms: atoms_for_bb,
                         implies: implies_for_bb,
                         structure: bb.explained_structure,
                         parent_implication: self,
                         implies_value: implies_value)
    end
  end
end
