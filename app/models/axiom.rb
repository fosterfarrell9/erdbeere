# Axiom class
class Axiom < ApplicationRecord
  belongs_to :structure
  belongs_to :atom

  def modifier
    value ? '' : '-'
  end

  def to_cnf
    "#{modifier}#{atom.id} 0 \n"
  end
end
