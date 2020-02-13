# Axiom class
class Axiom < ApplicationRecord
  belongs_to :structure
  belongs_to :atom

  def modifier
    value ? '' : '-'
  end

  def logic_modifier
    value ? I18n.t('logic.is') : I18n.t('logic.is_not')
  end

  def to_cnf
    "#{modifier}#{atom.id} 0 \n"
  end
end
