# Array class
class Array
  def of_atoms?
    find_all { |m| !m.is_a?(Atom) }.empty?
  end

  def implies!(atom)
    raise 'Not all members of Array are Atoms' unless of_atoms?

    if atom.is_a?(Array)
      atom.each do |a|
        implies! a
      end
    elsif atom.is_a?(Atom)
      Implication.create(atoms: self, implies: atom)
    else
      raise 'Argument not of type Atom'
    end
  end

  def is_equivalent!(atoms)
    atoms.each do |a|
      Implication.create(atoms: self, implies: a)
    end
    each do |a|
      Implication.create(atoms: atoms, implies: a)
    end
  end
end
