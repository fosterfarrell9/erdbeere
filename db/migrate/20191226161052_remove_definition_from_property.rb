class RemoveDefinitionFromProperty < ActiveRecord::Migration[6.0]
  def change

    remove_column :properties, :definition, :text
  end
end
