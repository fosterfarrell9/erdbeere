# Atom validator
class AtomValidator < ActiveModel::Validator
  def validate(atom)
    if atom.satisfies.is_a?(Property)
      if atom.satisfies.structure.related_structures
             .include?(atom.stuff_w_props.structure)
        return
      end

      atom.errors.add(:base, 'Type mismatch between satisfies.structure and '\
                             'stuff_w_props.structure')
    elsif atom.satisfies.is_a?(Atom)
      if atom.stuff_w_props.structure.building_blocks.map(&:structure)
             .map(&:related_structures).flatten
             .include?(atom.satisfies.structure)
        return
      end

      atom.errors.add(:base, 'There is no building block that matches '\
                             'satisfies.structure')
    else
      atom.errors.add(:base, 'Something srsly fucked up happened')
    end
  end
end
