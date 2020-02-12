# NoImmediateContradiction validator
class NoImmediateContradiction < ActiveModel::Validator
  def validate(obj)
    return if obj.satisfied != false
    return unless obj.example.satisfied_atoms.include?(obj.property.to_atom)

    obj.errors[:base] << "property #{obj.property.name} is already satisfied,"
    obj.errors[:base] << "can't hardcode to false."
  end
end
