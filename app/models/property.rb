class Property < ApplicationRecord
  belongs_to :structure
  has_many :atoms, as: :satisfies

  validates :structure, presence: true

  translates :name, :definition, fallbacks_for_empty_translations: true
  validates :name, presence: true
  globalize_accessors

  def to_atom(stuff_w_props = structure)
    Atom.find_or_create_by(stuff_w_props: stuff_w_props,
                           satisfies: self)
  end

  def positive_examples
  	structure.examples.select { |e| e.satisfies?(to_atom) }
  end

  def negative_examples
  	structure.examples.select { |e| e.violates?(to_atom) }
  end

  def positive_hardcoded_facts
    ExampleFact.where(example: positive_examples,
                      property: self,
                      satisfied: true)
  end

  def negative_hardcoded_facts
    ExampleFact.where(example: negative_examples,
                      property: self,
                      satisfied: false)
  end

  def positive_derived_examples
    positive_examples - positive_hardcoded_facts.map(&:example)
  end

  def negative_derived_examples
    negative_examples - negative_hardcoded_facts.map(&:example)
  end

  def example_facts
    ExampleFact.where(property: self)
  end
end
