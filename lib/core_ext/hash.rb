# Hash class
class Hash
  def copy_implications(hash, buildingblock)
    hash.each do |p_name, p|
      self[p_name] = Atom.create do |a|
        a.stuff_w_props = buildingblock
        a.satisfies = p.property
      end
    end
    Implication.all.to_a.each do |im|
      next unless hash.value?(im.implies)

      atoms = self.select { |k, _v| im.atoms.include?(hash[k]) }.values
      implies = self.select { |k, _v| im.implies == hash[k] }.values.first
      Implication.create(atoms: atoms,
                         implies: implies,
                         parent_implication: im)
    end
  end
end
