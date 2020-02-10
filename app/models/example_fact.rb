class NoImmediateContradiction < ActiveModel::Validator
  def validate(obj)
    return if obj.satisfied != false
    return unless obj.example.satisfied_atoms_by_sat.include?(obj.property.to_atom)
    obj.errors[:base] << "property #{obj.property.name} is already satisfied,"
    obj.errors[:base] << "can't hardcode to false."
  end
end

class ExampleFact < ApplicationRecord
  belongs_to :example, touch: true
  belongs_to :property
  has_one :explanation, as: :explainable, dependent: :destroy
  after_create :touch_example
  after_destroy :touch_example

  validates :example, presence: true
  validates :property, presence: true, uniqueness: { scope: :example }
  validates :satisfied, inclusion: { in: [true, false] }
  validates_with EqualityTest, a: 'example.structure', b: 'property.structure'
  validates_with NoImmediateContradiction

  def violated?
    if satisfied.nil?
      nil
    else
      !satisfied
    end
  end

  def satisfied?
    satisfied
  end

  def irrelevant?
    atoms = Atom.where(satisfies: property)
    structure_atoms = atoms.where(stuff_w_props_type: 'Structure')
    structure_axioms = Axiom.where(atom: structure_atoms)
    structures = structure_axioms.map(&:structure)
    structures.each do |s|
      return false if example.in?(s.examples)
    end
  end

  def touch_example
    example.touch
    property.touch
  end
end
