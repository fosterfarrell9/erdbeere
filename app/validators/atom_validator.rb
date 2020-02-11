class AtomValidator < ActiveModel::Validator
  def validate(a)
    if a.satisfies.is_a?(Property)
      return if a.satisfies.structure.related_structures.include?(a.stuff_w_props.structure)
      a.errors[:base] << 'Type mismatch between satisfies.structure and stuff_w_props.structure'
    elsif a.satisfies.is_a?(Atom)
      return if a.stuff_w_props.structure.building_blocks.map(&:structure).map(&:related_structures).flatten.include?(a.satisfies.structure)
      a.errors[:base] << 'There is no building block that matches satisfies.structure'
    else
      a.errors[:base] << 'Something srsly fucked up happened'
    end
  end
end