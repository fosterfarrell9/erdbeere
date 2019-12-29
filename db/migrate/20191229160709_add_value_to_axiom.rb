class AddValueToAxiom < ActiveRecord::Migration[6.0]
  def change
    add_column :axioms, :value, :boolean, default: true
  end
end
