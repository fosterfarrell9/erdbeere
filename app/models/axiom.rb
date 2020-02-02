class Axiom < ApplicationRecord
  belongs_to :structure
  belongs_to :atom

  def modifier
  	value ? '' : '-'
  end
end
