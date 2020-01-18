class AddParentImplicationIdToImplication < ActiveRecord::Migration[6.0]
  def change
    add_column :implications, :parent_implication_id, :integer
  end
end
