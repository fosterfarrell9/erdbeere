# Structures helper
module StructuresHelper
  def building_block_class(building_block)
    return 'BuildingBlockForm' if building_block.persisted?

    'newBuildingBlock'
  end
end
