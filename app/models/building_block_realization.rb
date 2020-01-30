class BuildingBlockRealization < ApplicationRecord
  belongs_to :example, touch: true
  belongs_to :building_block
  belongs_to :realization, class_name: 'Example'

  validates :example, presence: true
  validates :building_block, presence: true
  validates :realization, presence: true

  validate :valid_realization
  validate :compatibility
  validate :realization_match

  def compatibility
    if realization&.structure.in?(building_block.structure.related_structures)
      return true
    end
    errors.add(:realization, :incompatible_structure)
  end

  def valid_realization
    return true if realization&.valid?
    errors.add(:realization, :invalid)
  end

  def realization_match
    return unless realization
    if (building_block.structure.defining_atoms -
          realization.satisfied_atoms_by_sat).empty?
      return true
    end
    errors.add(:realization, :axioms_violated)
  end
end
