# ExampleFact class
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
    Example.update_all(updated_at: Time.now)
    Property.update_all(updated_at: Time.now)
  end
end
