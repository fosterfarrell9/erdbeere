# Proof class
# plain old ruby class to store proofs
class Proof
	attr_reader :used_implications, :premises, :assumption, :steps, :example

	def initialize(text, example_id)
		parse_proof(text)
		@example = example_id
	end

	def parse_proof(text)
		extract_lines!(text)
		extract_implications!
		extract_premises_and_assumption!
		extract_steps!
		@steps_lines.each_with_index do |l, i|
			j = i + 1
			@steps[j] = {}
			@steps[:lines][j] = l.first
			separator = l.index(0)
			conclusion = l.first(separator).drop(1).map { |x| [x.abs, x.positive?]}
										.to_h
			conclusion = :contradiction if conclusion.empty?
			@steps[j][:conclusion] = conclusion
			used_lines = l[(separator + 1)..(l.length - 2)]
			@steps[j][:used] = []
			used_lines.each do |u|
				result = if u.in?(@used_implications[:lines].values)
								  [:implication, @used_implications[:lines].key(u)]
								 elsif u.in?(@premises[:lines].values)
								 	 [:premise, @premises[:lines].key(u)]
								 elsif u == @assumption[:line]
								 	 [:assumption]
								 else
								 	 [:step, @steps[:lines].key(u)]
								 end
				steps[j][:used].push(result)
			end
		end
		clean_up!
	end

	def clean_up!	
		remove_instance_variable(:@lines)
		remove_instance_variable(:@used_implications_lines)
		remove_instance_variable(:@premises_lines)
		remove_instance_variable(:@assumption_line)
		remove_instance_variable(:@steps_lines)
		@used_implications.except!(:lines)
		@premises.except!(:lines)
		@assumption.except!(:line)
		@steps.except!(:lines)
	end

	def to_s
		aim = "Wir möchten zeigen: \n #{Example.find(@example).description} ist "
		aim += 'nicht ' if true.in?(@assumption.values)
		aim += "#{Atom.find(@assumption.keys.first).property.name}.\n"
		used = "Wir verwenden: \n"
		@used_implications.each do |k,v|
			used += "(I#{k}) #{Implication.find(v).to_s} \n"
		end
		know = "Wir wissen:\n"
		@premises.each do |k,v|
			know += "(V#{k}) #{Example.find(@example).description} ist "
			know += 'nicht ' if false.in?(v.values)
			know += "#{Atom.find(v.keys.first).property.name}.\n"
		end
		assumption = "Annahme: \n #{Example.find(@example).description} ist "
		assumption += 'nicht ' if false.in?(@assumption.values)
		assumption += "#{Atom.find(@assumption.keys.first).property.name}.\n"
		proof = "Beweis: \n"
		@steps.each do |i,s|
			proof += "Schritt (#{i}): \n"
			if s[:conclusion] != :contradiction
				proof += "#{Example.find(@example).description} ist "
				proof += 'nicht ' if false.in?(s[:conclusion].values)
				proof += "#{Atom.find(s[:conclusion].keys.first).property.name}.\n"
			else
				proof += "Widerspruch.\n"
			end
			proof += "Das folgt aus:"
			s[:used].each do |u|
				if u.first == :implication
					proof += "I(#{u.second}), "
				elsif u.first == :premise
					proof += "V(#{u.second}), "
				elsif u.first == :step
					proof += "Schritt (#{u.second}), "
				elsif u.first == :assumption
					proof += "Annahme"
				end
			end
			proof += ".\n"
		end
		aim + used + know + assumption + proof
	end

	def extract_lines!(text)
		@lines = text.split("\n").map { |l| l.split(' ').map(&:to_i) }
	end

	def extract_implications!
		implication_ids = Implication.order(:id).pluck(:id)
		implication_map = (1..implication_ids.length).zip(implication_ids).to_h
		@used_implications_lines = @lines.select do |l|
																 l.first.in?(implication_ids)
															 end
		@used_implications = (1..@used_implications_lines.count)
													 .zip(@used_implications_lines
													 				.map { |l| implication_map[l.first] })
													 .to_h
		@used_implications[:lines] = (1..@used_implications.count)
																		.zip(@used_implications_lines
																					 .map(&:first)).to_h															 
	end

	def extract_premises_and_assumption!
		@premises_lines = (@lines - @used_implications_lines).select do |l|
												l.drop(2) == [0,0]
											end
		@assumption_line = @premises_lines.pop
		@premises = (1..@premises_lines.count)
									.zip(@premises_lines
												 .map { |l| [[l.second.abs, l.second.positive?]].to_h })
									.to_h
		@premises[:lines] = (1..@premises.count)
													.zip(@premises_lines.map(&:first)).to_h
		@assumption = [[@assumption_line.second.abs,
										@assumption_line.second.positive?]].to_h
		@assumption[:line] = @assumption_line.first
	end

	def extract_steps!
		@steps_lines = @lines -
										(@used_implications_lines + @premises_lines +
											[@assumption_line])
		@steps = {}
		@steps[:lines] = {}
	end
end