class AddDefinitionToProperty < ActiveRecord::Migration[6.0]
  def change
    add_column :properties, :definition, :text
  end
end
