require 'open3'

# Proof class
# plain old ruby class to store proofs
class Proof
  attr_reader :sort, :used_implications, :premises, :assumption, :steps,
              :axioms, :example, :structure

  def initialize(sort, text, example_id, structure)
    @sort = sort
    @example = example_id if @sort == 'example'
    @structure = structure if @sort == 'find'
    parse_proof(text)
  end

  def self.from_dimacs(sort, dimacs, example_id, structure)
    out, trace, _st = Open3.capture3("echo '#{dimacs}' | "\
                                      'picosat.trace -T /dev/stderr')
    return unless out == "s UNSATISFIABLE\n"

    Proof.new(sort, trace, example_id, structure)
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
      conclusion = l.first(separator).drop(1).map { |x| [x.abs, x.positive?] }
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
                 elsif @axioms[:lines] && u.in?(@axioms[:lines].values)
                   [:axiom, @axioms[:lines].key(u)]
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
    remove_instance_variable(:@axioms_lines)
    @used_implications.except!(:lines)
    @premises.except!(:lines)
    @assumption.except!(:line)
    @axioms.except!(:lines)
    @steps.except!(:lines)
  end

  def extract_lines!(text)
    @lines = text.split("\n").map { |l| l.split(' ').map(&:to_i) }
  end

  def extract_implications!
    implication_ids = Implication.order(:id).pluck(:id)
    implication_map = (1..implication_ids.length).zip(implication_ids).to_h
    @used_implications_lines = @lines.select do |l|
      l.first.in?(implication_map.keys)
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
      l.drop(2) == [0, 0]
    end
    if sort == 'example'
      @assumption_line = @premises_lines.pop
      @axioms_lines = []
      @axioms = {}
    else
      axiom_values = @structure.axioms.pluck(:atom_id, :value)
                               .map { |a| a[0] * (-1)**(a[1] ? 0 : 1) }
      @axioms_lines = @premises_lines.select { |l| l.second.in?(axiom_values) }
      @premises_lines -= @axioms_lines
    end
    @premises = (1..@premises_lines.count)
                .zip(@premises_lines
                       .map { |l| [[l.second.abs, l.second.positive?]].to_h })
                .to_h
    @premises[:lines] = (1..@premises.count)
                        .zip(@premises_lines.map(&:first)).to_h
    if @sort == 'example' && @assumption_line
      @assumption = [[@assumption_line.second.abs,
                      @assumption_line.second.positive?]].to_h
      @assumption[:line] = @assumption_line.first
    else
      @assumption = {}
      @assumption_line = nil
      @axioms = (1..@axioms_lines.count)
                .zip(@axioms_lines
                       .map { |l| [[l.second.abs, l.second.positive?]].to_h })
                .to_h
      @axioms[:lines] = (1..@axioms.count)
                        .zip(@axioms_lines.map(&:first)).to_h
    end
  end

  def extract_steps!
    previous_lines = @used_implications_lines + @premises_lines
    previous_lines += if @sort == 'example'
                        [@assumption_line]
                      else
                        @axioms_lines
                      end
    @steps_lines = @lines - previous_lines
    @steps = {}
    @steps[:lines] = {}
  end
end
