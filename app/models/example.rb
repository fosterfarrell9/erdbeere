require 'open3'

# Example class
class Example < ApplicationRecord
  include CacheIt
  has_many :example_facts, dependent: :destroy
  has_many :building_block_realizations, dependent: :destroy
  belongs_to :structure
  has_many :explanations, as: :explainable, dependent: :destroy
  has_many :appearances_as_building_block_realizations,
           class_name: 'BuildingBlockRealization',
           foreign_key: 'realization_id'

  validates :structure, presence: true
  after_create :create_axiom_facts
  after_save :touch_appearances_as_building_block_realizations
  after_save :touch_related_properties

  translates :description, fallbacks_for_empty_translations: true
  validates :description, presence: true
  globalize_accessors
  validates_associated :building_block_realizations
  validate :correct_bb_realizations?
  validate :axioms_fulfilled?
  validate :no_duplicate_deep_realizations?

  accepts_nested_attributes_for :building_block_realizations

  def self.find_contradiction(structure, satisfies, violates)
    dimacs = Example.dimacs_header(structure, satisfies, violates) +
             Implication.to_dimacs
    dimacs += Example.dimacs_assumptions(structure, satisfies, violates)
    Proof.from_dimacs('find', dimacs, nil, structure)
  end

  def self.dimacs_header(structure, satisfies, violates)
    "p cnf #{Atom.last.id} "\
      "#{Implication.count + satisfies.size + violates.size +
           structure.axioms.size} \n"
  end

  def self.dimacs_assumptions(structure, satisfies, violates)
    result = ''
    structure.axioms.each { |axiom| result.concat(axiom.to_cnf) }
    satisfies.each { |s| result.concat(s.to_cnf) }
    violates.each { |v| result.concat(v.to_cnf(value: false)) }
    result
  end

  def realization(atom)
    if atom.satisfies.is_a?(Property)
      return self if atom.stuff_w_props_type == 'Structure'

      building_block_realizations_flattened.find do |bbr|
        bbr.building_block_id == atom.stuff_w_props_id
      end  .realization
    else
      realization(atom.satisfies)
    end
  end

  def building_block_realizations_flattened
    return [] unless building_block_realizations.any?

    bbrs = building_block_realizations
    bbrs += building_block_realizations.map do |bbr|
      bbr.realization.building_block_realizations_flattened
    end
    bbrs.flatten
  end

  def touch_appearances_as_building_block_realizations
    appearances_as_building_block_realizations.update_all(updated_at: Time.now)
  end

  def hardcoded_true_facts
    example_facts.where(satisfied: true)
  end

  def hardcoded_false_facts
    example_facts.where(satisfied: false)
  end

  def hardcoded_flat_truths
    example_facts.find_all { |t| t.satisfied == true }
                 .map { |t| t.property.to_atom } +
      structure.positive_defining_atoms
  end

  def hardcoded_flat_falsehoods
    example_facts.find_all { |t| t.satisfied == false }
                 .map { |t| t.property.to_atom } +
      structure.negative_defining_atoms
  end

  def hardcoded_flat_truths_as_properties
    hardcoded_flat_truths.map(&:property)
  end

  def hardcoded_falsehoods_as_properties
    hardcoded_flat_falsehoods.map(&:property)
  end

  def subfacts(test: [true, false])
    return [] unless building_block_realizations.present?

    building_block_realizations.map do |bbr|
      sub_facts = bbr.realization.facts(test: test)
      # those sub facts are now of the wrong type: the resulting Atoms have
      # stuff_w_props = bbr.realization.structure, not the building block
      # we want!
      sub_facts.map do |st|
        if st.stuff_w_props.is_a?(Structure)
          Atom.find_or_create_by(stuff_w_props: bbr.building_block,
                                 satisfies: st.satisfies)
        else
          st
        end
      end
    end
  end

  def axiom_facts(test: [true, false])
    if test == [true, false]
      structure.defining_atoms
    elsif test == [true] || test === true
      structure.positive_defining_atoms
    elsif test == [false] || test === false
      structure.negative_defining_atoms
    end
  end

  def facts(test: [true, false])
    a = subfacts(test: test)
    a += example_facts.where(satisfied: test).map do |et|
      Atom.find_or_create_by(stuff_w_props: structure, satisfies: et.property)
    end.to_a
    a += axiom_facts(test: test)
    a.flatten.uniq
  end

  def hardcoded_truths
    facts(test: true).uniq
  end
  cache_it :hardcoded_truths

  def hardcoded_falsehoods
    facts(test: false).uniq
  end
  cache_it :hardcoded_falsehoods

  def dimacs_header
    "p cnf #{Atom.last.id} "\
    "#{Implication.count + hardcoded_truths.size + hardcoded_falsehoods.size +
        1} \n"
  end

  def to_dimacs
    dimacs = dimacs_header + Implication.to_dimacs
    hardcoded_truths.each { |a| dimacs.concat(a.to_cnf) }
    hardcoded_falsehoods.each { |a| dimacs.concat(a.to_cnf(value: false)) }
    dimacs
  end
