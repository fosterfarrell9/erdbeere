require 'open3'

class Example < ApplicationRecord
  include CacheIt
  has_many :example_facts
  has_many :building_block_realizations
  belongs_to :structure
  has_many :explanations, as: :explainable
  has_many :appearances_as_building_block_realizations, class_name: 'BuildingBlockRealization', foreign_key: 'realization_id'

  validates :structure, presence: true
  after_commit :touch_appearances_as_building_block_realizations

  translates :description, fallbacks_for_empty_translations: true
  globalize_accessors

  def self.find_restricted(structure, satisfies, violates)
    dimacs = "p cnf #{Atom.count} "
    dimacs.concat("#{Implication.count + satisfies.size + violates.size} \n")
    dimacs.concat(Implication.to_dimacs_cached)
    satisfies.each { |s| dimacs.concat("#{s.id} 0 \n") }
    violates.each { |v| dimacs.concat("#{-v.id} 0 \n") }
    out, err, st = Open3.capture3("echo '#{dimacs}' | picosat -n")
    if out == "s UNSATISFIABLE\n"
      out, trace, st = Open3.capture3("echo '#{dimacs}' | picosat.trace -T /dev/stderr")
      proof = Proof.new('find', trace, nil, structure)
    end
    proof
  end

  def realization(atom)
    if atom.satisfies.is_a?(Property)
      if atom.stuff_w_props_type == 'Structure'
        return self
      elsif atom.stuff_w_props_type == 'BuildingBlock'
        return building_block_realizations_flattened.find do |bbr|
          bbr.building_block_id == atom.stuff_w_props_id
        end  .realization
      end
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
  cache_it :building_block_realizations_flattened

  def touch_appearances_as_building_block_realizations
    appearances_as_building_block_realizations.update_all(updated_at: Time.now)
  end

  def hardcoded_flat_truths
    example_facts.find_all { |t| t.satisfied == true }.map { |t| t.property.to_atom } + structure.defining_atoms
  end

  def hardcoded_flat_falsehoods
    example_facts.find_all { |t| t.satisfied == false }.map { |t| t.property.to_atom }
  end

  def hardcoded_flat_truths_as_properties
    # TODO deep atoms
    hardcoded_flat_truths.map(&:property)
  end

  def hardcoded_falsehoods_as_properties
    # TODO deep atoms
    hardcoded_flat_falsehoods.map(&:property)
  end

  def facts(test: [true, false])
    a = []
    if building_block_realizations.present?
      a += building_block_realizations.map do |bbr|
        sub_facts = bbr.realization.facts(test: test)
        # those sub facts are now of the wrong type: the resulting Atoms have
        # stuff_w_props = bbr.realization.structure, not the building block we want!
        sub_facts.map do |st|
          if st.stuff_w_props.is_a?(Structure)
            Atom.find_or_create_by(stuff_w_props: bbr.building_block, satisfies: st.satisfies)
          else
            st
          end
        end
      end
    end

    a += example_facts.where(satisfied: test).map do |et|
      Atom.find_or_create_by(stuff_w_props: structure, satisfies: et.property)
    end.to_a

    if (test.is_a?(Array) && test.include?(true)) || test === true
      a += structure.defining_atoms
    end

    a.flatten
  end

  def hardcoded_truths
    facts(test: true).uniq
  end
  cache_it :hardcoded_truths

  def hardcoded_falsehoods
    facts(test: false).uniq
  end
  cache_it :hardcoded_falsehoods

  def to_dimacs
    dimacs = "p cnf #{Atom.count} "
    dimacs.concat("#{Implication.count + hardcoded_truths.size + hardcoded_falsehoods.size + 1} \n")
    dimacs.concat(Implication.to_dimacs_cached)
    hardcoded_truths.each { |a| dimacs.concat("#{a.id} 0 \n") }
    hardcoded_falsehoods.each { |a| dimacs.concat("-#{a.id} 0 \n") }
    dimacs
  end
  cache_it :to_dimacs

  def derived_atoms_by_sat(satisfied: true, with_proof: false)
    result = []
    proofs = {}
    props = structure.properties_as_atoms - (hardcoded_truths + hardcoded_falsehoods)
    props.each do |prop|
      dimacs = to_dimacs
      assumption = satisfied ? -prop.id : prop.id
      dimacs.concat("#{assumption} 0 \n")
      out, err, st = Open3.capture3("echo '#{dimacs}' | picosat -n")
      if out == "s UNSATISFIABLE\n"
        if with_proof
          out, trace, st = Open3.capture3("echo '#{dimacs}' | picosat.trace -T /dev/stderr")
          result.push(prop)
          proofs[prop] = Proof.new('example', trace, id, nil)
        else
          result.push(prop)
        end
      end
    end
    return [result + hardcoded_falsehoods, proofs] if !satisfied && with_proof
    return result + hardcoded_falsehoods if !satisfied
    return [result + hardcoded_truths, proofs] if with_proof
    result + hardcoded_truths
  end

  def satisfied_atoms_by_sat
    derived_atoms_by_sat
  end
  cache_it :satisfied_atoms_by_sat

  def satisfied_atoms_by_sat_with_proof
    derived_atoms_by_sat(with_proof: true)
  end
  cache_it :satisfied_atoms_by_sat_with_proof

  def violated_atoms_by_sat
    derived_atoms_by_sat(satisfied: false)
  end
  cache_it :violated_atoms_by_sat

  def violated_atoms_by_sat_with_proof
    derived_atoms_by_sat(satisfied: false, with_proof: true)
  end
  cache_it :violated_atoms_by_sat_with_proof

  def satisfies?(atom)
    # atom might be a property
    atom = atom.is_a?(Property) ? atom.to_atom : atom

    satisfied_atoms_by_sat.include?(atom)
  end

  def violates?(atom)
    # might be a property
    atom = atom.is_a?(Property) ? atom.to_atom : atom
    violated_atoms_by_sat.include?(atom)
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
      ExampleFact.find_or_create_by(example: self, property: atom.property, satisfied: value)
    end
  end
end
