class AddAspaceIdsToAccessions < ActiveRecord::Migration

  def change
  	add_column :accessions, :aspace_col_id, :integer
  	add_column :accessions, :aspace_acc_id, :integer
  	add_column :collections, :aspace_col_id, :integer
  end
end
