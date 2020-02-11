# Property class
class Property < ApplicationRecord
  include CacheIt
  belongs_to :structure
  has_many :atoms, as: :satisfies
  before_destroy :destroy_example_facts
  before_destroy :destroy_atoms
  after_destroy :touch_examples_and_structures

  validates :structure, presence: true

  translates :name, :definition, fallbacks_for_empty_translations: true
  validates :name, presence: true
  globalize_accessors

  def to_atom(stuff_w_props = structure)
    Atom.find_or_create_by(stuff_w_props: stuff_w_props,
                           satisfies: self)
  end

  def positive_examples
    structure.examples.select do |e|
      e.satisfies?(to_atom)
    end
  end

  def negative_examples
    structure.examples.select { |e| e.violates?(to_atom) }
  end

  def positive_hardcoded_facts
    ExampleFact.where(example: positive_examples,
                      property: self,
                      satisfied: true)
  end
  cache_it :positive_hardcoded_facts

  def negative_hardcoded_facts
    ExampleFact.where(example: negative_examples,
                      property: self,
                      satisfied: false)
  end
  cache_it :negative_hardcoded_facts

  def positive_derived_examples
    positive_examples - positive_hardcoded_facts.map(&:example)
  end
  cache_it :positive_derived_examples

  def negative_derived_examples
    negative_examples - negative_hardcoded_facts.map(&:example)
  end
  cache_it :negative_derived_examples

  def example_facts
    ExampleFact.where(property: self)
  end

  def related_implications
    atoms.map(&:related_implications).flatten.uniq
  end

  def related_axioms
    atoms.map(&:axioms).flatten.uniq
  end

  def irrelevant?
    return false if related_implications.any?
    return false if related_axioms.any?

    true
  end

  def destroy_example_facts
    example_facts.delete_all
  end

  def destroy_atoms
    atoms.destroy_all
  end

  def touch_examples_and_structures
    Structure.update_all(updated_at: Time.now)
    Example.update_all(updated_at: Time.now)
  end
end