#  cache_it :to_dimacs

  def checkable_props(deep: false)
    props = structure.properties_as_atoms -
            (hardcoded_truths + hardcoded_falsehoods)
    return props unless deep

    (props + structure.example_bb_facts).uniq
  end

  def derived_atoms(satisfied: true, deep: false)
    result = {}
    checkable_props(deep: deep).each do |prop|
      dimacs = to_dimacs + prop.to_cnf(value: !satisfied)
      proof = Proof.from_dimacs('example', dimacs, id, nil)
      next unless proof

      result[prop] = proof
    end
    hardcoded = satisfied ? hardcoded_truths : hardcoded_falsehoods
    result.merge(Hash[hardcoded.zip])
  end

  def satisfied_atoms_with_proof
    derived_atoms
  end
  cache_it :satisfied_atoms_with_proof

  def satisfied_atoms
    satisfied_atoms_with_proof.keys.to_a
  end
  cache_it :satisfied_atoms

  def violated_atoms_with_proof
    derived_atoms(satisfied: false)
  end
  cache_it :violated_atoms_with_proof

  def violated_atoms
    violated_atoms_with_proof.keys.to_a
  end
  cache_it :violated_atoms

  def satisfied_deep_atoms
    derived_atoms(deep: true).keys.to_a
  end
  cache_it :satisfied_deep_atoms

  def violated_deep_atoms
    derived_atoms(satisfied: false, deep: true).keys.to_a
  end
  cache_it :violated_deep_atoms

  def satisfies?(atom)
    # atom might be a property
    atom = atom.is_a?(Property) ? atom.to_atom : atom

    satisfied_atoms.include?(atom)
  end

  def violates?(atom)
    # might be a property
    atom = atom.is_a?(Property) ? atom.to_atom : atom
    violated_atoms.include?(atom)
  end

  def satisfies!(atom)
    set_truth(atom, true)
  end

  def violates!(atom)
    set_truth(atom, false)
  end

  def set_truth(atom, value)
    if atom.is_a?(Array)
      atom.each do |a|
        set_truth(a, value)
      end
    elsif atom.is_a?(Property)
      set_truth(atom.to_atom, value)
    else
      methods = { true => 'satisfies?', false => 'violates?' }
      raise 'not implemented' unless atom.stuff_w_props == structure
      raise "already set to #{!value}" if send(methods[!value], atom)

      ExampleFact.find_or_create_by(example: self,
                                    property: atom.property,
                                    satisfied: value)
    end
  end

  def correct_bb_realizations?
    return true unless structure
    return true unless structure.original_building_blocks

    structure.original_building_blocks.each do |bb|
      realizations = building_block_realizations.select do |bbr|
        bbr.building_block == bb
      end
      next if realizations.count == 1 && realizations.first.valid?

      errors.add(:building_block_realizations, :incorrect)
      return false
    end
    true
  end

  def create_axiom_facts
    structure.axioms.each do |a|
      next unless a.atom.stuff_w_props_type == 'Structure'

      ExampleFact.find_or_create_by(example: self,
                                    property: a.atom.property,
                                    satisfied: a.value)
    end
  end

  def axioms_fulfilled?
    structure.defining_atoms.each do |a|
      next if a.stuff_w_props_type == 'Structure'

      bb = a.stuff_w_props
      bbr = building_block_realizations.find { |x| x.building_block == bb }
      if bbr.nil? || !bbr.valid?
        errors.add(:building_block_realizations, :incorrect)
        return false
      end
      realization = bbr.realization
      satisfies_atom = a.satisfies.to_atom
      return true if satisfies_atom.in?(realization.satisfied_atoms)

      errors.add(:base, :axioms_fail)
      return false
    end
    true
  end

  def irrelevant?
    return false if appearances_as_building_block_realizations.any?

    true
  end

  def touch_related_properties
    Property.where(id: structure.related_structures
                                .map(&:original_property_ids).flatten)
            .update_all(updated_at: Time.now)
  end

  def no_duplicate_deep_realizations?
    return unless building_block_realizations.any?

    structure.duplicate_building_blocks.each do |bb|
      realizations = building_block_realizations_flattened.select do |bbr|
        bbr.building_block == bb
      end
      next if realizations.map(&:realization_id).uniq.count == 1

      errors.add(:base, :realization_conflict)
      return false
    end
    true
  end
end
