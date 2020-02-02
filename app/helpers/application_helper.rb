module ApplicationHelper
	def structured_options_for_select(opts)
		return options_for_select(opts.second) if opts.first == :ungrouped
		grouped_options_for_select(opts.second)
	end
end
