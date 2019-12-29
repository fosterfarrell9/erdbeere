class AddValueToPremise < ActiveRecord::Migration[6.0]
  def change
    add_column :premises, :value, :boolean, default: true
  end
end
