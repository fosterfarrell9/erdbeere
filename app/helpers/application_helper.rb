# Application helper
module ApplicationHelper
  def structured_options_for_select(opts)
    return options_for_select(opts.second) if opts.first == :ungrouped

    grouped_options_for_select(opts.second)
  end

  def building_block_description(bb_id)
    building_block = BuildingBlock.find_by_id(bb_id)
    "#{building_block.name}: #{building_block.definition}"
  end
end
