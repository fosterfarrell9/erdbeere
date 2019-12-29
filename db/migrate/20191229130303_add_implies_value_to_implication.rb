class AddImpliesValueToImplication < ActiveRecord::Migration[6.0]
  def change
    add_column :implications, :implies_value, :boolean, default: true
  end
end
