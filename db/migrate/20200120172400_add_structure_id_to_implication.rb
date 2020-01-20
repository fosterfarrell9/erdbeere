class AddStructureIdToImplication < ActiveRecord::Migration[6.0]
  def change
    add_column :implications, :structure_id, :integer
  end
end
